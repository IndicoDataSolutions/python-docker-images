#! /bin/bash

TAG=0.20.1-kafka-2.6.0

docker pull strimzi/kafka:$TAG
docker tag strimzi/kafka:$TAG gcr.io/new-indico/strimzi-kafka:$TAG
docker push gcr.io/new-indico/strimzi-kafka:$TAG
