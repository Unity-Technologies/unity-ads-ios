#import "UADSDeviceInfoReader.h"
#import "USRVClientProperties.h"
#import "USRVDevice.h"
#import "USRVSdkProperties.h"
#import "USRVConnectivityUtils.h"
#import "NSMutableDictionary + SafeOperations.h"
#import "USRVTrackingManagerProxy.h"
#import "UADSTools.h"
#import "UADSDeviceInfoReaderKeys.h"
#import "NSBundle + TypecastGet.h"
#import "UADSJsonStorageKeyNames.h"

@interface UADSDeviceInfoReaderBase ()
@property (nonatomic, strong) id<UADSDeviceIDFIReader, UADSAnalyticValuesReader, UADSInitializationTimeStampReader>userDefaultsReader;
@end

@implementation UADSDeviceInfoReaderBase
+ (id<UADSDeviceInfoReader>)newWithIDFIReader: (id<UADSDeviceIDFIReader, UADSAnalyticValuesReader, UADSInitializationTimeStampReader>)idfiReader {
    UADSDeviceInfoReaderBase *base = [UADSDeviceInfoReaderBase new];

    base.userDefaultsReader = idfiReader;
    return base;
}

- (nonnull NSDictionary *)getDeviceInfoForGameMode: (UADSGameMode)mode {
    NSMutableDictionary *mDictionary = [NSMutableDictionary dictionaryWithDictionary: self.defaultInfo];

    return mDictionary;
}

- (NSDictionary *)defaultInfo {
    NSMutableDictionary *info = [NSMutableDictionary new];

    [info uads_setValueIfNotNil: [USRVClientProperties getAppName]
                         forKey: kUADSDeviceInfoReaderBundleIDKey];

    [info uads_setValueIfNotNil: [USRVConnectivityUtils getNetworkStatusString]
                         forKey: kUADSDeviceInfoReaderConnectionTypeKey];

    [info uads_setValueIfNotNil: @([USRVConnectivityUtils getNetworkType])
                         forKey: kUADSDeviceInfoReaderNetworkTypeKey];

    [info uads_setValueIfNotNil: [USRVDevice getScreenHeight]
                         forKey: kUADSDeviceInfoReaderScreenHeightKey];

    [info uads_setValueIfNotNil: [USRVDevice getScreenWidth]
                         forKey: kUADSDeviceInfoReaderScreenWidthKey];

    [info uads_setValueIfNotNil: @([USRVClientProperties isAppDebuggable])
                         forKey: kUADSDeviceInfoReaderEncryptedKey];

    [info uads_setValueIfNotNil: @"ios"
                         forKey: kUADSDeviceInfoReaderPlatformKey];

    [info uads_setValueIfNotNil: @([USRVDevice isRooted])
                         forKey: kUADSDeviceInfoReaderRootedKey];

    [info uads_setValueIfNotNil: @([USRVSdkProperties getVersionCode])
                         forKey: kUADSDeviceInfoReaderSDKVersionKey];

    [info uads_setValueIfNotNil: [USRVDevice getOsVersion]
                         forKey: kUADSDeviceInfoReaderOSVersionKey];

    [info uads_setValueIfNotNil: [USRVDevice getModel]
                         forKey: kUADSDeviceInfoReaderDeviceModelKey];

    [info uads_setValueIfNotNil: [USRVDevice getPreferredLocalization]
                         forKey: kUADSDeviceInfoReaderLanguageKey];

    [info uads_setValueIfNotNil:  @([USRVSdkProperties isTestMode])
                         forKey: kUADSDeviceInfoReaderIsTestModeKey];

    [info uads_setValueIfNotNil: [USRVDevice getFreeMemoryInKilobytes]
                         forKey: kUADSDeviceInfoReaderFreeMemoryKey];

    [info uads_setValueIfNotNil: @([USRVDevice getBatteryStatus])
                         forKey: kUADSDeviceInfoReaderBatteryStatusKey];

    [info uads_setValueIfNotNil: @([USRVDevice getBatteryLevel])
                         forKey: kUADSDeviceInfoReaderBatteryLevelKey];

    [info uads_setValueIfNotNil: @([USRVDevice getScreenBrightness])
                         forKey: kUADSDeviceInfoReaderScreenBrightnessKey];

    [info uads_setValueIfNotNil: @([USRVDevice  getOutputVolume])
                         forKey: kUADSDeviceInfoReaderVolumeKey];

    [info uads_setValueIfNotNil: [USRVDevice  getFreeSpaceInKilobytes]
                         forKey: kUADSDeviceInfoDeviceFreeSpaceKey];

    [info uads_setValueIfNotNil: [USRVDevice  getTotalSpaceInKilobytes]
                         forKey: kUADSDeviceInfoDeviceTotalSpaceKey];

    [info uads_setValueIfNotNil: [USRVDevice  getTotalMemoryInKilobytes]
                         forKey: kUADSDeviceInfoDeviceTotalMemoryKey];

    [info uads_setValueIfNotNil: [USRVDevice getDeviceName]
                         forKey: kUADSDeviceInfoDeviceDeviceNameKey];

    [info uads_setValueIfNotNil: [[USRVDevice getLocaleList] componentsJoinedByString: @","]
                         forKey: kUADSDeviceInfoDeviceLocaleListKey];

    [info uads_setValueIfNotNil: [USRVDevice getCurrentUITheme]
                         forKey: kUADSDeviceInfoDeviceCurrentUiThemeKey];

    [info uads_setValueIfNotNil: [[USRVClientProperties getAdNetworkIdsPlist] componentsJoinedByString: @","]
                         forKey: kUADSDeviceInfoDeviceAdNetworkPlistKey];

    [info uads_setValueIfNotNil: [USRVClientProperties getAppVersion]
                         forKey: kUADSDeviceInfoReaderBundleVersionKey];

    [info uads_setValueIfNotNil: @([USRVDevice isWiredHeadsetOn])
                         forKey: kUADSDeviceInfoDeviceIsWiredHeadsetOnKey];


    [info uads_setValueIfNotNil: [USRVDevice getSystemBootTime]
                         forKey: kUADSDeviceInfoDeviceSystemBootTimeKey];

    [info uads_setValueIfNotNil: self.authTrackingStatus
                         forKey: kUADSDeviceInfoDeviceTrackingAuthStatusKey];

    [info uads_setValueIfNotNil: [USRVDevice getNetworkOperator]
                         forKey: kUADSDeviceInfoDeviceNetworkOperatorKey];

    [info uads_setValueIfNotNil: [USRVDevice getNetworkOperatorName]
                         forKey: kUADSDeviceInfoDeviceNetworkOperatorNameKey];

    [info uads_setValueIfNotNil: @([USRVDevice getScreenScale])
                         forKey: kUADSDeviceInfoDeviceScreenScaleKey];

    [info uads_setValueIfNotNil: @([USRVDevice isSimulator])
                         forKey: kUADSDeviceInfoIsSimulatorKey];

    [info uads_setValueIfNotNil: @([USRVDevice isLimitTrackingEnabled])
                         forKey: kUADSDeviceInfoLimitAdTrackingKey];

    [info uads_setValueIfNotNil: [USRVDevice getTimeZone: false]
                         forKey: kUADSDeviceInfoLimitTimeZoneKey];

    [info uads_setValueIfNotNil: @"apple"
                         forKey: kUADSDeviceInfoLimitStoresKey];

    [info uads_setValueIfNotNil: @([USRVDevice getCPUCount])
                         forKey: kUADSDeviceInfoCPUCountKey];

    [info uads_setValueIfNotNil: self.userDefaultsReader.idfi
                         forKey: kUADSDeviceInfoIDFIKey];

    [info uads_setValueIfNotNil: self.userDefaultsReader.sessionID
                         forKey: kUADSDeviceInfoAnalyticSessionIDKey];

    [info uads_setValueIfNotNil: self.userDefaultsReader.userID
                         forKey: kUADSDeviceInfoAnalyticUserIDKey];

    [info uads_setValueIfNotNil: @([USRVDevice getTimeZoneOffset])
                         forKey: kUADSDeviceInfoTimeZoneOffsetKey];
    dispatch_on_main_sync(^{
        [info uads_setValueIfNotNil: @([USRVDevice isAppInForeground])
                             forKey: kUADSDeviceInfoAppInForegroundKey];
    });

    [info uads_setValueIfNotNil: [USRVDevice currentTimeStampInSeconds]
                         forKey: kUADSDeviceInfoCurrentTimestampKey];

    [info uads_setValueIfNotNil: self.initializeTimestamp
                         forKey: kUADSDeviceInfoAppStartTimestampKey];


    [info uads_setValueIfNotNil: [NSBundle getBuiltSDKVersion]
                         forKey: kUADSDeviceInfoBuiltSDKVersionKey];


    //for now webview doesnt set those values. need the next set to be able to
    // get proper configuration from the service

//    info[@"unifiedconfig.data.gameSessionId"] = @(1);
//    info[@"user.clickCount"] = @(1);
//    info[@"user.requestCount"] = @(1);
//    info[@"user.requestToReadyTime"] = @(10);

    dispatch_on_main_sync(^{
        [info uads_setValueIfNotNil: [USRVDevice getWebViewUserAgent]
                             forKey: kUADSDeviceInfoWebViewAgentKey];
    });

    return info;
}

- (NSNumber *)authTrackingStatus {
    return @([[USRVTrackingManagerProxy sharedInstance] trackingAuthorizationStatus]);
}

- (NSNumber *)initializeTimestamp {
    return @(self.userDefaultsReader.initializationStartTimeStamp.intValue);
}

@end
