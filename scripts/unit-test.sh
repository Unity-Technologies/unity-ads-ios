set -o xtrace
# Unit Test

echo $SIMULATOR_ID
open -b com.apple.iphonesimulator --args -CurrentDeviceUDID $SIMULATOR_ID
set -o pipefail
./generate-project.rb -c dev
ruby set_properties_for_testing.rb -s unity-ads-test-server.unityads.unity3d.com
# fastlane gym --scheme "UnityAds" --configuration "Debug" --export_method "development" --clean
bundle exec fastlane scan --scheme "UnityAds" --code_coverage --project UnityAds.xcodeproj
# xcodebuild -project UnityAds.xcodeproj -enableCodeCoverage YES -configuration Debug -scheme UnityAds -sdk iphonesimulator -destination "platform=iOS Simulator,name=iPhone 8,OS=11.4" clean build test
