release:
	./generate-project.rb -c library
	xcodebuild -project UnityAdsStaticLibrary.xcodeproj -configuration Release > /dev/null

zip: release
	cd build/Release-iphoneos && zip -9r builds.zip UnityAds.framework
	mv build/Release-iphoneos/builds.zip ./UnityAds.framework.zip

verify-release-build:
	if [[ -f "UnityAds.framework.zip" ]]; then \
		echo 'UnityAds.framework.zip exists'; \
	else \
		echo 'UnityAds.framework.zip does not exist'; \
		exit 1; \
	fi;

setup:
	./scripts/setup.sh

project:
	./generate-project.rb
	bundle exec fastlane provision_example_app
