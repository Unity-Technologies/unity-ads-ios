#import "NSError+UADSError.h"
#import "UADSGenericError.h"
@implementation NSError (Category)

- (nullable NSArray *)errorInfo {
    return @[self.userInfo];
}

- (nonnull NSString *)errorString {
    return self.localizedDescription ? : self.domain;
}

- (NSNumber *)errorCode {
    return @(self.code);
}

- (nonnull NSString *)errorDomain {
    return self.domain;
}

@end

NSNumber * uads_extractErrorCode(id error) {
    if ([error conformsToProtocol: @protocol(UADSError)]) {
        return ((id<UADSError>)error).errorCode;
    }

    return nil;
}

NSString * uads_extractErrorString(id error) {
    NSString *errorString;

    errorString = uads_tryExtractAsUADSErrorString(error);

    if (errorString) {
        return errorString;
    } else {
        errorString = uads_tryExtractAsNSString(error);
    }

    return errorString;
}

NSString * uads_tryExtractAsUADSErrorString(id error) {
    if ([error conformsToProtocol: @protocol(UADSError)]) {
        return ((id<UADSError>)error).errorString;
    }

    return nil;
}

NSString * uads_tryExtractAsNSString(id error) {
    NSString *optionalString = typecast(error, [NSString class]);

    GUARD_OR_NIL(optionalString)
    return optionalString;
}
