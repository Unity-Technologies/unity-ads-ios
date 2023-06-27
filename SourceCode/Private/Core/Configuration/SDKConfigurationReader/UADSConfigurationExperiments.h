#import <Foundation/Foundation.h>
NS_ASSUME_NONNULL_BEGIN

@interface UADSConfigurationExperiments : NSObject

@property (readonly) NSDictionary<NSString *, NSDictionary *> *json;
+ (instancetype)newWithJSON: (NSDictionary<NSString *, NSDictionary *> *)json;

- (BOOL)        isSwiftDownloadEnabled;
- (BOOL)        isSwiftNativeRequestsEnabled;
- (BOOL)        isSwiftWebViewRequestsEnabled;
- (BOOL)        isSwiftInitFlowEnabled;
- (BOOL)        isUseNewTasksEnabled;
- (BOOL)        isParallelExecutionEnabled;
- (BOOL)        isPrivacyWaitEnabled;
- (BOOL)        isNativeWebViewCacheEnabled;
- (BOOL)        isWebAdAssetCacheEnabled;
- (BOOL)        isSwiftTokenEnabled;
- (BOOL)        isOrientationSafeguardEnabled;

- (NSDictionary<NSString *, NSString *> *)nextSessionFlags;
- (NSDictionary<NSString *, NSString *> *)currentSessionFlags;
@end

NS_ASSUME_NONNULL_END
