#import "USRVWebViewApp.h"
#import <XCTest/XCTest.h>
NS_ASSUME_NONNULL_BEGIN

@interface USRVWebViewAppMock: USRVWebViewApp
@property (nonatomic, strong) XCTestExpectation* expectation;
@property (nonatomic, strong) NSNumber* expectedNumberOfCalls;
@property (nonatomic, strong) NSArray<NSArray  *> *returnedParams;
-(void)emulateResponseWithParams: (NSArray *)params;
-(void)emulateResponseWithParams: (NSArray *)params
                 operationNumber: (int)index;

@end

NS_ASSUME_NONNULL_END
