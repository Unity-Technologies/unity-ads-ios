#import "UADSInternalError.h"

@interface UADSInternalError()
@property (nonatomic, copy) NSString *errorMessage;
@property (nonatomic, assign) NSInteger errorCode;
@property (nonatomic, assign) NSInteger reasonCode;
@end

@implementation UADSInternalError
+ (instancetype)newWithErrorCode: (NSInteger)errorCode
                       andReason: (NSInteger)reasonCode
                      andMessage: (NSString *)errorMessage {
    UADSInternalError *error = [UADSInternalError new];
    error.errorCode = errorCode;
    error.errorMessage = errorMessage;
    error.reasonCode = reasonCode;
    return error;
}

- (BOOL)isEqual:(id)other {
    if (![other isKindOfClass:[UADSInternalError class]]) {
        return false;
    }

    if (other == self) {
        return true;
    }
    
    UADSInternalError *otherError = other;
    
    return  otherError.errorCode == _errorCode &&
            otherError.reasonCode == _reasonCode;
}

- (NSUInteger)hash {
    return [super hash];
}
@end
