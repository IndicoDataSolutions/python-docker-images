#! /bin/bash
docker build -t indicoio/${1} -f Dockerfile/${1} .
docker push indicoio/${1}