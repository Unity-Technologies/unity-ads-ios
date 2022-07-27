#import <Foundation/Foundation.h>
#import "USRVWebRequestFactory.h"
#import "WebRequestMock.h"
#import <XCTest/XCTest.h>

NS_ASSUME_NONNULL_BEGIN

@interface WebRequestFactoryMock : NSObject<IUSRVWebRequestFactoryStatic, IUSRVWebRequestFactory>
@property (nonatomic, strong) id<USRVWebRequest> mockRequest;
@property (nonatomic, strong) NSArray<NSData *> *expectedRequestData;
@property (nonatomic, strong) NSArray<WebRequestMock *> *createdRequests;
@property (nonatomic, strong) XCTestExpectation *exp;
@property (nonatomic, assign) CFTimeInterval requestSleepTime;
+ (instancetype)shared;
@end

NS_ASSUME_NONNULL_END
