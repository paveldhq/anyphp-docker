#!/bin/bash

DOCKER_REPO="pratushnyi/anyphp"

TAG="${DOCKER_REPO}${VERSION:+:${VERSION}}${BASE_IMAGE_TAG:+-${BASE_IMAGE_TAG}}"

set -x

docker build . \
    --file "$DOCKERFILE" \
    --no-cache \
    -t "$TAG" \
    --build-arg BASE_IMAGE="${BASE_IMAGE}"

image_id=$(docker images $TAG --format "{{.ID}}")
for tag in ${EXTRA_TAGS//;/$'\n'}
do
    echo $tag
    docker tag $image_id "${DOCKER_REPO}:${tag}"
done

if [ -z "${DOCKER_LOGIN}" ]; then
    exit 0
fi

echo "$DOCKER_PASSWORD" | docker login -u "$DOCKER_LOGIN" --password-stdin
for tag in $(sudo docker images ${DOCKER_REPO} --format "{{.Tag}}");
do
    docker push "${DOCKER_REPO}:${tag}"
done
