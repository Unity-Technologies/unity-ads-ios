#import "UADSBannerError.h"

@implementation UADSBannerError

- (instancetype)initWithCode: (UADSBannerErrorCode)code userInfo: (nullable NSDictionary<NSErrorUserInfoKey, id> *)dict {
    self = [super initWithDomain: @"UADSBannerError"
                            code: code
                        userInfo: dict];
    return self;
}

- (instancetype)initWithDomain: (NSErrorDomain)domain code: (NSInteger)code userInfo: (nullable NSDictionary<NSErrorUserInfoKey, id> *)dict {
    self = [super initWithDomain: @"UADSBannerError"
                            code: UADSBannerErrorCodeUnknown
                        userInfo: dict];
    return self;
}

@end
