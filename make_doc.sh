#!/bin/bash
docker-compose run \
    -u code \
    -w /data/docs_src \
    --entrypoint "" \
    devdoc-swissknife \
    make devdoc-swissknife-en
    # make
    # bash
    # ping kroki
