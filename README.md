# python-docker-images
For using wheel caches and faster build times

To build:
```bash
./build_and_ship.sh [Name of dependency]
```

To Use:
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
    rm =r /root/.cache # After installing python packages to reduce image size.
```
