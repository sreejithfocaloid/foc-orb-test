#!/bin/bash
#echo Hello "${PARAM_TO}"
echo Installing Docker-Slim
curl -sL https://raw.githubusercontent.com/docker-slim/docker-slim/master/scripts/install-dockerslim.sh | sudo -E bash -
# docker pull dslim/docker-slim
echo X-Ray Scan : "${PARAM_IMAGE}"

docker-slim xray --pull --target "${PARAM_IMAGE}"

cat slim.report.json >> /tmp/artifact-xray;

echo cat slim.report.json  | jq -r '.source_image.identity.id'
echo cat slim.report.json  | jq -r '.source_image.identity.tags[0]'


curl -X POST "https://platform.slim.dev/orgs/rko.24nRz6GvLBo9hah9dqmhHON820R/collections/rkcol.2EADUkqrBkln6jbfc9RYbHiZVp7/images" -H  "accept: application/json" -H  "Authorization: Basic ${SAAS_KEY}" -H  "Content-Type: application/json" -d "{\"connector\":\"dockerhub.public\",\"entity\":\"${PARAM_IMAGE}\",\"namespace\":\"library\",\"icon_url\":\"\",\"attributes\":{\"additionalProp1\":[null],\"additionalProp2\":[null],\"additionalProp3\":[null]}}"


#cat sbom.syft.json >> /tmp/artifact-syft;