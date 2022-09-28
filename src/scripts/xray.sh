#!/bin/bash
#echo Hello "${PARAM_TO}"
echo Installing Docker-Slim
#curl -sL https://raw.githubusercontent.com/docker-slim/docker-slim/master/scripts/install-dockerslim.sh | sudo -E bash -
# docker pull dslim/docker-slim


#docker-slim xray --pull --target "${PARAM_IMAGE}" --registry-account="${DOCKERHUB_USERNAME}"  --registry-secret="${DOCKERHUB_PASSWORD}"

echo "Fetching Details for" : "${PARAM_IMAGE}"

imageDetails=$(curl -u ":${SAAS_KEY}" -X "GET" \
  "https://platform.slim.dev/orgs/${ORG_ID}/collection/images?limit=10&entity=${PARAM_IMAGE}" \
  -H "accept: application/json")
 

imageDetail=$(jq -r '.data[0]' <<< "${imageDetails}")
connectorId=$(jq -r '.connector' <<< "${imageDetail}")
nameSpace=$(jq -r '.namespace' <<< "${imageDetail}")


echo Starting X-Ray Scan : "${PARAM_IMAGE}"

jsonData="${XRAY_REQUEST}"
command=xray
jsonDataUpdated=${jsonData//__CONNECTOR_ID__/${connectorId}}
jsonDataUpdated=${jsonDataUpdated//__NAMESPACE__/${nameSpace}}
jsonDataUpdated=${jsonDataUpdated//__REPO__/${PARAM_IMAGE}}
jsonDataUpdated=${jsonDataUpdated//__COMMAND__/${command}}

xrayRequest=$(curl -u ":${SAAS_KEY}" -X 'POST' \
  "https://platform.slim.dev/orgs/${ORG_ID}/engine/executions" \
  -H 'accept: application/json' \
  -H 'Content-Type: application/json' \
  -d "${jsonDataUpdated}")

executionId=$(jq -r '.id' <<< "${xrayRequest}")


echo Starting X-Ray Scan status check : "${PARAM_IMAGE}"


executionStatus=$(curl -u ":${SAAS_KEY}" -X 'GET' \
  "https://platform.slim.dev/orgs/${ORG_ID}/engine/executions/${executionId}" \
  -H 'accept: application/json')

echo "${executionStatus}"
# cat slim.report.json >> /tmp/artifact-xray;

# shaId=$(cat slim.report.json  | jq -r '.source_image.identity.digests[0]')
# tag=$(cat slim.report.json  | jq -r '.source_image.identity.tags[0]')
# fullName=$(cat slim.report.json  | jq -r '.source_image.identity.names[0]')
# echo "${shaId}"
# echo "${tag}"

# imageDetails=$(curl -X POST "https://platform.slim.dev/orgs/${ORG_ID}/collections/${FAV_COLLECTION_ID}/images" -H  "accept: application/json" -H  "Authorization: Basic ${SAAS_KEY}" -H  "Content-Type: application/json" -d "{\"connector\":\"dockerhub.public\",\"entity\":\"${PARAM_IMAGE}\",\"namespace\":\"library\",\"icon_url\":\"\",\"attributes\":{\"additionalProp1\":[null],\"additionalProp2\":[null],\"additionalProp3\":[null]}}")
# imageId=$(jq -r '.data.id' <<< "${imageDetails}")
# nameSpace=$(jq -r '.data.namespace' <<< "${imageDetails}")
# entity=$(jq -r '.data.entity' <<< "${imageDetails}")
# connector=$(jq -r '.data.connector' <<< "${imageDetails}")
# echo "${imageId}"



# curl -X POST "https://platform.slim.dev/orgs/${ORG_ID}/collections/${FAV_COLLECTION_ID}/images/"${imageId}"/pins" -H  "accept: application/json" -H  "Authorization: Basic ${SAAS_KEY}" -H  "Content-Type: application/json" -d "{\"scope\":\"tag\",\"connector\":\"dockerhub.public\",\"entity\":\"${entity}\",\"namespace\":\"${nameSpace}\",\"version\":\"${tag}\",\"digest\":\"\",\"os\":\"linux\",\"arch\":\"amd64\"}"









#cat sbom.syft.json >> /tmp/artifact-syft;



# {
#   "scope": "digest",
#   "connector": "dockerhub.public",
#   "entity": "postgres",
#   "namespace": "library",
#   "version": "latest",
#   "digest": "sha256:cbbf2f9a99b47fc460d422812b6a5adff7dfee951d8fa2e4a98caa0382cfbdbf",
#   "os": "linux",
#   "arch": "amd64"
# }