_E ?= default.env

include $(_E)
export $(shell sed 's/=.*//' $(_E))

# Check env to be sure of what's going on
.PHONY: show-env
show-env:
	env

# Build docker image then run make. Make target is defined via env
# Instead of Makefile in the top of project, for this one
# services like Kroki etc. should be already running somewhere
all: docker make

# Remove docker container
.PHONY: clean-docker
	docker image rm devdoc-swissknife		|| echo ""

# Remove all build output
.PHONY: clean-out
	rm -rf `find ${OUT_LOCATION}${OUT_NAME} ! -name .keep ! -name ${OUT_NAME}` || echo ""

# Remove container and build output
clean-all: clean-out clean-docker

# NOTE: other clean routines are available via running`TARGET=clean-xxx make make` command
# where xxx - is suffix name for desired clean routine

# Build docker image
.PHONY: docker
docker:
	docker build -t devdoc-swissknife:22.04 .

# Command for interactive actions
DOCKER_RUN = docker run --rm -it \
		--network=host \
		--volume="${CODE_HOME}:/home/code" \
		--volume="${CODE_PROJECT}:/data/docs_src" \
		--volume="${OUT_LOCATION}${OUT_NAME}:/data/docs_out" \
		-u `id -u ${USER}`:`id -g ${USER}` \

# Command for make
DOCKER_MAKE = docker run --rm -it \
		--network=host \
		--volume="${CODE_PROJECT}:/data/docs_src" \
		--volume="${OUT_LOCATION}${OUT_NAME}:/data/docs_out" \
		--workdir="/data/docs_src" \
		-u `id -u ${USER}`:`id -g ${USER}` \

# Command for running live server
DOCKER_LIVE = docker run --rm -it \
		--network=host \
		--volume="$(WD)/home-live:/home/code" \
		--volume="$(WD)/../live:/data/live" \
		--workdir="/data/live" \
		-u `id -u ${USER}`:`id -g ${USER}` \

# Command for running VSCode server
DOCKER_VSCS = docker run --rm -it \
		--network=host \
		--volume="${VSCS_HOME}:/home/code" \
		--volume="${CODE_PROJECT}:/data/docs_src" \
		--volume="${OUT_LOCATION}${OUT_NAME}:/data/docs_out" \
		-u `id -u ${USER}`:`id -g ${USER}` \

# Run interactively
.PHONY: run
run:
		$(DOCKER_RUN) \
		devdoc-swissknife:22.04 \
		${RUN}

# Run make
.PHONY: make
make:
		$(DOCKER_MAKE) \
		devdoc-swissknife:22.04 \
		make ${TARGET}

# Run simple live server
# Live server
# - hosts docs so they can be accessed via HTTP
# - checks for new docs versions on git repo and refreshes docs as necessary
# NOTE: configuration and temporary data for server resides in `live` folder
#       of this repo
.PHONY: live
live:
		$(DOCKER_LIVE) \
		devdoc-swissknife:22.04 \
		/bin/bash -c ./build_loop.sh

# Run interactively in live server environment
# (used to debug live server)
.PHONY: live-dev
live-dev:
		$(DOCKER_LIVE) \
		devdoc-swissknife:22.04 \
		/bin/bash

# Run VSCode server
.PHONY: vscs
vscs:
		$(DOCKER_VSCS) \
		devdoc-swissknife:22.04 \
		code-server
