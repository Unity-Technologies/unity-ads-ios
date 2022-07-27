#import "UADSMinDeviceInfoReader.h"
#import "NSMutableDictionary+SafeOperations.h"
#import "UADSDeviceInfoReaderKeys.h"
#import "UADSJsonStorageKeyNames.h"
#import "USRVDevice.h"
#import "USRVTrackingManagerProxy.h"

@interface UADSMinDeviceInfoReader ()
@property (nonatomic, strong) id<UADSDeviceIDFIReader>userDefaultsReader;
@property (nonatomic, strong) id<UADSPIITrackingStatusReader>userContainerReader;
@property (nonatomic) BOOL includeUserNonBehavioral;
@property (nonatomic, copy) NSString* gameID;
@end

@implementation UADSMinDeviceInfoReader

+ (id<UADSDeviceInfoReader>)newWithIDFIReader: (id<UADSDeviceIDFIReader>)idfiReader
                          userContainerReader: (id<UADSPIITrackingStatusReader>)userContainerReader
                        withUserNonBehavioral: (BOOL)includeUserNonBehavioral
                                   withGameID: (NSString *)gameID; {
    UADSMinDeviceInfoReader *base = [UADSMinDeviceInfoReader new];

    base.userDefaultsReader = idfiReader;
    base.userContainerReader = userContainerReader;
    base.includeUserNonBehavioral = includeUserNonBehavioral;
    base.gameID = gameID;
    return base;
}

- (nonnull NSDictionary *)getDeviceInfoForGameMode: (UADSGameMode)mode {
    NSMutableDictionary *info = [NSMutableDictionary new];

    [info uads_setValueIfNotNil: @"ios"
                         forKey: kUADSDeviceInfoReaderPlatformKey];

    [info uads_setValueIfNotNil: self.userDefaultsReader.idfi
                         forKey: kUADSDeviceInfoIDFIKey];

    if (_includeUserNonBehavioral) {
        [info uads_setValueIfNotNil: @(_userContainerReader.userNonBehavioralFlag)
                             forKey: UADSJsonStorageKeyNames.userNonBehavioralFlagKey];
    }

    [info uads_setValueIfNotNil: @([USRVDevice isLimitTrackingEnabled])
                         forKey: kUADSDeviceInfoLimitAdTrackingKey];

    [info uads_setValueIfNotNil: @([USRVTrackingManagerProxy.sharedInstance trackingAuthorizationStatus])
                         forKey: kUADSDeviceInfoDeviceTrackingAuthStatusKey];
    
    [info uads_setValueIfNotNil: self.gameID
                         forKey: kUADSDeviceInfoGameIDKey];

    return info;
}

@end
