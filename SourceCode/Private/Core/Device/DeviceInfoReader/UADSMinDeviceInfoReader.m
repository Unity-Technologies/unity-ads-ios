#import "UADSMinDeviceInfoReader.h"
#import "NSMutableDictionary+SafeOperations.h"
#import "UADSDeviceInfoReaderKeys.h"
#import "UADSJsonStorageKeyNames.h"
#import "USRVDevice.h"
#import "USRVTrackingManagerProxy.h"

@interface UADSMinDeviceInfoReader ()
@property (nonatomic, strong) id<UADSDeviceIDFIReader>userDefaultsReader;
@property (nonatomic, strong) id<UADSPIITrackingStatusReader>userContainerReader;
@property (nonatomic, strong) id<UADSClientConfig> clientConfig;
@property (nonatomic, strong) id<UADSGameSessionIdReader>gameSessionIdReader;
@end

@implementation UADSMinDeviceInfoReader

+ (id<UADSDeviceInfoReader>)newWithIDFIReader: (id<UADSDeviceIDFIReader>)idfiReader
                          userContainerReader: (id<UADSPIITrackingStatusReader>)userContainerReader
                          gameSessionIdReader: (id<UADSGameSessionIdReader>)gameSessionIdReader
                                 clientConfig: (id<UADSClientConfig>)clientConfig {
    UADSMinDeviceInfoReader *base = [UADSMinDeviceInfoReader new];

    base.userDefaultsReader = idfiReader;
    base.userContainerReader = userContainerReader;
    base.gameSessionIdReader = gameSessionIdReader;
    base.clientConfig = clientConfig;
    return base;
}

- (nonnull NSDictionary *)getDeviceInfoForGameMode: (UADSGameMode)mode {
    NSMutableDictionary *info = [NSMutableDictionary new];

    [info uads_setValueIfNotNil: @"ios"
                         forKey: kUADSDeviceInfoReaderPlatformKey];

    [info uads_setValueIfNotNil: self.userDefaultsReader.idfi
                         forKey: kUADSDeviceInfoIDFIKey];
    
    [info uads_setValueIfNotNil: @(_userContainerReader.userNonBehavioralFlag)
                         forKey: UADSJsonStorageKeyNames.userNonBehavioralFlagKey];
    
    
    [info uads_setValueIfNotNil: @([USRVDevice isLimitTrackingEnabled])
                         forKey: kUADSDeviceInfoLimitAdTrackingKey];
    
    [info uads_setValueIfNotNil: @([USRVTrackingManagerProxy.sharedInstance trackingAuthorizationStatus])
                         forKey: kUADSDeviceInfoDeviceTrackingAuthStatusKey];

    [info uads_setValueIfNotNil: self.clientConfig.gameID
                         forKey: kUADSDeviceInfoGameIDKey];
    
    [info uads_setValueIfNotNil: self.clientConfig.sdkVersion
                         forKey: kUADSDeviceInfoReaderSDKVersionKey];
    
    [info uads_setValueIfNotNil: self.clientConfig.sdkVersionName
                         forKey: kUADSDeviceInfoReaderSDKVersionNameKey];
    
    [info uads_setValueIfNotNil: self.gameSessionIdReader.gameSessionId
                         forKey: UADSJsonStorageKeyNames.webViewDataGameSessionIdKey];

    return info;
}

@end
