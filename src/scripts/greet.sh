#!/bin/bash
#echo Hello "${PARAM_TO}"
echo Installing Docker-Slim
#curl -sL https://raw.githubusercontent.com/docker-slim/docker-slim/master/scripts/install-dockerslim.sh | sudo -E bash -
docker pull dslim/docker-slim
echo X-Ray Scan

docker-slim xray --pull node --registry-account=sreejithfocaloid --registry-secret="${PARAM_KEY}"
