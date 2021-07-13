#import "UADSDefaultError.h"

@interface UADSDefaultError ()

@property (nonatomic, copy) NSString *errorMessage;
@end

@implementation UADSDefaultError

+ (instancetype)newWithString: (NSString *)errorMessage {
    return [[self alloc] initWithString: errorMessage];
}

- (instancetype)initWithString: (NSString *)errorMessage {
    SUPER_INIT;
    self.errorMessage = errorMessage;
    return self;
}

- (nullable NSArray *)errorInfo {
    return @[];
}

- (NSNumber *)errorCode {
    return @-1;
}

- (nonnull NSString *)errorString {
    return _errorMessage;
}

- (NSString *)errorDomain {
    return @"";
}

@end
