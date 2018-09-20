# python-docker-images
Because some python libraries require compilation with Cython and other build dependencies, building and installing these libraries can take very long and introduce large dependencies in a docker image. If we build beforehand and save these compiled caches via python wheel, we can avoid compiling libraries during installation and in turn only require runtime dependencies which are much smaller.

We do this by using a multistage build in which the initial images are ones we have compiled libraries with all the compilation dependencies and copy the wheel cache into our current docker image. With docker image cache locally and on codeship, this speeds up the build significantly and reduces the size of docker images.


## To build:
```bash
./build_and_ship.sh [Name of dependency]
```

## To Use:
```Dockerfile
FROM indico/indicoio as indicoio-base
FROM indico/tsne as tsne-base
FROM indico/sklearn as sklearn-base

COPY --from=tsne-base /root/.cache/pip/wheels /root/tsne.cache
COPY --from=indicoio-base /root/.cache/pip/wheels /root/indicoio.cache
COPY --from=sklearn-base /root/.cache/pip/wheels /root/sklearn.cache

RUN mkdir -p /root/.cache/pip/wheels && \
    cp -r /root/tsne.cache/* /root/.cache/pip/wheels && \
    cp -r /root/sklearn.cache/* /root/.cache/pip/wheels && \
    cp -r /root/indicoio.cache/* /root/.cache/pip/wheels && \
    pip3 install --find-links=/root/.cache/pip/wheels [DEPENDENCIES] && \
    rm -r /root/.cache # After installing python packages to reduce image size.
```
