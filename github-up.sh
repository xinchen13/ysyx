#!/bin/bash
source tenv

for remote_branch in `git branch -a | grep remotes | grep -v HEAD`; do
    local_branch=${remote_branch#remotes/xinchen/}
    if [ -z "$(git branch --list $local_branch)" ]; then
        git branch --track $local_branch $remote_branch
    else
        echo "Local branch $local_branch is already tracking a remote branch. Skipping."
    fi
done

git pull --all