#!/bin/sh

macro() {
    echo $(pwd) > ~/tmp.txt
}

polo() {
    cd $(cat ~/tmp.txt)
    rm ~/tmp.txt
}