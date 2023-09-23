#!/bin/bash -e

GIT_STATUS=$(git status --porcelain)
if [ -n "$GIT_STATUS" ]; then
    echo 'There are uncommited changes'
    exit 1
fi

SOURCE_DATE_EPOCH=$(git log -n 1 "--pretty=format:%ct")
SOURCE_HASH=$(git log -n 1 "--pretty=format:%H")

TAG_NAME=$(date --utc "--date=@${SOURCE_DATE_EPOCH}" '+v%Y.%m.%d')
echo "Package version: ${TAG_NAME}, source hash: ${SOURCE_HASH}"

git tag -a -m "Package version" ${TAG_NAME} ${SOURCE_HASH}
