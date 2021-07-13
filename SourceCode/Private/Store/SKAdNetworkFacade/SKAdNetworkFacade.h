NS_ASSUME_NONNULL_BEGIN

@interface SKAdNetworkFacade : NSObject

+ (instancetype)sharedInstance;
- (void)          startImpression: (NSDictionary *)impressionJSON
                completionHandler: (UADSNSErrorCompletion)completion;

- (void)endImpression: (NSDictionary *)impressionJSON
    completionHandler: (UADSNSErrorCompletion)completion;
@end

NS_ASSUME_NONNULL_END
