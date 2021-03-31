release:
	./generate-project.rb -c library
	xcodebuild -project UnityAdsStaticLibrary.xcodeproj -configuration Release > /dev/null

zip: release
	cp LICENSE build/Release-iphoneos/
	cd build/Release-iphoneos && zip -9r builds.zip UnityAds.framework LICENSE
	mv build/Release-iphoneos/builds.zip ./UnityAds.zip

verify-release-build:
	if [[ -f "UnityAds.zip" ]]; then \
		echo 'UnityAds.zip exists'; \
	else \
		echo 'UnityAds.zip does not exist'; \
		exit 1; \
	fi;

setup:
	./scripts/setup.sh

project:
	./generate-project.rb
	bundle exec fastlane provision_example_app

generate-mute-detection-header:
	./create-mute-header.sh MuteSwitchDetection.aiff
