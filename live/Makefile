_E		?= default.env-

include $(_E)

default: all

REPO_HASH_X	= $(shell git ls-remote $(REPO_PATH).git refs/heads/$(REPO_BRANCH))
REPO_HASH   = $(shell echo $(REPO_HASH_X) | grep -oP '^.[^ ]+')

.PHONY: show-env
show-env:
	@env
	@echo REPO_HASH=$(REPO_HASH)

$(SITE_CONTEXT)/.x:
	mkdir -p $(SITE_CONTEXT)
	touch $(SITE_CONTEXT)/.x

$(SITE_CONTEXT)/$(REPO_HASH).info: $(SITE_CONTEXT)/.x
	rm -f $(SITE_CONTEXT)/*.info
	rm -f $(SITE_PATH)/.ok
	touch $(SITE_CONTEXT)/$(REPO_HASH).info

$(SITE_CONTEXT)/$(REPO_DATA)/.x: $(SITE_CONTEXT)/$(REPO_HASH).info
	rm -rf $(SITE_CONTEXT)/$(REPO_NAME)-*
	curl -L $(REPO_PATH)/archive/refs/heads/$(REPO_BRANCH).zip \
	| bsdtar -xvf - -C $(SITE_CONTEXT)
	touch $(SITE_CONTEXT)/$(REPO_DATA)/.x
	cd $(SITE_CONTEXT)/$(REPO_DATA)/$(MAKE_PATH) && _E=../default.env $(MAKE) $(MAKE_TARGET)
	touch $(SITE_CONTEXT)/$(REPO_DATA)/.ok

$(SITE_PATH)/.ok: $(SITE_CONTEXT)/$(REPO_DATA)/.x $(SITE_CONTEXT)/$(REPO_DATA)/.ok
	rm -rf $(SITE_PATH)
	mkdir -p $(SITE_PATH)
	cp -r $(SITE_CONTEXT)/$(REPO_DATA)/$(BUILD_PATH)/* $(SITE_PATH)
	touch $(SITE_PATH)/.ok

web: $(SITE_PATH)/.ok

all: web

.PHONY: remake
remake:
	rm -f $(SITE_CONTEXT)/*.info

.PHONY: clean-context
clean-context:
	rm -rf $(SITE_CONTEXT)

.PHONY: clean-web
clean-web:
	rm -rf $(SITE_PATH)

clean-all: clean-context clean-web

.PHONY: purge
purge:
	rm -rf .context
	rm -rf .web

.PHONY: webserver
webserver:
	cd .web && python3 -m http.server $(WEBSERVER_PORT)
