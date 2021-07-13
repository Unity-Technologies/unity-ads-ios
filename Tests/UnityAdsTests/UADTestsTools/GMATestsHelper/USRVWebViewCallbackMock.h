#import <Foundation/Foundation.h>
#import "USRVWebViewCallback.h"
#import "UADSGenericCompletion.h"
NS_ASSUME_NONNULL_BEGIN

@interface USRVWebViewCallbackMock : USRVWebViewCallback

+ (instancetype)newWithCompletion: (UADSSuccessCompletion)completion;

@end

NS_ASSUME_NONNULL_END
