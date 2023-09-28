Pod::Spec.new do |s|
  s.name = 'UnityAds'
  s.version = '4.9.0'
  s.license = { :type => 'Unity License', :file => 'LICENSE' }
  s.author = { 'UnityAds' => 'itunes@unity3d.com' }
  s.homepage = 'https://unity3d.com/services/ads'
  s.summary = 'Monetize your entire player base and reach new audiences with video ads.'
  s.platform = :ios
  s.source = { :http => 'https://github.com/Unity-Technologies/unity-ads-ios/releases/download/4.9.0/UnityAds.zip' }
  s.ios.deployment_target = '9.0'
  s.ios.vendored_frameworks = 'UnityAds.xcframework'
  s.swift_version = '5.0'
end
