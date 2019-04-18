# python-docker-images

Because some python libraries require compilation with Cython and other build dependencies, building and installing these libraries can take very long and introduce large dependencies in a docker image. If we build beforehand and save these compiled caches via python wheel, we can avoid compiling libraries during installation and in turn only require runtime dependencies which are much smaller.

We do this by using a multistage build in which the initial images are ones we have compiled libraries with all the compilation dependencies and copy the wheel cache into our current docker image. With docker image cache locally and on codeship, this speeds up the build significantly and reduces the size of docker images.

## To Build:

```bash
docker build -t indicoio/<name> -f Dockerfile/<name> .
```

## To Use:

```Dockerfile
FROM indicoio/tsne as tsne-base
FROM indicoio/alpine:3.7.3

COPY --from=tsne-base /root/.cache/pip/wheels/ /root/.cache/pip/wheels

RUN pip3 install [DEPENDENCIES] && \
    rm -r /root/.cache # After installing python packages to reduce image size.
```
