#!/bin/bash
#echo Hello "${PARAM_TO}"
echo Installing Docker-Slim
#curl -sL https://raw.githubusercontent.com/docker-slim/docker-slim/master/scripts/install-dockerslim.sh | sudo -E bash -
# docker pull dslim/docker-slim
echo X-Ray Scan : "${PARAM_IMAGE}"

# docker-slim xray --pull --target "${PARAM_IMAGE}"

# cat slim.report.json >> /tmp/artifact-xray;

echo Syft sbom

curl -sSfL https://raw.githubusercontent.com/anchore/syft/main/install.sh | sudo sh -s -- -b /usr/local/bin

syft "${PARAM_IMAGE}" -o json #=sbom.syft.json

#cat sbom.syft.json >> /tmp/artifact-syft;