#import "USRVWebViewCallbackMock.h"

@interface USRVWebViewCallbackMock ()

@property (nonatomic, strong) UADSSuccessCompletion completion;
@property (nonatomic, strong) UADSWebViewCallbackCompletion scompletion;
@end

@implementation USRVWebViewCallbackMock

+ (instancetype)newWithCompletion: (UADSSuccessCompletion)completion {
    USRVWebViewCallbackMock *obj = [USRVWebViewCallbackMock new];

    obj.completion = completion;
    return obj;
}

+ (instancetype)newSwiftCompletion: (UADSWebViewCallbackCompletion)completion {
    USRVWebViewCallbackMock *obj = [USRVWebViewCallbackMock new];

    obj.scompletion = completion;
    return obj;
}

- (void)invokeWithStatus: (NSString *)status
                   error: (NSString *)error
                  params: (NSArray *)params  {
    if (_completion) {
        _completion(params);
    }
    if (_scompletion) {
        _scompletion(params);
    }
}

@end
