#import "UADSProxyReflection.h"
#import "GADRequestBridge.h"
#import "UADSGenericCompletion.h"

typedef NS_ENUM (NSInteger, GADQueryInfoAdType) {
    GADQueryInfoAdTypeBanner       = 0,
    GADQueryInfoAdTypeInterstitial = 1,
    GADQueryInfoAdTypeRewarded     = 2
};

@class GADQueryInfoBridge;
@class GADRequestBridge;

typedef UADSGenericCompletion<GADQueryInfoBridge *> GADQueryInfoBridgeCompletion;

NS_ASSUME_NONNULL_BEGIN

@interface GADQueryInfoBridge : UADSProxyReflection
- (NSString *_Nullable)    query;
- (NSString *_Nullable)    requestIdentifier;
- (NSDictionary *_Nullable)queryDictionary;
- (NSDictionary *_Nullable)sourceQueryDictionary;
+ (void)              createQueryInfo: (GADRequestBridge *)request
                               format: (GADQueryInfoAdType)type
                           completion: (GADQueryInfoBridgeCompletion *)completion;
@end

NS_ASSUME_NONNULL_END
