#import "UADSDeviceInfoReader.h"
#import "USRVClientProperties.h"
#import "USRVDevice.h"
#import "USRVSdkProperties.h"
#import "USRVConnectivityUtils.h"
#import "NSMutableDictionary+SafeOperations.h"
#import "UADSTools.h"
#import "UADSDeviceInfoReaderKeys.h"
#import "NSBundle+TypecastGet.h"
#import "UADSJsonStorageKeyNames.h"
#import "UADSUserAgentStorage.h"


@interface UADSDeviceInfoReaderExtended ()
@property (nonatomic, strong) id<UADSAnalyticValuesReader, UADSInitializationTimeStampReader>userDefaultsReader;
@property (nonatomic, strong) id<UADSDeviceInfoReader>original;
@property (nonatomic, strong) id<UADSLogger> logger;
@property (nonatomic, strong) UADSUserAgentStorage *userAgentReader;
@end

@implementation UADSDeviceInfoReaderExtended
+ (id<UADSDeviceInfoReader>)newWithIDFIReader: (id<UADSAnalyticValuesReader, UADSInitializationTimeStampReader>)idfiReader
                                  andOriginal: (id<UADSDeviceInfoReader>)orignal
                                    andLogger: (id<UADSLogger>)logger {
    UADSDeviceInfoReaderExtended *base = [UADSDeviceInfoReaderExtended new];

    base.original = orignal;

    base.userDefaultsReader = idfiReader;
    base.logger = logger;
    base.userAgentReader = [UADSUserAgentStorage new];
    return base;
}

- (nonnull NSDictionary *)getDeviceInfoForGameMode: (UADSGameMode)mode {
    NSDictionary *baseInfo = [_original getDeviceInfoForGameMode: mode];

    return [self extendInfo: baseInfo];
}

- (NSDictionary *)extendInfo: (NSDictionary *)baseInfo {
    NSMutableDictionary *info = [[NSMutableDictionary alloc] initWithDictionary: baseInfo];



    [self measurePerformanceAndLog: @"getAppName"
                             using:^{
                                 [info uads_setValueIfNotNil: [USRVClientProperties getAppName]
                                                      forKey: kUADSDeviceInfoReaderBundleIDKey];
                             }];


    [self measurePerformanceAndLog: @"getNetworkStatusString"
                             using: ^{
                                 [info uads_setValueIfNotNil: [USRVConnectivityUtils getNetworkStatusString]
                                                      forKey: kUADSDeviceInfoReaderConnectionTypeKey];
                             }];


    [self measurePerformanceAndLog: @"getNetworkType"
                             using: ^{
                                 [info uads_setValueIfNotNil: @([USRVConnectivityUtils getNetworkType])
                                                      forKey: kUADSDeviceInfoReaderNetworkTypeKey];
                             }];



    [self measurePerformanceAndLog: @"getScreenHeight"
                             using: ^{
                                 [info uads_setValueIfNotNil: [USRVDevice getScreenHeight]
                                                      forKey: kUADSDeviceInfoReaderScreenHeightKey];
                             }];


    [self measurePerformanceAndLog: @"getScreenWidth"
                             using: ^{
                                 [info uads_setValueIfNotNil: [USRVDevice getScreenWidth]
                                                      forKey: kUADSDeviceInfoReaderScreenWidthKey];
                             }];


    [self measurePerformanceAndLog: @"isAppDebuggable"
                             using: ^{
                                 [info uads_setValueIfNotNil: @([USRVClientProperties isAppDebuggable])
                                                      forKey: kUADSDeviceInfoReaderEncryptedKey];
                             }];

    [self measurePerformanceAndLog: @"isRooted"
                             using: ^{
                                 [info uads_setValueIfNotNil: @([USRVDevice isRooted])
                                                      forKey: kUADSDeviceInfoReaderRootedKey];
                             }];

    [self measurePerformanceAndLog: @"getVersionCode"
                             using: ^{
                                 [info uads_setValueIfNotNil: @([USRVSdkProperties getVersionCode])
                                                      forKey: kUADSDeviceInfoReaderSDKVersionKey];
                             }];

    [self measurePerformanceAndLog: @"getOsVersion"
                             using: ^{
                                 [info uads_setValueIfNotNil: [USRVDevice getOsVersion]
                                                      forKey: kUADSDeviceInfoReaderOSVersionKey];
                             }];

    [self measurePerformanceAndLog: @"getModel"
                             using: ^{
                                 [info uads_setValueIfNotNil: [USRVDevice getModel]
                                                      forKey: kUADSDeviceInfoReaderDeviceModelKey];
                             }];

    [self measurePerformanceAndLog: @"getPreferredLocalization"
                             using: ^{
                                 [info uads_setValueIfNotNil: [USRVDevice getPreferredLocalization]
                                                      forKey: kUADSDeviceInfoReaderLanguageKey];
                             }];

    [self measurePerformanceAndLog: @"isTestMode"
                             using: ^{
                                 [info uads_setValueIfNotNil:  @([USRVSdkProperties isTestMode])
                                                      forKey: kUADSDeviceInfoReaderIsTestModeKey];
                             }];

    [self measurePerformanceAndLog: @"isTestMode"
                             using: ^{
                                 [info uads_setValueIfNotNil:  @([USRVSdkProperties isTestMode])
                                                      forKey: kUADSDeviceInfoReaderIsTestModeKey];
                             }];

    [self measurePerformanceAndLog: @"getFreeMemoryInKilobytes"
                             using: ^{
                                 [info uads_setValueIfNotNil: [USRVDevice getFreeMemoryInKilobytes]
                                                      forKey: kUADSDeviceInfoReaderFreeMemoryKey];
                             }];

    [self measurePerformanceAndLog: @"getBatteryStatus"
                             using: ^{
                                 [info uads_setValueIfNotNil: @([USRVDevice getBatteryStatus])
                                                      forKey: kUADSDeviceInfoReaderBatteryStatusKey];
                             }];

    [self measurePerformanceAndLog: @"getBatteryLevel"
                             using: ^{
                                 [info uads_setValueIfNotNil: @([USRVDevice getBatteryLevel])
                                                      forKey: kUADSDeviceInfoReaderBatteryLevelKey];
                             }];

    [self measurePerformanceAndLog: @"getScreenBrightness"
                             using: ^{
                                 [info uads_setValueIfNotNil: @([USRVDevice getScreenBrightness])
                                                      forKey: kUADSDeviceInfoReaderScreenBrightnessKey];
                             }];

    [self measurePerformanceAndLog: @"getOutputVolume"
                             using: ^{
                                 [info uads_setValueIfNotNil: @([USRVDevice  getOutputVolume])
                                                      forKey: kUADSDeviceInfoReaderVolumeKey];
                             }];

    [self measurePerformanceAndLog: @"getFreeSpaceInKilobytes"
                             using: ^{
                                 [info uads_setValueIfNotNil: [USRVDevice  getFreeSpaceInKilobytes]
                                                      forKey: kUADSDeviceInfoDeviceFreeSpaceKey];
                             }];


    [self measurePerformanceAndLog: @"getTotalSpaceInKilobytes"
                             using: ^{
                                 [info uads_setValueIfNotNil: [USRVDevice  getTotalSpaceInKilobytes]
                                                      forKey: kUADSDeviceInfoDeviceTotalSpaceKey];
                             }];

    [self measurePerformanceAndLog: @"getTotalMemoryInKilobytes"
                             using: ^{
                                 [info uads_setValueIfNotNil: [USRVDevice  getTotalMemoryInKilobytes]
                                                      forKey: kUADSDeviceInfoDeviceTotalMemoryKey];
                             }];

    [self measurePerformanceAndLog: @"getDeviceName"
                             using: ^{
                                 [info uads_setValueIfNotNil: [USRVDevice getDeviceName]
                                                      forKey: kUADSDeviceInfoDeviceDeviceNameKey];
                             }];


    [self measurePerformanceAndLog: @"getLocaleList"
                             using: ^{
                                 [info uads_setValueIfNotNil: [[USRVDevice getLocaleList] componentsJoinedByString: @","]
                                                      forKey: kUADSDeviceInfoDeviceLocaleListKey];
                             }];


    [self measurePerformanceAndLog: @"getCurrentUITheme"
                             using: ^{
                                 [info uads_setValueIfNotNil: [USRVDevice getCurrentUITheme]
                                                      forKey: kUADSDeviceInfoDeviceCurrentUiThemeKey];
                             }];

    [self measurePerformanceAndLog: @"getAdNetworkIdsPlist"
                             using: ^{
                                 [info uads_setValueIfNotNil: [[USRVClientProperties getAdNetworkIdsPlist] componentsJoinedByString: @","]
                                                      forKey: kUADSDeviceInfoDeviceAdNetworkPlistKey];
                             }];


    [self measurePerformanceAndLog: @"getAppVersion"
                             using: ^{
                                 [info uads_setValueIfNotNil: [USRVClientProperties getAppVersion]
                                                      forKey: kUADSDeviceInfoReaderBundleVersionKey];
                             }];

    [self measurePerformanceAndLog: @"isWiredHeadsetOn"
                             using: ^{
                                 [info uads_setValueIfNotNil: @([USRVDevice isWiredHeadsetOn])
                                                      forKey: kUADSDeviceInfoDeviceIsWiredHeadsetOnKey];
                             }];

    [self measurePerformanceAndLog: @"getSystemBootTime"
                             using: ^{
                                 [info uads_setValueIfNotNil: [USRVDevice getSystemBootTime]
                                                      forKey: kUADSDeviceInfoDeviceSystemBootTimeKey];
                             }];


    [self measurePerformanceAndLog: @"getNetworkOperator"
                             using: ^{
                                 [info uads_setValueIfNotNil: [USRVDevice getNetworkOperator]
                                                      forKey: kUADSDeviceInfoDeviceNetworkOperatorKey];
                             }];


    [self measurePerformanceAndLog: @"getNetworkOperatorName"
                             using: ^{
                                 [info uads_setValueIfNotNil: [USRVDevice getNetworkOperatorName]
                                                      forKey: kUADSDeviceInfoDeviceNetworkOperatorNameKey];
                             }];


    [self measurePerformanceAndLog: @"getScreenScale"
                             using: ^{
                                 [info uads_setValueIfNotNil: @([USRVDevice getScreenScale])
                                                      forKey: kUADSDeviceInfoDeviceScreenScaleKey];
                             }];

    [self measurePerformanceAndLog: @"isSimulator"
                             using: ^{
                                 [info uads_setValueIfNotNil: @([USRVDevice isSimulator])
                                                      forKey: kUADSDeviceInfoIsSimulatorKey];
                             }];

    [self measurePerformanceAndLog: @"getTimeZone"
                             using: ^{
                                 [info uads_setValueIfNotNil: [USRVDevice getTimeZone: false]
                                                      forKey: kUADSDeviceInfoLimitTimeZoneKey];
                             }];

    [self measurePerformanceAndLog: @"getCPUCount"
                             using: ^{
                                 [info uads_setValueIfNotNil: @([USRVDevice getCPUCount])
                                                      forKey: kUADSDeviceInfoCPUCountKey];
                             }];


    [info uads_setValueIfNotNil: @"apple"
                         forKey: kUADSDeviceInfoLimitStoresKey];


    [self measurePerformanceAndLog: @"sessionID"
                             using: ^{
                                 [info uads_setValueIfNotNil: self.userDefaultsReader.sessionID
                                                      forKey: kUADSDeviceInfoAnalyticSessionIDKey];
                             }];

    [self measurePerformanceAndLog: @"userID"
                             using: ^{
                                 [info uads_setValueIfNotNil: self.userDefaultsReader.userID
                                                      forKey: kUADSDeviceInfoAnalyticUserIDKey];
                             }];

    [self measurePerformanceAndLog: @"getTimeZoneOffset"
                             using: ^{
                                 [info uads_setValueIfNotNil: @([USRVDevice getTimeZoneOffset])
                                                      forKey: kUADSDeviceInfoTimeZoneOffsetKey];
                             }];

    [self measurePerformanceAndLog: @"isAppInForeground"
                             using: ^{
                                 dispatch_on_main_sync(^{
                                                           [info uads_setValueIfNotNil: @([USRVDevice isAppInForeground])
                                                                                forKey: kUADSDeviceInfoAppInForegroundKey];
                                                       });
                             }];


    [self measurePerformanceAndLog: @"currentTimeStampInSeconds"
                             using: ^{
                                 [info uads_setValueIfNotNil: [USRVDevice currentTimeStampInSeconds]
                                                      forKey: kUADSDeviceInfoCurrentTimestampKey];
                             }];

    [self measurePerformanceAndLog: @"initializeTimestamp"
                             using: ^{
                                 [info uads_setValueIfNotNil: self.initializeTimestamp
                                                      forKey: kUADSDeviceInfoAppStartTimestampKey];
                             }];

    [self measurePerformanceAndLog: @"getBuiltSDKVersion"
                             using: ^{
                                 [info uads_setValueIfNotNil: [NSBundle uads_getBuiltSDKVersion]
                                                      forKey: kUADSDeviceInfoBuiltSDKVersionKey];
                             }];

    [self measurePerformanceAndLog: @"getWebViewUserAgent"
                             using: ^{
                                 [info uads_setValueIfNotNil: self.userAgentReader.userAgent
                                                      forKey: kUADSDeviceInfoWebViewAgentKey];
                             }];


    return info;
}

- (void)measurePerformanceAndLog: (NSString *)eventName
                           using: (UADSVoidClosure)blockToMeasure {
    CFTimeInterval duration = uads_measure_duration_sync(blockToMeasure);
    id<UADSLogRecord> record =  [UADSDurationLogRecord newWith: eventName
                                                        system: @"DEVICE INFO PERF"
                                                      duration: duration];

    [_logger logRecord: record];
}

- (NSNumber *)initializeTimestamp {
    return @(self.userDefaultsReader.initializationStartTimeStamp.intValue);
}

@end
