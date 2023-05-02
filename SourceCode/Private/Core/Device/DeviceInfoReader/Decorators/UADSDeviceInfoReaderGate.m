#import "UADSDeviceInfoReaderGate.h"
#import "NSMutableDictionary+SafeRemoval.h"
#import "UADSJsonStorageKeyNames.h"

@interface UADSDeviceInfoReaderGate ()
@property (nonatomic, strong) id<UADSDeviceInfoReader>original;
@property (nonatomic, strong) id<UADSPrivacyResponseReader>privacyReader;
@end


@implementation UADSDeviceInfoReaderGate
+ (instancetype)decorateOriginal: (id<UADSDeviceInfoReader>)original
               withPrivacyReader: (id<UADSPrivacyResponseReader>)privacyReader {
    UADSDeviceInfoReaderGate *decorator = [self new];

    decorator.original = original;
    decorator.privacyReader = privacyReader;
    return decorator;
}


- (nonnull NSDictionary *)getDeviceInfoForGameMode:(UADSGameMode)mode {
    NSMutableDictionary *info = [[NSMutableDictionary alloc] initWithDictionary: [_original getDeviceInfoForGameMode: mode]];
    if (!_privacyReader.shouldSendUserNonBehavioral) {
        [info uads_removeObjectForKeyAndReturn: UADSJsonStorageKeyNames.userNonBehavioralFlagKey];
    }
    
    return info;
}

@end

