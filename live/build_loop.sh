#!/bin/bash

# Every .env file in this folder defines one web section
# - which repo and branch to monitor
# - make setttings
# - where to place result

while [ 1 ]
do
    date
    for file in *.env; do
        echo $file
        _E=$file make all
    done
    sleep 60
done
