#import "UADSGenericCompletion.h"

@interface UADSGenericCompletion ()
@property (nonatomic, strong)  _Nullable UADSSuccessCompletion success;
@property (nonatomic, strong)  _Nullable UADSErrorCompletion error;
@end

@implementation UADSGenericCompletion

+ (instancetype)newWithSuccess: (_Nullable UADSSuccessCompletion)success andError: (UADSErrorCompletion)error {
    return [[self alloc] initWithSuccess: success
                                andError: error];
}

- (instancetype)initWithSuccess: (_Nullable UADSSuccessCompletion)success
                       andError: (_Nullable UADSErrorCompletion)error {
    self = [super init];

    if (self) {
        _success = success;
        _error = error;
    }

    return self;
}

- (void)error: (id<UADSError>)error {
    _error(error);
    return;
}

- (void)success: (_Nullable id)data {
    _success(data);
    return;
}

@end
