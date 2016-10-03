#!/bin/bash

set -e
set -v
set -x

if [ -z "$TRAVIS_TAG" ]; then
  echo "Not a tag, skipping release description updating";
else
  echo "Updating description of Github release";

  RESPONSE=$(curl -H "Authorization: token ${GITHUB_RELEASE_TOKEN}" https://api.github.com/repos/Applifier/unity-ads-ios/releases)

  echo $RESPONSE

  RELEASE_URL=$(echo $RESPONSE | jq ".[] | select(.tag_name == \"${TRAVIS_TAG}\") | .url" | tr -d '"')

  RELEASE_NOTES=$(./print-changelog.sh)

  curl -H "Authorization: token ${GITHUB_RELEASE_TOKEN}" --request PATCH ${RELEASE_URL} --data "{ \"body\": \"${RELEASE_NOTES//$'\n'/$'\\n'}\" }"
fi
