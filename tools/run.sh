#!/bin/sh
set -xe

IMAGE=${1}
if test X${IMAGE} = X; then
  echo "Usage: ${0} image-name"
  echo "i.e. ${0} thedxw/workshop"
  exit 1
fi

# chown the socket file
docker run -ti --rm -v /var/run/docker.sock:/var/run/docker.sock busybox chmod 777 /var/run/docker.sock

if test X`docker inspect --format='{{.State.Running}}' workshop` = Xtrue; then
  # Reattach
  exec docker attach workshop
else
  # Remove stale
  docker rm workshop || true
  # Start fresh
  exec docker run -ti --rm --name workshop --hostname workshop -v /usr/bin/docker:/usr/local/bin/docker:ro -v /var/run/docker.sock:/var/run/docker.sock -v /workbench:/workbench ${IMAGE}
fi
