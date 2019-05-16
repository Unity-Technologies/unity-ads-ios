#import <XCTest/XCTest.h>
#import "USRVASWebAuthenticationSessionManager.h"

@interface USRVASWebAuthenticationSessionManagerTest: XCTestCase

@property (nonatomic, strong) USRVASWebAuthenticationSessionManager *sessionManager;
@end

@implementation USRVASWebAuthenticationSessionManagerTest

-(void)setUp {
    self.sessionManager = [[USRVASWebAuthenticationSessionManager alloc] init];
}

- (void)testCreateSession {
    NSURL *url = [[NSURL alloc] initWithString:@"https://google.com"];
    USRVASWebAuthenticationSession *session = [self.sessionManager createSession:url callbackUrlScheme:@"google.com"];
    XCTAssertNotNil(session);
    XCTestExpectation *expectation = [self expectationWithDescription:@"testCreateSessionExpectation"];
    [self.sessionManager getSessions:^(NSDictionary *sessions){
        XCTAssertEqual([sessions allValues].count, 1);
        XCTAssertEqual([sessions objectForKey:[session getSessionId]], session);
        [expectation fulfill];
    }];
    [self waitForExpectationsWithTimeout:1 handler:^(NSError * _Nullable error) {}];

    session = [self.sessionManager createSession:url callbackUrlScheme:@"google.com"];
    XCTAssertNotNil(session);
    expectation = [self expectationWithDescription:@"testCreateSessionExpectation2"];
    [self.sessionManager getSessions:^(NSDictionary *sessions){
        XCTAssertEqual([sessions allValues].count, 2);
        XCTAssertEqual([sessions objectForKey:[session getSessionId]], session);
        [expectation fulfill];
    }];
    [self waitForExpectationsWithTimeout:1 handler:^(NSError * _Nullable error) {}];
}

- (void)testRemoveSession {
    NSURL *url = [[NSURL alloc] initWithString:@"https://google.com"];
    USRVASWebAuthenticationSession *session = [self.sessionManager createSession:url callbackUrlScheme:@"google.com"];
    XCTAssertNotNil(session);
    XCTestExpectation *expectation = [self expectationWithDescription:@"testCreateSessionExpectation"];
    [self.sessionManager getSessions:^(NSDictionary *sessions){
        XCTAssertEqual([sessions allValues].count, 1);
        XCTAssertEqual([sessions objectForKey:[session getSessionId]], session);
        [expectation fulfill];
    }];
    [self waitForExpectationsWithTimeout:1 handler:^(NSError * _Nullable error) {}];

    [self.sessionManager removeSession:[session getSessionId]];
    expectation = [self expectationWithDescription:@"testCreateSessionExpectation"];
    [self.sessionManager getSessions:^(NSDictionary *sessions){
        XCTAssertEqual([sessions allValues].count, 0);
        XCTAssertNil([sessions objectForKey:[session getSessionId]]);
        [expectation fulfill];
    }];
    [self waitForExpectationsWithTimeout:1 handler:^(NSError * _Nullable error) {}];
}

@end
