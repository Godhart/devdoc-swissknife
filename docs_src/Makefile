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
	cd devdoc-swissknife-en && LANG=en_US.UTF-8 LANGUAGE=en_US $(MAKE) all

.PHONY: devdoc-swissknife-ru
devdoc-swissknife-ru:
	cd devdoc-swissknife-ru && LANG=ru_RU.UTF-8 LANGUAGE=ru_RU $(MAKE) all

.PHONY: doc-template
doc-template:
	cd doc-template && LANG=en_US.UTF-8 LANGUAGE=en_US $(MAKE) all

en: devdoc-swissknife-en

ru: devdoc-swissknife-ru

.PHONY: clean-all
clean-all:
	cd devdoc-swissknife-en && $(MAKE) clean-all
	cd devdoc-swissknife-ru && $(MAKE) clean-all
	cd doc-template && $(MAKE) clean-all

.PHONY: pure-all
pure-all:
	cd devdoc-swissknife-en && $(MAKE) pure
	cd devdoc-swissknife-ru && $(MAKE) pure
	cd doc-template && $(MAKE) pure

.PHONY: refresh-all
refresh-all:
	cd devdoc-swissknife-en && $(MAKE) refresh
	cd devdoc-swissknife-ru && $(MAKE) refresh
	cd doc-template && $(MAKE) refresh

.PHONY: show-locale-en
show-locale-en:
	cd devdoc-swissknife-en && LANG=en_US.UTF-8 LANGUAGE=en_US $(MAKE) show-locale

.PHONY: show-locale-ru
show-locale-ru:
	cd devdoc-swissknife-ru && LANG=ru_RU.UTF-8 LANGUAGE=ru_RU $(MAKE) show-locale
