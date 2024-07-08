#!/usr/bin/env bash

count=1
echo "" > test.log

while true 
do
    ./bugbash.sh >> test.log
    if [[ $? -ne 0 ]]; then
        echo "failed after $count times" &>> test.log
        cat test.log
        break
    fi
    ((count++))
done