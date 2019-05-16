#!/bin/bash

set -e
set -v
set -x

if [ -z "$TRAVIS_TAG" ]; then
  echo "Not a tag, skipping building Release framework";
else
  make release
fi

