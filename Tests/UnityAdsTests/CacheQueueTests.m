#import <XCTest/XCTest.h>
#import "UnityAdsTests-Bridging-Header.h"

static long kMinFileSize = 5000;

@interface MockWebViewApp : USRVWebViewApp
@property (nonatomic, strong) XCTestExpectation *expectation;
@property (nonatomic, strong) XCTestExpectation *progressExpectation;
@property (nonatomic, strong) XCTestExpectation *resumeEndExpectation;


@end

@implementation MockWebViewApp

- (BOOL)sendEvent: (NSString *)eventId category: (NSString *)category param1: (id)param1, ... {
    if (eventId && [eventId isEqualToString: @"DOWNLOAD_END"]) {
        NSLog(@"DOWNLOAD_END");

        if (self.expectation) {
            [self.expectation fulfill];
            self.expectation = nil;
        }

        if (self.resumeEndExpectation) {
            [self.resumeEndExpectation fulfill];
            self.resumeEndExpectation = nil;
        }
    }

    if (eventId && [eventId isEqualToString: @"DOWNLOAD_PROGRESS"]) {
        va_list args;
        va_start(args, param1);

        NSMutableArray *params = [[NSMutableArray alloc] init];

        __unsafe_unretained id arg = nil;

        if (param1) {
            [params addObject: param1];

            while ((arg = va_arg(args, id)) != nil)
                [params addObject: arg];

            va_end(args);
        }

        NSLog(@"DOWNLOAD_PROGRESS %li", (long)[[params objectAtIndex: 1] integerValue]);

        if ([[params objectAtIndex: 1] integerValue] > kMinFileSize) {
            if (self.progressExpectation) {
                [self.progressExpectation fulfill];
                self.progressExpectation = nil;
            }
        }
    }

    return true;
}

- (BOOL)invokeCallback: (USRVInvocation *)invocation {
    return true;
}

@end

@interface CacheQueueTests : XCTestCase
@end

@implementation CacheQueueTests

- (void)setUp {
    [super setUp];
    MockWebViewApp *webApp = [[MockWebViewApp alloc] init];

    [USRVWebViewApp setCurrentApp: webApp];
    [USRVCacheQueue start];
}

- (void)testSetConnectTimeout {
    [USRVCacheQueue setConnectTimeout: 15000];
    XCTAssertEqual([USRVCacheQueue getConnectTimeout], 15000, "Connect timeout was not the same as expected");
}

- (void)testSetProgressInterval {
    [USRVCacheQueue setProgressInterval: 500];
    XCTAssertEqual(500, [USRVCacheQueue getProgressInterval], @"Progress interval should be equal to 500");
}

@end
