#import <XCTest/XCTest.h>
#import "USRVASWebAuthenticationSessionManager.h"

@interface USRVASWebAuthenticationSessionManagerTest : XCTestCase

@property(nonatomic, strong) USRVASWebAuthenticationSessionManager *sessionManager;
@end

@implementation USRVASWebAuthenticationSessionManagerTest

- (void)setUp {
    self.sessionManager = [[USRVASWebAuthenticationSessionManager alloc] init];
}

- (void)testCreateSession {
    NSURL *url = [[NSURL alloc] initWithString:@"https://google.com"];
    USRVASWebAuthenticationSession *session = [self.sessionManager createSession:url callbackUrlScheme:@"google.com"];
    XCTAssertNotNil(session);
    NSDictionary *sessions = [self.sessionManager getSessions];

    XCTAssertEqual([sessions allValues].count, 1);
    XCTAssertEqual([sessions objectForKey:[session getSessionId]], session);

    session = [self.sessionManager createSession:url callbackUrlScheme:@"google.com"];
    XCTAssertNotNil(session);

    sessions = [self.sessionManager getSessions];

    XCTAssertEqual([sessions allValues].count, 2);
    XCTAssertEqual([sessions objectForKey:[session getSessionId]], session);
}

- (void)testRemoveSession {
    NSURL *url = [[NSURL alloc] initWithString:@"https://google.com"];
    USRVASWebAuthenticationSession *session = [self.sessionManager createSession:url callbackUrlScheme:@"google.com"];
    XCTAssertNotNil(session);
    NSDictionary *sessions = [self.sessionManager getSessions];

    XCTAssertEqual([sessions allValues].count, 1);
    XCTAssertEqual([sessions objectForKey:[session getSessionId]], session);

    [self.sessionManager removeSession:[session getSessionId]];
    sessions = [self.sessionManager getSessions];

    XCTAssertEqual([sessions allValues].count, 0);
    XCTAssertNil([sessions objectForKey:[session getSessionId]]);
}

- (void)testStartSession {
    NSURL *url = [[NSURL alloc] initWithString:@"https://google.com"];
    USRVASWebAuthenticationSession *session = [self.sessionManager createSession:url callbackUrlScheme:@"google.com"];
    XCTAssertNotNil(session);
    BOOL didStart = [self.sessionManager startSession:[session getSessionId]];
    XCTAssertFalse(didStart);
}

- (void)testStartSessionFails {
    BOOL didStart = [self.sessionManager startSession:@"no session"];
    XCTAssertFalse(didStart);
}

- (void)testCancelSession {
    // test no crash
    NSURL *url = [[NSURL alloc] initWithString:@"https://google.com"];
    USRVASWebAuthenticationSession *session = [self.sessionManager createSession:url callbackUrlScheme:@"google.com"];
    XCTAssertNotNil(session);
    [self.sessionManager cancelSession:[session getSessionId]];
}

- (void)testCancelSessionNoSession {
    // test no crash
    [self.sessionManager cancelSession:@"no session"];
}

@end
