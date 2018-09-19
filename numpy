FROM alpine

RUN apk update && \
    apk add --no-cache build-base && \
    apk add --no-cache python3-dev && \
    apk add --no-cache python3 && \
    apk add --no-cache git && \
    apk add --no-cache bash && \
    apk add --no-cache curl && \
    python3 -m ensurepip && \
    rm -r /usr/lib/python*/ensurepip && \
    pip3 install --upgrade pip setuptools wheel && \
    pip3 install cython

RUN pip3 install numpy
