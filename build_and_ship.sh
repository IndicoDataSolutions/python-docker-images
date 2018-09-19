#! /bin/bash
IMAGE_NAME=$1

set -e

docker build --no-cache -t indico/$IMAGE_NAME -f $IMAGE_NAME ${@:2} .
docker push indico/$IMAGE_NAME
