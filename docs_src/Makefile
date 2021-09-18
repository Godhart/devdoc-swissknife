all:
	rm -rf _book &&\
	BOOKDOWN_FULL_PDF=false Rscript --quiet _render.R &&\
	rm -rf ../out/* &&\
	touch ../out/.keep &&\
	mv -f _book/* ../out/ &&\
	rm -rf _book
