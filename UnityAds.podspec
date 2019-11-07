Pod::Spec.new do |s|
  s.name = 'UnityAds'
  s.version = '3.3.0'
  s.license = { :type => 'Apache License, Version 2.0'}
  s.author = { 'UnityAds' => 'itunes@unity3d.com' }
  s.homepage = 'https://unity3d.com/services/ads'
  s.summary = 'Monetize your entire player base and reach new audiences with video ads.'
  s.platform = :ios
  s.source = { :http => 'https://github.com/Unity-Technologies/unity-ads-ios/releases/download/3.3.0/UnityAds.framework.zip' }
  s.ios.deployment_target = '7.0'
  s.ios.vendored_frameworks = 'UnityAds.framework'  
  s.ios.xcconfig = { 'OTHER_LDFLAGS' => '-framework UnityAds' }
  
end
