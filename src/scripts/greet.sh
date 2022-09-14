#!/bin/bash
#echo Hello "${PARAM_TO}"
echo Installing Docker-Slim
curl -sL https://raw.githubusercontent.com/docker-slim/docker-slim/master/scripts/install-dockerslim.sh | sudo -E bash -
# docker pull dslim/docker-slim
echo X-Ray Scan : "${PARAM_IMAGE}"

docker-slim xray --pull --target "${PARAM_IMAGE}"

echo "my artifact ddfile" > /tmp/artifact-1.json;
