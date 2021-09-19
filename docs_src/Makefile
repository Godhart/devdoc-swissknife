all:
	rm -f \"`cat _bookdown.yml | grep -Po 'book_filename: "\K[^"#]*' | xargs`.Rmd\" &&\
	rm -rf generated &&\
	mkdir generated &&\
	rm -rf _book &&\
	BOOKDOWN_FULL_PDF=false Rscript --quiet _render.R &&\
	rm -rf ../out/* &&\
	touch ../out/.keep &&\
	mv -f _book/* ../out/ &&\
	rm -rf _book
