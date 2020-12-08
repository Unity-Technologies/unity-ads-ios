#import <XCTest/XCTest.h>
#import "UnityAdsTests-Bridging-Header.h"

@interface TokenStorageEventHandlerMock : NSObject<UADSTokenStorageEventProtocol>

@property int queueEmptyCount;
@property int accessTokenCount;
@property NSMutableArray* indecies;

- (void) sendQueueEmpty;
- (void) sendTokenAccessIndex:(NSNumber*)index;

@end

@implementation TokenStorageEventHandlerMock

- (void) sendQueueEmpty {
    self.queueEmptyCount++;
}

- (void) sendTokenAccessIndex:(NSNumber*)index {
    self.accessTokenCount++;
    
    if (self.indecies == nil) {
        self.indecies = [NSMutableArray new];
    }
    
    [self.indecies addObject:index];
}

@end

@interface TokenStorageTests : XCTestCase

@property UADSTokenStorage* tokenStorage;
@property TokenStorageEventHandlerMock* eventHandlerMock;

@end

@implementation TokenStorageTests

- (void)setUp {
    [super setUp];
    
    self.eventHandlerMock = [TokenStorageEventHandlerMock new];
    self.tokenStorage = [[UADSTokenStorage alloc] initWithEventHandler:self.eventHandlerMock];
}

- (void)tearDown {
    [super tearDown];
}

- (void)testCreateToken {
    [self.tokenStorage createTokens:@[@"token1", @"token2", @"token3"]];
    
    XCTAssertEqual([self.tokenStorage getToken], @"token1");
    XCTAssertEqual([self.tokenStorage getToken], @"token2");
    XCTAssertEqual([self.tokenStorage getToken], @"token3");
    XCTAssertEqual([self.tokenStorage getToken], nil);
}

- (void)testDeleteToken {
    [self.tokenStorage createTokens:@[@"token1", @"token2", @"token3"]];
    [self.tokenStorage deleteTokens];
    
    XCTAssertEqual([self.tokenStorage getToken], nil);
}

- (void)testAppendToken {
    [self.tokenStorage createTokens:@[@"token1"]];
    [self.tokenStorage appendTokens:@[@"token2", @"token3"]];
    
    XCTAssertEqual([self.tokenStorage getToken], @"token1");
    XCTAssertEqual([self.tokenStorage getToken], @"token2");
    XCTAssertEqual([self.tokenStorage getToken], @"token3");
    XCTAssertEqual([self.tokenStorage getToken], nil);
}

- (void)testAppendTokenOnEmptyStorage {
    [self.tokenStorage deleteTokens];
    [self.tokenStorage appendTokens:@[@"token1", @"token2"]];
    
    XCTAssertEqual([self.tokenStorage getToken], @"token1");
    XCTAssertEqual([self.tokenStorage getToken], @"token2");
    XCTAssertEqual([self.tokenStorage getToken], nil);
}

- (void)testAppendTokenWithoutQueueShouldNotCrashApp {
    [self.tokenStorage appendTokens:@[@"token2", @"token3"]];
}


- (void)testGetTokenWhenNoQueue {
    XCTAssertEqual([self.tokenStorage getToken], nil);
    XCTAssertEqual(self.eventHandlerMock.queueEmptyCount, 0);
    XCTAssertEqual(self.eventHandlerMock.accessTokenCount, 0);
}

- (void)testGetTokenAccessToken {
    [self.tokenStorage createTokens:@[@"token1"]];
    
    XCTAssertEqual([self.tokenStorage getToken], @"token1");
    XCTAssertEqual(self.eventHandlerMock.queueEmptyCount, 0);
    XCTAssertEqual(self.eventHandlerMock.accessTokenCount, 1);
    
    NSArray *myArray = @[@0];
    XCTAssertEqualObjects(self.eventHandlerMock.indecies, myArray);
}

- (void)testGetTokenEmptyQueue {
    [self.tokenStorage createTokens:@[]];
    
    XCTAssertEqual([self.tokenStorage getToken], nil);
    XCTAssertEqual(self.eventHandlerMock.queueEmptyCount, 1);
    XCTAssertEqual(self.eventHandlerMock.accessTokenCount, 0);
}

- (void)testGetTokenAccessTokenInPeekMode {
    [self.tokenStorage setPeekMode:YES];
    
    [self.tokenStorage createTokens:@[@"token1", @"token2"]];
    
    XCTAssertEqual([self.tokenStorage getToken], @"token1");
    XCTAssertEqual([self.tokenStorage getToken], @"token1");
    XCTAssertEqual(self.eventHandlerMock.queueEmptyCount, 0);
    XCTAssertEqual(self.eventHandlerMock.accessTokenCount, 2);
    
    NSArray *myArray = @[@0, @1];
    XCTAssertEqualObjects(self.eventHandlerMock.indecies, myArray);
}

@end
