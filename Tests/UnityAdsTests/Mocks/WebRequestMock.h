#import "USRVWebRequest.h"
#import <XCTest/XCTest.h>
#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface WebRequestMock : NSObject<USRVWebRequest>
@property (nonatomic, strong) NSString *url;
@property (nonatomic, strong) NSString *requestType;
@property (nonatomic, strong) NSString *body;
@property (nonatomic, strong) NSData *bodyData;
@property (nonatomic, strong) NSDictionary<NSString *, NSArray *> *headers;
@property (nonatomic, strong) NSDictionary<NSString *, NSString *> *responseHeaders;
@property (nonatomic, strong) NSMutableData *receivedData;
@property (nonatomic, strong) NSError *error;
@property (nonatomic, assign) long long expectedContentLength;
@property (nonatomic, assign) long responseCode;
@property (nonatomic, assign) BOOL canceled;
@property (nonatomic, assign) BOOL finished;
@property (nonatomic, strong) NSCondition *blockCondition;
@property (nonatomic, strong) UnityServicesWebRequestProgress progressBlock;
@property (nonatomic, strong) UnityServicesWebRequestStart startBlock;

@property (nonatomic, strong) NSMutableURLRequest *request;
@property (nonatomic, strong) NSURLConnection *connection;
@property (nonatomic, assign) int connectTimeout;

@property (nonatomic, assign) int makeRequestCount;

@property (nonatomic, assign) NSData *expectedData;
@property (nonatomic, assign) BOOL isResponseCodeInvalid;

@property (nonatomic, strong) XCTestExpectation *exp;
@property (nonatomic, assign) CFTimeInterval sleepTime;
@end

NS_ASSUME_NONNULL_END
