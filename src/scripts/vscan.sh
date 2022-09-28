#!/bin/bash
echo "$CONNECTOR_ID"

echo Starting Vulnerability Scan : "${PARAM_IMAGE}"

jsonData="${VSCAN_REQUEST}"
command=vscan
jsonDataUpdated=${jsonData//__CONNECTOR_ID__/${CONNECTOR_ID}}
jsonDataUpdated=${jsonDataUpdated//__NAMESPACE__/${NAMESPACE}}
jsonDataUpdated=${jsonDataUpdated//__REPO__/${PARAM_IMAGE}}
jsonDataUpdated=${jsonDataUpdated//__COMMAND__/${command}}

xrayRequest=$(curl -u ":${SAAS_KEY}" -X 'POST' \
  "https://platform.slim.dev/orgs/${ORG_ID}/engine/executions" \
  -H 'accept: application/json' \
  -H 'Content-Type: application/json' \
  -d "${jsonDataUpdated}")

echo "${xrayRequest}"



executionId=$(jq -r '.id' <<< "${xrayRequest}")


echo Starting Vulnerability Scan status check : "${PARAM_IMAGE}"

echo "${executionId}"

executionStatus="unknown"
while [[ ${executionStatus} != "completed" ]]; do
	executionStatus=$(curl -s -u :"${SAAS_KEY}" https://platform.slim.dev/orgs/"${ORG_ID}"/engine/executions/"${executionId}" | jq -r '.state')
    printf 'current NX state: %s '"$executionStatus \n"
    [[ "${executionStatus}" == "failed" || "${executionStatus}" == "null" ]] && { echo "Vulnerability scan failed - exiting..."; exit 1; }
    sleep 3
done

printf 'Vulnerability scan Completed state= %s '"$executionStatus \n"

echo Fetching Vulnerability scan report : "${PARAM_IMAGE}"

xrayReport=$(curl -L -u ":${SAAS_KEY}" -X 'GET' \
  "https://platform.slim.dev/orgs/${ORG_ID}/engine/executions/${executionId}/result/report" \
  -H 'accept: application/json' \
  -H 'Content-Type: application/json')

echo "${xrayReport}" >> /tmp/artifact-vscan;



echo "${xrayReport}"

