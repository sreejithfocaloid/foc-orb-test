#!/usr/bin/env bash

set -euo pipefail

# SOURCE="./"
# while [ -h "$SOURCE" ] ; do SOURCE="$(readlink "$SOURCE")"; done
# CDIR="$( cd -P "$( dirname "$SOURCE" )" && pwd )"



printf "SaaS optimize container image...\n"
./optimize_image.sh

printf "EXECUTE [DONE]\n"
