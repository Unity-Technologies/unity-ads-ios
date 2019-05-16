# unity-ads-ios

[![Build Status](https://magnum.travis-ci.com/Applifier/unity-ads-ios.svg?token=rfESq21CCtaWmssfAxQc&branch=master)](https://magnum.travis-ci.com/Applifier/unity-ads-ios)
[![Coverage Status](https://coveralls.io/repos/github/Applifier/unity-ads-ios/badge.svg?branch=master&t=LX7D3s)](https://coveralls.io/github/Applifier/unity-ads-ios?branch=master)

# Unity Ads 2.0 iOS repo


To Build
----------
#### Pre Requirements
Install xcodeproj
```bash
gem install bundler
bundler install
```

To Generate the project file for development
-----------------------------

```bash
./generate-project.rb -c dev
```

Optionally, the same script can be used to generate project files with custom targets for the test and example app targets. To use the script to generate the hybrid test project, for example, use the script like:

```bash
./generate-project.rb -c dev -t UnityAdsHybridTests -e UnityAdsHybridTestsExample
```

Or to generate the project that the framework is built from

```bash
./generate-project.rb -c library
```

Build the static framework
----------------------------
```bash
make release
```

To Run tests
------------------------
```bash
xcodebuild -project UnityAds.xcodeproj -configuration Debug -scheme UnityAds -sdk iphonesimulator -destination "platform=iOS Simulator,OS=9.3,name=iPhone 6" test
```

Target non-release webview branch
---------------

To target a webview other than the production version for a particular SDK version, add a string value to the Info.plist of a hosting app for key UADSWebviewBranch.

Releasing
----------------

Step 1. Make a staged commit by removing ./publish_to_public.sh from the end of .travis.yml

Step 2. Tag the release, push tag to internal repository, Travis will automatically publish a release in internal repository under the releases tab

Step 3. Final testing with QA

Step 4. Add ./publish_to_public.sh back to .travis.yml, re-tag the release and push tag

Updating staged binaries
------------------------

If issues are found during testing or other changes need to be made before pushing the release to public repository, you need to update the staged binaries.

Step 1. Delete the release from internal repository

Step 2. Continue with release steps 2 and 3
