_E		?= default.env-

include $(_E)

default: all

# Get hash for monitored repo branch.
# In case if hash changed rebuild would start
REPO_HASH_X	= $(shell git ls-remote $(REPO_PATH).git refs/heads/$(REPO_BRANCH))
REPO_HASH   = $(shell echo $(REPO_HASH_X) | grep -oP '^.[^ ]+')

# Check env to be sure of what's going on
.PHONY: show-env
show-env:
	@env
	@echo REPO_HASH=$(REPO_HASH)

# Make folder to store docs context
# - current content of repo branch
# - misc make related marks
$(SITE_CONTEXT)/.x:
	mkdir -p $(SITE_CONTEXT)
	touch $(SITE_CONTEXT)/.x

# When site context is changed - update vital make related marks
# to cause rebuild
$(SITE_CONTEXT)/$(REPO_HASH).info: $(SITE_CONTEXT)/.x
	rm -f $(SITE_CONTEXT)/*.info
	rm -f $(SITE_PATH)/.ok
	touch $(SITE_CONTEXT)/$(REPO_HASH).info

# Rebuild site context
# - get fresh files from monitored repo branch
# - invoke make to build docs
$(SITE_CONTEXT)/$(REPO_DATA)/.x: $(SITE_CONTEXT)/$(REPO_HASH).info
	rm -rf $(SITE_CONTEXT)/$(REPO_NAME)-*
	curl -L $(REPO_PATH)/archive/refs/heads/$(REPO_BRANCH).zip \
	| bsdtar -xvf - -C $(SITE_CONTEXT)
	touch $(SITE_CONTEXT)/$(REPO_DATA)/.x
	cd $(SITE_CONTEXT)/$(REPO_DATA)/$(MAKE_PATH) && _E=../default.env $(MAKE) $(MAKE_TARGET)
	touch $(SITE_CONTEXT)/$(REPO_DATA)/.ok

# When docs are sucessfully built - refresh web section
# NOTE: in case if build failed
# - web content isn't changed
# - next build will be only when
#   - branch on repo is updated
#   - forced to do so (make remake)
$(SITE_PATH)/.ok: $(SITE_CONTEXT)/$(REPO_DATA)/.x $(SITE_CONTEXT)/$(REPO_DATA)/.ok
	rm -rf $(SITE_PATH)
	mkdir -p $(SITE_PATH)
	cp -r $(SITE_CONTEXT)/$(REPO_DATA)/$(BUILD_PATH)/* $(SITE_PATH)
	touch $(SITE_PATH)/.ok

# Update web content if it's not up to date
web: $(SITE_PATH)/.ok

all: web

# Removes make marks so next time make would do fresh build
.PHONY: remake
remake:
	rm -f $(SITE_CONTEXT)/*.info

# Cleanup site context
# (mostly contains data files from repo and some build marks)
.PHONY: clean-context
clean-context:
	rm -rf $(SITE_CONTEXT)

# Cleanup web content
.PHONY: clean-web
clean-web:
	rm -rf $(SITE_PATH)

clean-all: clean-context clean-web

# Clean all derivative files
.PHONY: purge
purge:
	rm -rf .context
	rm -rf .web

# Run live server
.PHONY: webserver
webserver:
	cd .web && python3 -m http.server $(WEBSERVER_PORT)
