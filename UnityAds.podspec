Pod::Spec.new do |s|
  s.name = 'UnityAds'
  s.version = '3.4.8'
  s.license = { :type => 'Apache License, Version 2.0', :file => 'LICENSE' }
  s.author = { 'UnityAds' => 'itunes@unity3d.com' }
  s.homepage = 'https://unity3d.com/services/ads'
  s.summary = 'Monetize your entire player base and reach new audiences with video ads.'
  s.platform = :ios
  s.source = { :http => 'https://github.com/Unity-Technologies/unity-ads-ios/releases/download/3.4.8/UnityAds.framework.zip' }
  s.ios.deployment_target = '9.0'
  s.ios.vendored_frameworks = 'UnityAds.framework'  
  s.ios.xcconfig = { 'OTHER_LDFLAGS' => '-framework UnityAds' }
  
end
