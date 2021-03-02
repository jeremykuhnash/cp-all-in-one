#!/bin/bash
set -e
DOCKER_IMAGE_PROXY="haproxy:2.3-alpine"
CONTAINER_NAME="haproxy"

SOURCE="${BASH_SOURCE[0]}"
while [ -h "$SOURCE" ]; do # resolve $SOURCE until the file is no longer a symlink
  DIR="$( cd -P "$( dirname "$SOURCE" )" && pwd )"
  SOURCE="$(readlink "$SOURCE")"
  [[ $SOURCE != /* ]] && SOURCE="$DIR/$SOURCE" # if $SOURCE was a relative symlink, we need to resolve it relative to the path where the symlink file was located
done
THIS_DIR="$( cd -P "$( dirname "$SOURCE" )" && pwd )"
echo "This Dir: $THIS_DIR"

docker stop $CONTAINER_NAME || true
docker rm $CONTAINER_NAME || true
docker pull $DOCKER_IMAGE_PROXY || true

docker run \
  --restart unless-stopped \
  -p 0.0.0.0:18082:80 \
  -p 0.0.0.0:48082:443 \
  -p 0.0.0.0:8000:8000 \
  -v $THIS_DIR/haproxy.cfg:/usr/local/etc/haproxy/haproxy.cfg \
  -v $THIS_DIR/mydomain.pem:/etc/ssl/private/mydomain.pem \
  --network cp-all-in-one_default \
  --name $CONTAINER_NAME \
  $DOCKER_IMAGE_PROXY