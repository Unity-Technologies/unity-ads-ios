#import "UADSProxyReflection.h"
#import "UADSTools.h"
NS_ASSUME_NONNULL_BEGIN

@interface UADSSDKInitializerProxy : UADSProxyReflection
-(void)initializeWithGameID: (NSString *)gameId
                   testMode: (BOOL)testMode
                 completion: (UADSVoidClosure)completion
                      error:  (UADSNSErrorCompletion)error;
@end

NS_ASSUME_NONNULL_END
