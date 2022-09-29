#!/bin/bash

echo "Fetching Details for" : "${PARAM_IMAGE}"

imageDetails=$(curl -u ":${SAAS_KEY}" -X "GET" \
  "https://platform.slim.dev/orgs/${ORG_ID}/collection/images?limit=10&entity=${PARAM_IMAGE}" \
  -H "accept: application/json")
 

export imageDetail
imageDetail=$(jq -r '.data[0]' <<< "${imageDetails}")

connectorId=$(jq -r '.connector' <<< "${imageDetail}")
nameSpace=$(jq -r '.namespace' <<< "${imageDetail}")
imageId=$(jq -r '.id' <<< "${imageDetail}")
entity=$(jq -r '.entity' <<< "${imageDetail}")

echo "${imageId}"


echo Starting X-Ray Scan : "${PARAM_IMAGE}"

jsonData="${XRAY_REQUEST}"
command=xray
jsonDataUpdated=${jsonData//__CONNECTOR_ID__/${connectorId}}
jsonDataUpdated=${jsonDataUpdated//__NAMESPACE__/${nameSpace}}
jsonDataUpdated=${jsonDataUpdated//__REPO__/"${PARAM_IMAGE}"}
jsonDataUpdated=${jsonDataUpdated//__COMMAND__/${command}}

xrayRequest=$(curl -u ":${SAAS_KEY}" -X 'POST' \
  "https://platform.slim.dev/orgs/${ORG_ID}/engine/executions" \
  -H 'accept: application/json' \
  -H 'Content-Type: application/json' \
  -d "${jsonDataUpdated}")

executionId=$(jq -r '.id' <<< "${xrayRequest}")


echo Starting X-Ray Scan status check : "${PARAM_IMAGE}"



executionStatus="unknown"
while [[ ${executionStatus} != "completed" ]]; do
	executionStatus=$(curl -s -u :"${SAAS_KEY}" https://platform.slim.dev/orgs/"${ORG_ID}"/engine/executions/"${executionId}" | jq -r '.state')
    printf 'current NX state: %s '"$executionStatus \n"
    [[ "${executionStatus}" == "failed" || "${executionStatus}" == "null" ]] && { echo "XRAY failed - exiting..."; exit 1; }
    sleep 3
done

printf 'XRAY Completed state= %s '"$executionStatus \n"

echo Fetching XRAY report : "${PARAM_IMAGE}"

xrayReport=$(curl -L -u ":${SAAS_KEY}" -X 'GET' \
  "https://platform.slim.dev/orgs/${ORG_ID}/engine/executions/${executionId}/result/report" \
  -H 'accept: application/json' \
  -H 'Content-Type: application/json')

echo "${xrayReport}" >> /tmp/artifact-xray;



shaId=$(jq -r '.source_image.identity.digests[0]' <<< "${xrayReport}")
#tag=$(jq -r '.source_image.identity.tags[0]' <<< "${xrayReport}")

targetRef=$(jq -r '.target_reference' <<< "${xrayReport}")
targ1=$(echo "${targetRef}" | cut -d "@" -f1)
tag=$(echo "${targ1}" | cut -d ":" -f2)

echo "${shaId}"
echo "${tag}"
echo "${imageId}"





curl -u ":${SAAS_KEY}" -X POST "https://platform.slim.dev/orgs/${ORG_ID}/collections/${FAV_COLLECTION_ID}/images/${imageId}/pins" -H  "accept: application/json" -H  "Content-Type: application/json" -d "{\"scope\":\"digest\",\"connector\":\"${connectorId}\",\"entity\":\"${entity}\",\"namespace\":\"${nameSpace}\",\"version\":\"${tag}\",\"digest\":\"${shaId}\",\"os\":\"linux\",\"arch\":\"amd64\"}"


