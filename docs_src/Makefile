all: doc-template en ru

####################################################
# Template for including new doc into Makefile
# Replace 'doc-<subject>' with location of your docs
####
# .PHONY: doc-<subject>
# devdoc-swissknife-ru:
# 	cd doc-<subject> && LANG=xx_XX.UTF-8 LANGUAGE=xx_XX $(MAKE) all
# Then update clean-*, pure-all and refresh-all targets

# Build docs reusing already rendered diagrams
.PHONY: devdoc-swissknife-en
devdoc-swissknife-en:
	cd devdoc-swissknife-en && LANG=en_US.UTF-8 LANGUAGE=en_US $(MAKE) all

.PHONY: devdoc-swissknife-ru
devdoc-swissknife-ru:
	cd devdoc-swissknife-ru && LANG=ru_RU.UTF-8 LANGUAGE=ru_RU $(MAKE) all

.PHONY: doc-template
doc-template:
	cd doc-template && LANG=en_US.UTF-8 LANGUAGE=en_US $(MAKE) all

# Aliases to type less
en: devdoc-swissknife-en

ru: devdoc-swissknife-ru

# Rebuild docs from the scratch
.PHONY: pure-all
pure-all: clean-all doc-template en ru

# Rebuild docs from the scratch and clean intermediate files
.PHONY: refresh-all
refresh-all: pure-all clean-tmp

# Clean temporary and cache files
.PHONY: clean-tmp
clean-tmp:
	cd devdoc-swissknife-en && $(MAKE) clean-tmp
	cd devdoc-swissknife-ru && $(MAKE) clean-tmp
	cd doc-template && $(MAKE) clean-tmp

# Clean temporary, cache and build output
.PHONY: clean-all
clean-all:
	cd devdoc-swissknife-en && $(MAKE) clean-all
	cd devdoc-swissknife-ru && $(MAKE) clean-all
	cd doc-template && $(MAKE) clean-all

# Clean temporary files that are created when previewing
# from VSCode
.PHONY: clean-preview
clean-preview:
	cd devdoc-swissknife-en && $(MAKE) clean-preview
	cd devdoc-swissknife-ru && $(MAKE) clean-preview
	cd doc-template && $(MAKE) clean-preview

# Things to check if locale is set up right
.PHONY: show-locale-en
show-locale-en:
	cd devdoc-swissknife-en && LANG=en_US.UTF-8 LANGUAGE=en_US $(MAKE) show-locale

.PHONY: show-locale-ru
show-locale-ru:
	cd devdoc-swissknife-ru && LANG=ru_RU.UTF-8 LANGUAGE=ru_RU $(MAKE) show-locale
