fastlane documentation
================
# Installation

Make sure you have the latest version of the Xcode command line tools installed:

```
xcode-select --install
```

Install _fastlane_ using
```
[sudo] gem install fastlane -NV
```
or alternatively using `brew cask install fastlane`

# Available Actions
## iOS
### ios unit_test
```
fastlane ios unit_test
```
Run unit tests
### ios unit_test_on_device
```
fastlane ios unit_test_on_device
```
Run unit tests on device specified by IPHONE_DEVICE_ID environment variable
### ios integration_test
```
fastlane ios integration_test
```
Run integration tests
### ios integration_test_on_device
```
fastlane ios integration_test_on_device
```
Run integration tests on device specified by IPHONE_DEVICE_ID environment variable
### ios analyze
```
fastlane ios analyze
```
Run static analysis

----

This README.md is auto-generated and will be re-generated every time [fastlane](https://fastlane.tools) is run.
More information about fastlane can be found on [fastlane.tools](https://fastlane.tools).
The documentation of fastlane can be found on [docs.fastlane.tools](https://docs.fastlane.tools).
