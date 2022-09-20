#!/usr/bin/env bash

set -euo pipefail

# SOURCE="./"
# while [ -h "$SOURCE" ] ; do SOURCE="$(readlink "$SOURCE")"; done
# CDIR="$( cd -P "$( dirname "$SOURCE" )" && pwd )"



printf "SaaS optimize container image...\n"
__dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "${__dir}"/optimize_image.sh


printf "EXECUTE [DONE]\n"
