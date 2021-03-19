#import "UADSTools.h"
#import "USRVConfiguration.h"
#import "UADSAbstractModuleDelegate.h"
#import <UIKit/UIKit.h>
#import "UADSWebViewInvoker.h"
#import "UADSAbstractModuleOperationBasicObject.h"
#import "UADSErrorLogger.h"
NS_ASSUME_NONNULL_BEGIN

static NSString *const kUnityAdsNotSupportedMessage = @"Unity Ads is not supported for this device";
static NSString *const kUnityAdsNotInitializedMessage = @"Unity Ads is not initialized";

typedef NSDictionary<NSString*, id<UADSAbstractModuleOperationObject>> UADSAbstractModuleStateStorage;

@interface UADSAbstractModule : NSObject
// Contains common initialization flow for sharedInstances.
+(instancetype)newSharedModule;
+(instancetype)newWithInvoker:(id<UADSWebViewInvoker>)invoker
              andErrorHandler:(id<UADSErrorHandler>)errorHandler;
+(instancetype)createDefaultModule;
+(instancetype)sharedInstance;
+(void)setConfiguration:(USRVConfiguration *)config;
+(USRVConfiguration *)configuration;

-(void)executeForPlacement: (NSString *_Nonnull)placementId
               withOptions: (id<UADSDictionaryConvertible>)options
               andDelegate: (nullable id<UADSAbstractModuleDelegate>)delegate
         forViewController: (nullable UIViewController *)viewController;

-(id<UADSAbstractModuleOperationObject>)createEventWithPlacementID: (NSString *)placementID
                                                       withOptions: (id<UADSDictionaryConvertible>)options
                                                      withDelegate: (id<UADSAbstractModuleDelegate>)delegate
                                                 andViewController: (UIViewController *)viewController;
    
-(UADSInternalError * _Nullable)executionErrorForPlacementID: (NSString *)placementID;
-(UADSAbstractModuleStateStorage *)statesStorage;

-(dispatch_queue_t)synchronizedQueue;
-(_Nullable id)getDelegateForIDAndRemove: (NSString *)listenerID;
-(NSInteger)operationOperationTimeoutMs;
-(id<UADSAbstractModuleOperationObject>)getOperationWithID: (NSString *)operationID;
@end

NS_ASSUME_NONNULL_END
