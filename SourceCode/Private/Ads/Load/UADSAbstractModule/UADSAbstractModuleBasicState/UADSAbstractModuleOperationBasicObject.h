#import "UADSWebViewInvoker.h"
#import "UADSAbstractModuleDelegate.h"
NS_ASSUME_NONNULL_BEGIN

static NSString *const kUADSPlacementIDKey = @"placementId";
static NSString *const kUADSListenerIDKey = @"listenerId";
static NSString *const kUADSTimestampKey = @"time";
static NSString *const kUADSHeaderBiddingOptionsDictionaryKey = @"headerBiddingOptions";
static NSString *const kUADSOptionsDictionaryKey = @"options";

@protocol UADSAbstractModuleOperationObject <NSObject, UADSWebViewInvokerOperation>
- (id<UADSAbstractModuleDelegate>)delegate;
- (NSString *)                    id;
- (NSString *)                    placementID;
- (void)                          startListeningOperationTTLExpiration: (UADSVoidClosure)operationExpired;
@end

@interface UADSAbstractModuleOperationBasicObject : NSObject<UADSAbstractModuleOperationObject>
@property (nonatomic, copy) NSString *placementID;
@property (nonatomic, strong) NSNumber *time;
@property (nonatomic, strong) id<UADSDictionaryConvertible> options;
@property (nonatomic, strong) id<UADSAbstractModuleDelegate> delegate;
@property (nonatomic, assign) NSInteger ttl;
- (void)                          stopTTLObserving;
- (nonnull NSString *)            methodName;
@end

NS_ASSUME_NONNULL_END
