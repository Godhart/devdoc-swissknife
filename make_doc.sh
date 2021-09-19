#/bin/bash
docker-compose run \
    -u rstudio \
    -w /docs/src \
    --entrypoint "" \
    rstudio \
    make
    # make
    # bash
    # ping kroki
