#! /bin/bash
image=$1
docker build -f Dockerfile/$image -t ${image} .