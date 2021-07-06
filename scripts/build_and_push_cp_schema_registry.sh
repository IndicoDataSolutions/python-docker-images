#! /bin/bash

TAG=5.5.5

docker pull confluentinc/cp-schema-registry:$TAG
docker tag confluentinc/cp-schema-registry:$TAG gcr.io/new-indico/cp-schema-registry:$TAG
docker push gcr.io/new-indico/cp-schema-registry:$TAG
