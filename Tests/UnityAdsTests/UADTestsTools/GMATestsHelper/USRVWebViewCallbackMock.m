#import "USRVWebViewCallbackMock.h"

@interface USRVWebViewCallbackMock ()

@property (nonatomic, strong) UADSSuccessCompletion completion;
@end

@implementation USRVWebViewCallbackMock

+ (instancetype)newWithCompletion: (UADSSuccessCompletion)completion {
    USRVWebViewCallbackMock *obj = [USRVWebViewCallbackMock new];

    obj.completion = completion;
    return obj;
}

- (void)invokeWithStatus: (NSString *)status
                   error: (NSString *)error
                  params: (NSArray *)params  {
    _completion(params);
}

@end
