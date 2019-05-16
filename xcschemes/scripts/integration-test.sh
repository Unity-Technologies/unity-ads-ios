# Integration Test
echo $SIMULATOR_ID
open -b com.apple.iphonesimulator --args -CurrentDeviceUDID $SIMULATOR_ID
set -o pipefail
./generate-project.rb -c dev
ruby set_properties_for_testing.rb -s unity-ads-test-server.unityads.unity3d.com
fastlane scan --scheme "UnityAdsIntegrationTests" --code_coverage --project UnityAds.xcodeproj