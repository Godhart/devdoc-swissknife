## Build the docs using all own's services (Kroki etc.)
#  (service is started locally and is running only while build lasts)

default: refresh-all

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

# Build the docs and clean the mess after build
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

# Cleanup temporary, cache files and build output
.PHONY: clean-all
clean-all:
	docker-compose run \
		-u code \
		-w /data/docs_src \
		--entrypoint "" \
		devdoc-swissknife \
		make clean-all

# Cleanup temporary and cache files only
.PHONY: clean-tmp
clean-tmp:
	docker-compose run \
		-u code \
		-w /data/docs_src \
		--entrypoint "" \
		devdoc-swissknife \
		make clean-tmp

# Clean temporary files that are created when previewing
# from VSCode
.PHONY: clean-preview
clean-preview:
	docker-compose run \
		-u code \
		-w /data/docs_src \
		--entrypoint "" \
		devdoc-swissknife \
		make clean-preview

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

# I'm feeling lucky.
# Update all docs from the scratch, published them
# and clean all intermedeiate files
all: refresh-all publish-all clean-all
