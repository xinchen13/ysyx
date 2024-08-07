#!/bin/bash
source tenv

for branch in `git branch -a | grep remotes | grep -v HEAD | grep -v master `; do
    git branch --track ${branch#remotes/xinchen/} $branch
done

git pull --all
