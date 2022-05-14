_E ?= default.env

include $(_E)
export $(shell sed 's/=.*//' $(_E))

.PHONY: show-env
show-env:
	env

all: docker make

.PHONY: clean-docker
	docker image rm devdoc-swissknife		|| echo ""

.PHONY: clean-out
	rm -rf `find ${OUT_LOCATION}${OUT_NAME} ! -name .keep ! -name ${OUT_NAME}` || echo ""

clean-all: clean-out clean-docker

.PHONY: docker
docker:
	docker build -t devdoc-swissknife:22.04 .

DOCKER_RUN = docker run --rm -it \
		--network=host \
		--volume="${CODE_HOME}:/home/code" \
		--volume="${CODE_PROJECT}:/data/docs_src" \
		--volume="${OUT_LOCATION}${OUT_NAME}:/data/docs_out" \
		-u `id -u ${USER}`:`id -g ${USER}` \

DOCKER_MAKE = docker run --rm -it \
		--network=host \
		--volume="${CODE_PROJECT}:/data/docs_src" \
		--volume="${OUT_LOCATION}${OUT_NAME}:/data/docs_out" \
		--workdir="/data/docs_src" \
		-u `id -u ${USER}`:`id -g ${USER}` \

DOCKER_LIVE = docker run --rm -it \
		--network=host \
		--volume="$(WD)/home-live:/home/code" \
		--volume="$(WD)/../live:/data/live" \
		--workdir="/data/live" \
		-u `id -u ${USER}`:`id -g ${USER}` \

.PHONY: run
run:
		$(DOCKER_RUN) \
		devdoc-swissknife:22.04 \
		${RUN}

.PHONY: make
make:
		$(DOCKER_MAKE) \
		devdoc-swissknife:22.04 \
		make ${TARGET}

.PHONY: live-dev
live-dev:
		$(DOCKER_LIVE) \
		devdoc-swissknife:22.04 \
		/bin/bash

.PHONY: live
live:
		$(DOCKER_LIVE) \
		devdoc-swissknife:22.04 \
		/bin/bash -c ./build_loop.sh
