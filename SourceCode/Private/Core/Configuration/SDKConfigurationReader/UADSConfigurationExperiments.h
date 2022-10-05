#import <Foundation/Foundation.h>
#import "UADSPIIDataSelector.h"
NS_ASSUME_NONNULL_BEGIN

@interface UADSConfigurationExperiments : NSObject
@property (readonly) NSDictionary<NSString *, NSString *> *json;
+ (instancetype)newWithJSON: (NSDictionary<NSString *, NSString *> *)json;
- (BOOL)        isTwoStageInitializationEnabled;
- (BOOL)        isPOSTMethodInConfigRequestEnabled;
- (BOOL)        isForwardExperimentsToWebViewEnabled;
- (BOOL)        isForcedUpdatePIIEnabled;
- (BOOL)        isHeaderBiddingTokenGenerationEnabled;
- (BOOL)        isPrivacyRequestEnabled;
- (BOOL)        isPrivacyWaitEnabled;
- (BOOL)        isSwiftDownloadEnabled;
- (BOOL)        isSwiftNativeRequestsEnabled;
- (BOOL)        isSwiftWebViewRequestsEnabled;

- (NSDictionary<NSString *, NSString *> *)nextSessionFlags;
- (NSDictionary<NSString *, NSString *> *)currentSessionFlags;
@end

NS_ASSUME_NONNULL_END
