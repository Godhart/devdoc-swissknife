# NOTE: it's ugly :( but works. Just don't look at this now
all: doc-template devdoc-swissknife-lobby devdoc-swissknife-en devdoc-swissknife-ru

.PHONY: devdoc-swissknife-lobby
devdoc-swissknife-lobby:
	cd devdoc-swissknife-lobby &&\
	bash ../render_doc.sh devdoc-swissknife-lobby &&\
	cd ..

.PHONY: devdoc-swissknife-en
devdoc-swissknife-en:
	cd devdoc-swissknife-en &&\
	bash ../render_doc.sh devdoc-swissknife-en &&\
	cd ..

.PHONY: devdoc-swissknife-ru
devdoc-swissknife-ru:
	cd devdoc-swissknife-ru &&\
	bash ../render_doc.sh devdoc-swissknife-ru &&\
	cd ..

.PHONY: doc-template
doc-template:
	cd doc-template &&\
	bash ../render_doc.sh doc-template &&\
	cd ..
