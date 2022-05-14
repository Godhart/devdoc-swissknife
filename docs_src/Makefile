# NOTE: it's could be ugly but does the job

all: doc-template en ru

####################################################
# Template for including new doc into Makefile
# Replace 'doc-<subject>' with location of your docs
####
# .PHONY: doc-<subject>
# devdoc-swissknife-ru:
# 	cd doc-<subject> && $(MAKE) all

.PHONY: devdoc-swissknife-en
devdoc-swissknife-en:
	cd devdoc-swissknife-en && $(MAKE) all

.PHONY: devdoc-swissknife-ru
devdoc-swissknife-ru:
	cd devdoc-swissknife-ru && $(MAKE) all

.PHONY: doc-template
doc-template:
	cd doc-template && $(MAKE) all

en: devdoc-swissknife-en

ru: devdoc-swissknife-ru

clean-all:
	cd devdoc-swissknife-en && $(MAKE) clean-all
	cd devdoc-swissknife-ru && $(MAKE) clean-all
	cd doc-template && $(MAKE) clean-all
