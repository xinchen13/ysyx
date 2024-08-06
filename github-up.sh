#!/bin/bash
source tenv

if [ $# -eq 0 ]; then
  echo "offer commit message!"
  exit 1
fi

commit_message="$1"

git add .

git commit -m "$commit_message" --allow-empty

git push xinchen --all