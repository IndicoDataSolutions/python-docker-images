#! /bin/bash

TAG=0.20.1

docker pull strimzi/operator:$TAG
docker tag strimzi/operator:$TAG gcr.io/new-indico/strimzi-operator:$TAG
docker push gcr.io/new-indico/strimzi-operator:$TAG
