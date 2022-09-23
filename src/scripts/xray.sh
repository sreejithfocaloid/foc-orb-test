#!/bin/bash
#echo Hello "${PARAM_TO}"
echo Installing Docker-Slim
curl -sL https://raw.githubusercontent.com/docker-slim/docker-slim/master/scripts/install-dockerslim.sh | sudo -E bash -
# docker pull dslim/docker-slim
echo X-Ray Scan : "${PARAM_IMAGE}"

docker-slim xray --pull --target "${PARAM_IMAGE}" --json-output

cat slim.report.json >> /tmp/artifact-xray;
# echo $(cat slim.report.json)

shaId=$(cat slim.report.json  | jq -r '.source_image.identity.id')
tag=$(cat slim1.report.json  | jq -r '.source_image.identity.tags')
fullName=$(cat slim.report.json  | jq -r '.source_image.identity.names[0]')
echo "${shaId}"
echo "${tag}"

imageDetails=$(curl -X POST "https://platform.slim.dev/orgs/rko.24nRz6GvLBo9hah9dqmhHON820R/collections/rkcol.2EADUkqrBkln6jbfc9RYbHiZVp7/images" -H  "accept: application/json" -H  "Authorization: Basic ${SAAS_KEY}" -H  "Content-Type: application/json" -d "{\"connector\":\"dockerhub.public\",\"entity\":\"${PARAM_IMAGE}\",\"namespace\":\"library\",\"icon_url\":\"\",\"attributes\":{\"additionalProp1\":[null],\"additionalProp2\":[null],\"additionalProp3\":[null]}}")
imageId=$(jq -r '.data.id' <<< "${imageDetails}")
nameSpace=

echo "${imageId}"
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