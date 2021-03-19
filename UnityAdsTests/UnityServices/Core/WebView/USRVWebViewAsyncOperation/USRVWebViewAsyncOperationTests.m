#import <XCTest/XCTest.h>
#import "USRVWebViewAppMock.h"
#import "USRVWebViewApp.h"
#import "USRVWebViewAsyncOperation.h"

static NSString * const FAKE_WEB_VIEW_METHOD = @"FAKE_WEB_VIEW_METHOD";
static NSString * const FAKE_WEB_VIEW_CLASS = @"FAKE_WEB_VIEW_METHOD";
static NSString * const DEFAULT_EXPECTATION_NAME = @"FAKE_WEB_VIEW_METHOD";

#define DEFAULT_WAITING_TIME 5
#define OPERATION_DEFAULT_WAITING_TIME 5
@interface USRVWebViewAsyncOperationTests : XCTestCase
@property (nonatomic, strong) USRVWebViewAppMock *webAppMock;
@property (nonatomic) dispatch_queue_t queue;

@end

@implementation USRVWebViewAsyncOperationTests

-(void)setUp {
    _webAppMock = [USRVWebViewAppMock new];
    [USRVWebViewApp setCurrentApp:_webAppMock];
    _queue = dispatch_queue_create("USRVWebViewAsyncOperationTests.Queue", DISPATCH_QUEUE_CONCURRENT);
}

-(void)test_success_response_from_web_app_returns_ok_status {
    USRVWebViewAsyncOperation *operation = [self newOperationToTest];
    
    XCTestExpectation *expectation = self.defaultExpectation;
    [self setWebViewExpectation];
    
    [self executeOperation: operation
            withCompletion: ^(USRVWebViewAsyncOperationStatus status, NSString *codeStatus) {
        
        XCTAssertEqual(status, kUSRVWebViewAsyncOperationStatusOK);
        [expectation fulfill];
    }];
    
    [self waitForExpectations: @[self.webAppMock.expectation]
                      timeout: DEFAULT_WAITING_TIME];

    [_webAppMock emulateResponseWithParams: @[@"OK"]];
    [self waitForExpectations:@[expectation] timeout: DEFAULT_WAITING_TIME];
}

-(void)test_error_response_from_web_app_returns_error_status {
    USRVWebViewAsyncOperation *operation = [self newOperationToTest];
    
    XCTestExpectation *expectation = self.defaultExpectation;
    
    [self setWebViewExpectation];
    
    [self executeOperation: operation
            withCompletion: ^(USRVWebViewAsyncOperationStatus status, NSString *codeStatus) {
        
        XCTAssertEqual(status, kUSRVWebViewAsyncOperationStatusError);
        [expectation fulfill];
    }];
    
    [self waitForExpectations: @[self.webAppMock.expectation]
                      timeout: DEFAULT_WAITING_TIME];

    [_webAppMock emulateResponseWithParams: @[@"NOT_OK"]];
    [self waitForExpectations:@[expectation] timeout: DEFAULT_WAITING_TIME];
}

-(void)test_timeout_response_from_web_app_returns_timeout_status {
    USRVWebViewAsyncOperation *operation = [self newOperationToTest];
    
    XCTestExpectation *expectation = self.defaultExpectation;
    [self setWebViewExpectation];
    
    [self executeOperation: operation
            withCompletion: ^(USRVWebViewAsyncOperationStatus status, NSString *codeStatus) {
        
        XCTAssertEqual(status, kUSRVWebViewAsyncOperationStatusTimeout);
        [expectation fulfill];
    }];
    
    [self waitForExpectations: @[self.webAppMock.expectation]
                      timeout: DEFAULT_WAITING_TIME];

    [self waitForExpectations: @[expectation]
                      timeout: DEFAULT_WAITING_TIME];
}

-(void)executeOperation: (USRVWebViewAsyncOperation *)operation
         withCompletion: (USRVWebViewAsyncOperationCompletion)completion {
    [operation execute: completion];
}

-(void)setWebViewExpectation {
    self.webAppMock.expectation =  [self expectationWithDescription: @"WebViewMock_Expectation"];
}

-(XCTestExpectation *)defaultExpectation {
    return [self expectationWithDescription:@"USRVWebViewAsyncOperationTests"];
}

-(USRVWebViewAsyncOperation *)newOperationToTest {
  return [USRVWebViewAsyncOperation newWithMethod: FAKE_WEB_VIEW_METHOD
                                     webViewClass: FAKE_WEB_VIEW_CLASS
                                       parameters: @[]
                                         waitTime: 1];
}

@end
