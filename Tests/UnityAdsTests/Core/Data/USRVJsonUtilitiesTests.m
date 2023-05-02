#import <XCTest/XCTest.h>
#import "USRVJsonUtilities.h"
#import "XCTestCase+Convenience.h"
@interface USRVJsonUtilities (Mock)
+ (void)setMockException: (NSException *)mockException;
@end

@implementation USRVJsonUtilities (Mock)

static NSException * _mockException;
static NSString *lockObject = @"lock";
+ (NSData *)_dataWithJSONObject: (id)obj options: (NSJSONWritingOptions)opt error: (NSError *_Nullable *)error {
    @synchronized (lockObject) {
        if (_mockException) {
            @throw _mockException;
        } else {
            return [NSJSONSerialization dataWithJSONObject: obj
                                                   options: opt
                                                     error: error];
        }
    }
  
}

+ (void)setMockException: (NSException *)mockException {
    _mockException = mockException;
}

@end

@interface USRVJsonUtilitiesTests : XCTestCase

@end

@implementation USRVJsonUtilitiesTests

- (void)setUp {
    [super setUp];
    [USRVJsonUtilities setMockException: nil];
    [self resetUnityAds];
}

- (void)tearDown {
    [USRVJsonUtilities setMockException: nil];
    [self resetUnityAds];
}

- (void)testNilError {
    // should not throw
    [USRVJsonUtilities dataWithJSONObject: @1
                                  options: 0
                                    error: nil];
}

- (void)testInvalidJsonError {
    NSError *error;

    [USRVJsonUtilities dataWithJSONObject: @1
                                  options: 0
                                    error: &error];
    XCTAssertNotNil(error);
    NSString *localizedDescription = [error localizedDescription];

    XCTAssertTrue([localizedDescription isEqualToString: @"USRVJsonUtilities.dataWithJSONObject was not able to convert invalid json object to json : 1"]);
}

- (void)testException {
    [USRVJsonUtilities setMockException: [[NSException alloc] initWithName: NSMallocException
                                                                    reason: @"Out of memory in test"
                                                                  userInfo: nil]];
    NSError *error;
    NSData *data = [USRVJsonUtilities dataWithJSONObject: @{
                        @"key": @"value"
                    }
                                                 options: 0
                                                   error: &error];

    XCTAssertNil(data);
    XCTAssertNotNil(error);
    XCTAssertTrue([@"USRVJsonUtilities.dataWithJSONObject an exception occurred during dataWithJSONObject : NSMallocException : Out of memory in test" isEqualToString: [error localizedDescription]]);
}

- (void)testValidTranslation {
    NSError *error;
    NSData *data = [USRVJsonUtilities dataWithJSONObject: @{
                        @"key": @"value"
                    }
                                                 options: 0
                                                   error: &error];

    XCTAssertNotNil(data);
    XCTAssertNil(error);
}

@end
