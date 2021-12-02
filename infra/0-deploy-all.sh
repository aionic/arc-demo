#! /bin/bash
set -euxo pipefail

SCRIPT_DIR="$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )"
pushd "$SCRIPT_DIR"

ROOT=../
source $ROOT/readEnv.sh

"$SCRIPT_DIR"/1-configCli.sh
"$SCRIPT_DIR"/2-deploy-cluster.sh
"$SCRIPT_DIR"/3-connect-cluster.sh
"$SCRIPT_DIR"/4-deploy-appservice.sh
"$SCRIPT_DIR"/5-create-custom-location.sh
"$SCRIPT_DIR"/6-create-kube-ase.sh

popd
set -euxo pipefail