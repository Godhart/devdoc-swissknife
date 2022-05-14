#!/bin/bash

while [ 1 ]
do
    date
    for file in *.env; do
        echo $file
        _E=$file make all
    done
    sleep 60
done
