default: docs-all

# Build the docs reusing already rendered diagrams
.PHONY: docs-all
docs-all:
	docker-compose run \
		-u code \
		-w /data/docs_src \
		--entrypoint "" \
		devdoc-swissknife \
		make all

# Build the docs generating diagrams from scratch
.PHONY: pure-all
pure-all:
	docker-compose run \
		-u code \
		-w /data/docs_src \
		--entrypoint "" \
		devdoc-swissknife \
		make pure-all

# Build the docs and clean the mess
.PHONY: refresh-all
refresh-all:
	docker-compose run \
		-u code \
		-w /data/docs_src \
		--entrypoint "" \
		devdoc-swissknife \
		make refresh-all

# Run bash
.PHONY: run
run:
	docker-compose run \
		-u code \
		-w /data/docs_src \
		--entrypoint "" \
		devdoc-swissknife \
		/bin/bash

# Cleanup
.PHONY: clean-all
clean-all:
	docker-compose run \
		-u code \
		-w /data/docs_src \
		--entrypoint "" \
		devdoc-swissknife \
		make clean-all

# Cleanup published docs
.PHONY: clean-publish-en
clean-publish-en:
	rm -rf docs/devdoc-swissknife-en

.PHONY: clean-publish-ru
clean-publish-ru:
	rm -rf docs/devdoc-swissknife-ru

clean-publish-all: clean-publish-en clean-publish-ru

# Move the docs to published folder
.PHONY: publish-en
publish-en: clean-publish-en
	cp -r docs_out/devdoc-swissknife-en docs/devdoc-swissknife-en

.PHONY: publish-ru
publish-ru: clean-publish-ru
	cp -r docs_out/devdoc-swissknife-ru docs/devdoc-swissknife-ru

publish-all: publish-en publish-ru
