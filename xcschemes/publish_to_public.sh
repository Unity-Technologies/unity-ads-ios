#!/bin/bash

set -e
set -v
set -x

PUBLIC_REPO_NAME=unity-ads-ios
PUBLIC_REPO_OWNER=Unity-Technologies

if [ -z "$TRAVIS_TAG" ]; then
  echo "Not a tag, skipping publishing";
else

  if [ -z "$GITHUB_RELEASE_TOKEN" ]; then
    echo "No GITHUB_RELEASE_TOKEN set, skipping publishing"
    exit 1
  fi

  echo "Doing publish to public Github repository";
  git archive -o snapshot.zip -0 HEAD
  git clone https://${GITHUB_RELEASE_TOKEN}@github.com/${PUBLIC_REPO_OWNER}/${PUBLIC_REPO_NAME}

  # delete everything except .git and other hidden files
  rm -rf ${PUBLIC_REPO_NAME}/*

  unzip -o snapshot.zip -d ${PUBLIC_REPO_NAME}
  cp public_README.md ${PUBLIC_REPO_NAME}/README.md

  # remove files that should not be public
  cd ${PUBLIC_REPO_NAME}
  rm public_README.md
  rm .travis.yml
  rm .slather.yml
  rm print-changelog.sh
  rm publish_to_public.sh
  rm update_release_notes.sh
  rm build_release_if_tagged.sh

  # setup git and create a tagged commit of the source code snapshot
  git config user.email "travis@foo.unity3d.com"
  git config user.name "Unity Ads Travis"
  git add -A
  git commit -m "Release ${TRAVIS_TAG}"
  git tag $TRAVIS_TAG
  git push
  git push --tags

  # move back to private repo
  cd ..

  sleep 5  # Waits 5 seconds for Github to set tag, otherwise the release will fail

  # push a Github release to public repo
  RESPONSE=$(curl -H "Content-Type: application/json" \
     -H "Authorization: token ${GITHUB_RELEASE_TOKEN}" \
     -X POST -d "{\"tag_name\":\"${TRAVIS_TAG}\",\"name\":\"Unity Ads ${TRAVIS_TAG}\"}" \
     https://api.github.com/repos/${PUBLIC_REPO_OWNER}/${PUBLIC_REPO_NAME}/releases)

  echo $RESPONSE

  UPLOAD_URL=$(echo $RESPONSE | jq .upload_url | tr -d '"')

  # prepare the upload url from the upload template url
  TEMPLATE_SUFFIX={?name,label}
  BASE_UPLOAD_URL="${UPLOAD_URL%$TEMPLATE_SUFFIX}"

  # upload the install package as asset to Github release
  curl --verbose -H "Content-Type: application/zip" \
       -H "Authorization: token ${GITHUB_RELEASE_TOKEN}" \
       -X POST --data-binary @build/Release-iphoneos/UnityAds.framework.zip "${BASE_UPLOAD_URL}?name=UnityAds.framework.zip"

fi
