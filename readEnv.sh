#! /bin/bash

#$1 file to source if it exists
sourceIfExists() {
    if [ -f "$1" ]; then
        source "$1"
    fi
}

ROOT_DIR="$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )"
pushd "$ROOT_DIR" || exit
export ROOT_DIR

sourceIfExists "$ROOT_DIR"/env
sourceIfExists "$ROOT_DIR"/.env


popd || exit
