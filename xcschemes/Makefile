release:
	./generate-project.rb -c library
	xcodebuild -project UnityAdsStaticLibrary.xcodeproj -configuration Release > /dev/null

zip: release
	cd build/Release-iphoneos && zip -9r builds.zip UnityAds.framework
	mv build/Release-iphoneos/builds.zip .