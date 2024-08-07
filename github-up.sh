#!/bin/bash
source tenv

current_branch=$(git symbolic-ref --short HEAD)
git fetch --all

for remote_branch in `git branch -r | grep xinchen | grep -v HEAD`; do
    local_branch=${remote_branch#xinchen/}
    if [ -z "$(git branch --list $local_branch)" ]; then
        git branch --track $local_branch $remote_branch
    else
        echo "Local branch $local_branch is already tracking a remote branch. Skipping."
    fi
    git checkout $local_branch
    git pull xinchen $local_branch
done

git checkout "$current_branch"