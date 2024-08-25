#!/bin/bash
# [ Build ]
dest="/opt/network-components"
#dest="$(pwd)"
docker build "${dest}/docker-images/alpine-image/" -t alpine-user
docker build "${dest}/docker-images/containernet-image/" -t containernet

# [ Start ]
docker run -d --name containernet -it --rm --privileged --pid='host' -v /var/run/docker.sock:/var/run/docker.sock --mount type=bind,source="${dest}/topology",target=/netlabautoops containernet python3 /netlabautoops/topology.py
# docker attach containernet
# docker exec -it mn.router1 bash'