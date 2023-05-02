#import <Foundation/Foundation.h>
#import "USRVJsonStorage.h"
NS_ASSUME_NONNULL_BEGIN

typedef NS_ENUM (NSInteger, UADSPrivacyMode) {
    kUADSPrivacyModeApp,
    kUADSPrivacyModeNone,
    kUADSPrivacyModeMixed,
    kUADSPrivacyModeUndefined,
    kUADSPrivacyModeNull
};

extern NSString * uads_privacyModeString(UADSPrivacyMode mode);

@protocol UADSPIITrackingStatusReader <NSObject>
- (UADSPrivacyMode)privacyMode;
- (NSNumber *)userNonBehavioralFlag;
@end

@interface UADSPIITrackingStatusReaderBase : NSObject<UADSPIITrackingStatusReader>
+ (instancetype)   newWithStorageReader: (id<UADSJsonStorageReader>)storageReader;
@end

NS_ASSUME_NONNULL_END
