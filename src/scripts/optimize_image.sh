#!/usr/bin/env bash

set -euo pipefail

SOURCE="${BASH_SOURCE[0]}"
while [ -h "$SOURCE" ] ; do SOURCE="$(readlink "$SOURCE")"; done
CDIR="$( cd -P "$( dirname "$SOURCE" )" && pwd )"

[[ -z "${API_TOKEN:-}" ]] && { echo "API_TOKEN is not set"; exit 1; }
[[ -z "${API_DOMAIN:-}" ]] && { echo "API_DOMAIN is not set"; exit 1; }
[[ -z "${CONNECTOR_ID:-}" ]] && { echo "CONNECTOR_ID is not set"; exit 1; }
[[ -z "${TARGET_IMAGE_TAG:-}" ]] && { echo "TARGET_IMAGE_TAG is not set"; exit 1; }
[[ -z "${TARGET_IMAGE_NAME:-}" ]] && { echo "TARGET_IMAGE_NAME is not set"; exit 1; }
[[ -z "${TARGET_IMAGE_NS:-}" ]] && { echo "TARGET_IMAGE_NS is not set"; exit 1; }
[[ -z "${ORGANIZATION_ID:-}" ]] && { echo "ORGANIZATION_ID is not set"; exit 1; }

printf "[optimize_image.sh] API_DOMAIN: ${API_DOMAIN}\n"
printf "[optimize_image.sh] ORGANIZATION_ID: ${ORGANIZATION_ID}\n"
printf "[optimize_image.sh] CONNECTOR_ID: ${CONNECTOR_ID}\n"
printf "[optimize_image.sh] TARGET_IMAGE_TAG: ${TARGET_IMAGE_TAG}\n"
printf "[optimize_image.sh] TARGET_IMAGE_NAME: ${TARGET_IMAGE_NAME}\n"
printf "[optimize_image.sh] TARGET_IMAGE_NS: ${TARGET_IMAGE_NS}\n"


ai=$(curl -s -u :${API_TOKEN} https://${API_DOMAIN}/account/identity)
# printf "ai:\n${ai}\n\n"

export SYSTEM_ORG="${ORGANIZATION_ID}" #$(jq -r '.default_org' <<< "${ai}")
printf "[optimize_image.sh] SYSTEM_ORG: ${SYSTEM_ORG}\n"

jsonData="$(<${CDIR}/optimize_image_nxreq.json)"

jsonDataUpdated=${jsonData//__CONNECTOR_ID__/${CONNECTOR_ID}}
jsonDataUpdated=${jsonDataUpdated//__TARGET_IMAGE_NS__/${TARGET_IMAGE_NS}}
jsonDataUpdated=${jsonDataUpdated//__TARGET_IMAGE_NAME__/${TARGET_IMAGE_NAME}}
jsonDataUpdated=${jsonDataUpdated//__TARGET_IMAGE_TAG__/${TARGET_IMAGE_TAG}}

printf "NX build request:\n${jsonDataUpdated}\n\n"

nx=$(curl -s -H 'Content-Type: application/json' -X POST -u :${API_TOKEN} https://${API_DOMAIN}/orgs/${SYSTEM_ORG}/engine/executions -d "${jsonDataUpdated}")
printf "NX:\n${nx}\n\n"

nxID=$(jq -r '.id' <<< "${nx}")
printf "minify NX id: ${nxID}\n"

nxState="unknown"
while [[ ${nxState} != "completed" ]]; do
	nxState=$(curl -s -u :${API_TOKEN} https://${API_DOMAIN}/orgs/${SYSTEM_ORG}/engine/executions/${nxID} | jq -r '.state')
    printf "current NX state: ${nxState}\n"
    [[ "${nxState}" == "failed" || "${nxState}" == "null" ]] && { echo "minify NX failed - exiting..."; exit 1; }
    sleep 3
done

printf "nx[done] state=${nxState}\n"






