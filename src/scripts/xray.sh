#!/bin/bash
#echo Hello "${PARAM_TO}"
echo Installing Docker-Slim
curl -sL https://raw.githubusercontent.com/docker-slim/docker-slim/master/scripts/install-dockerslim.sh | sudo -E bash -
# docker pull dslim/docker-slim
echo X-Ray Scan : "${PARAM_IMAGE}"

docker-slim xray --pull --target "${PARAM_IMAGE}" --registry-account="${DOCKERHUB_USERNAME}"  --registry-secret="${DOCKERHUB_PASSWORD}"

cat slim.report.json >> /tmp/artifact-xray;

shaId=$(cat slim.report.json  | jq -r '.source_image.identity.digests[0]')
tag=$(cat slim.report.json  | jq -r '.source_image.identity.tags[0]')
fullName=$(cat slim.report.json  | jq -r '.source_image.identity.names[0]')
echo "${shaId}"
echo "${tag}"

imageDetails=$(curl -X POST "https://platform.slim.dev/orgs/${ORG_ID}/collections/${FAV_COLLECTION_ID}/images" -H  "accept: application/json" -H  "Authorization: Basic ${SAAS_KEY}" -H  "Content-Type: application/json" -d "{\"connector\":\"dockerhub.public\",\"entity\":\"${PARAM_IMAGE}\",\"namespace\":\"library\",\"icon_url\":\"\",\"attributes\":{\"additionalProp1\":[null],\"additionalProp2\":[null],\"additionalProp3\":[null]}}")
imageId=$(jq -r '.data.id' <<< "${imageDetails}")
nameSpace=$(jq -r '.data.namespace' <<< "${imageDetails}")
entity=$(jq -r '.data.entity' <<< "${imageDetails}")
connector=$(jq -r '.data.connector' <<< "${imageDetails}")
echo "${imageId}"



curl -X POST "https://platform.slim.dev/orgs/${ORG_ID}/collections/${FAV_COLLECTION_ID}/images/"${imageId}"/pins" -H  "accept: application/json" -H  "Authorization: Basic ${SAAS_KEY}" -H  "Content-Type: application/json" -d "{\"scope\":\"tag\",\"connector\":\"dockerhub.public\",\"entity\":\"${entity}\",\"namespace\":\"${nameSpace}\",\"version\":\"${tag}\",\"digest\":\"\",\"os\":\"linux\",\"arch\":\"amd64\"}"









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