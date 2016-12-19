release:
	./build-framework.sh -c RELEASE

zip: release
	cd build/Release-iphoneos && zip -9r builds.zip UnityAds.framework
	mv build/Release-iphoneos/builds.zip .