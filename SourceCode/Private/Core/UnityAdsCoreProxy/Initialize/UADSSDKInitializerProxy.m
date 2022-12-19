#import "UADSSDKInitializerProxy.h"

static NSString *const kInitializeMethodName = @"initializeWithGameID:testMode:completion:error:";

@implementation UADSSDKInitializerProxy

+ (NSString *)className {
    return @"UnityAds.SDKInitializerOBJBridge";
}

-(void)initializeWithGameID: (NSString *)gameId
                   testMode: (BOOL)testMode
                 completion: (UADSVoidClosure)completion
                      error: (UADSNSErrorCompletion)error {
 
    [self callInstanceMethod: kInitializeMethodName
                        args:@[gameId, @(testMode), completion, error]];
}




@end
