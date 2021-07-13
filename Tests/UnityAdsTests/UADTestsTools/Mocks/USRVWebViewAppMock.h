#import "USRVWebViewApp.h"
#import <XCTest/XCTest.h>
NS_ASSUME_NONNULL_BEGIN

@interface USRVWebViewAppMock : USRVWebViewApp
@property (nonatomic, strong) XCTestExpectation *expectation;
@property (nonatomic, strong) NSNumber *expectedNumberOfCalls;
@property (nonatomic, strong) NSArray<NSArray *> *returnedParams;
@property (nonatomic, strong) NSArray<NSString *> *categoryNames;
@property (nonatomic, strong) NSArray<NSString *> *eventNames;
@property (nonatomic, strong) NSArray<NSArray *> *params;


- (void)emulateResponseWithParams: (NSArray *)params;
- (void)emulateResponseWithParams: (NSArray *)params
                  operationNumber: (int)index;

- (void)installAllowedClasses: (NSArray *)allowedClasses;
- (void)emulateInvokeWebExposedMethod: (NSString *)methodName
                            className: (NSString *)className
                               params: (NSArray *)params
                             callback: (id)callback;

@end

NS_ASSUME_NONNULL_END
