#!/bin/bash

# This script is a workaround due to inability to invoke bazel run targets from within bazel sandboxes.
# It is a simple shim over test/integration/driver.go that accepts the same set of flags.
# Please add new flags to the Go test driver directly instead of extending this file.
# The additional steps that the script performs are:
# - set default docker tag based on a timestamp and user name
# - build and push docker images, including this repo pieces and proxy.

args=""
hub="gcr.io/istio-testing"
tag=""

while [[ $# -gt 0 ]]; do
    case "$1" in
        -tag) tag="$2"; shift ;;
        -hub) hub="$2"; args=$args" -hub $hub"; shift ;;
        *) args=$args" $1" ;;
    esac
    shift
done

set -ex

if [[ -z $tag ]]; then
  tag=$(whoami)_$(date +%Y%m%d_%H%M%S)
fi
args=$args" -tag $tag"

if [[ "$hub" =~ ^gcr\.io ]]; then
  gcloud docker --authorize-only
fi

for image in app init pilot; do
  bazel $BAZEL_ARGS run //docker:${image}
  docker tag istio/docker:${image} $hub/$image:$tag
  docker push $hub/$image:$tag
done

# Always use debug images
bazel $BAZEL_ARGS run //docker:proxy_debug
docker tag istio/docker:proxy_debug $hub/proxy_debug:$tag
docker push $hub/proxy_debug:$tag

bazel $BAZEL_ARGS run //test/integration -- --logtostderr $args
