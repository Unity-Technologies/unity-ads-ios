#import "UADSSDKInitializerProxy.h"
#import "NSPrimitivesBox.h"

static NSString *const kInitializeMethodName = @"initializeWithGameID:testMode:completion:error:";

@implementation UADSSDKInitializerProxy

+ (NSString *)className {
    return @"UnityAds.SDKInitializerOBJBridge";
}

-(void)initializeWithGameID: (NSString *)gameId
                   testMode: (BOOL)testMode
                 completion: (UADSVoidClosure)completion
                      error: (UADSNSErrorCompletion)error {
 
    NSPrimitivesBox *box = [NSPrimitivesBox newWithBytes: &testMode objCType: @encode(BOOL)];
    [self callInstanceMethod: kInitializeMethodName
                        args:@[gameId, box, completion, error]];
}




@end
