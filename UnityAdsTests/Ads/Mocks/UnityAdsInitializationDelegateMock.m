#import <Foundation/Foundation.h>
#import "UnityAdsInitializationDelegateMock.h"

@implementation UnityAdsInitializationDelegateMock

- (instancetype)init {
    if (self = [super init]) {
        self.didInitializeSuccessfully = NO;
        self.didInitializeFailedErrorMessage = [[NSMutableArray alloc] init];
    }
    return self;
}

// UnityAdsInitializationDelegate Methods
- (void)initializationComplete {
    self.didInitializeSuccessfully = YES;
    [self.expectation fulfill];
}

- (void)initializationFailed:(UnityAdsInitializationError)error withMessage:(NSString *)message {
    self.didInitializeFailedError = error;
    [self.didInitializeFailedErrorMessage addObject:message];
    [self.expectation fulfill];
}

@end
