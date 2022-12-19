#import <Foundation/Foundation.h>
#import "USRVWebViewCallback.h"
#import "UADSGenericCompletion.h"
NS_ASSUME_NONNULL_BEGIN

typedef void (^UADSWebViewCallbackCompletion)(NSArray*);

@interface USRVWebViewCallbackMock : USRVWebViewCallback

+ (instancetype)newWithCompletion: (UADSSuccessCompletion)completion;

+ (instancetype)newSwiftCompletion: (UADSWebViewCallbackCompletion)completion;

@end

NS_ASSUME_NONNULL_END
