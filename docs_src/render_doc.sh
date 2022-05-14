#!/bin/bash

rm -f \"`cat _bookdown.yml | grep -Po 'book_filename: "\K[^"#]*' | xargs`.Rmd\" &&\
rm -rf generated &&\
mkdir generated &&\
rm -rf .book &&\
BOOKDOWN_FULL_PDF=false Rscript --quiet ../_render.R &&\
rm -rf ../../docs_out/$1 &&\
mkdir ../../docs_out/$1 &&\
mv -f .book/* ../../docs_out/$1 &&\
rm -rf .book
