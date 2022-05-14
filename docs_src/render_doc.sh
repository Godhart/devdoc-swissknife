#!/bin/bash

# TODO: get output dir from env
# TODO: don't polute sources dir
# TODO: into make via include
# TODO: split into stages - clean, make, publish

rm -f \"`cat _bookdown.yml | grep -Po 'book_filename: "\K[^"#]*' | xargs`.Rmd\" &&\
rm -rf generated &&\
mkdir generated &&\
rm -rf .book &&\
BOOKDOWN_FULL_PDF=false Rscript --quiet ../_render.R &&\
rm -rf ../../docs_out/$1 &&\
mkdir ../../docs_out/$1 &&\
mv -f .book/* ../../docs_out/$1 &&\
rm -rf .book
