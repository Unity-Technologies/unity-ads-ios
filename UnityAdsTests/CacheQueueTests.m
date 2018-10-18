#import <XCTest/XCTest.h>
#import "UnityAdsTests-Bridging-Header.h"

static long kMinFileSize = 5000;

@interface MockWebViewApp : USRVWebViewApp
@property (nonatomic, strong) XCTestExpectation *expectation;
@property (nonatomic, strong) XCTestExpectation *progressExpectation;
@property (nonatomic, strong) XCTestExpectation *resumeEndExpectation;


@end

@implementation MockWebViewApp

- (BOOL)sendEvent:(NSString *)eventId category:(NSString *)category param1:(id)param1, ... {
    if (eventId && [eventId isEqualToString:@"DOWNLOAD_END"]) {
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
    if (eventId && [eventId isEqualToString:@"DOWNLOAD_PROGRESS"]) {
        
        va_list args;
        va_start(args, param1);
        
        NSMutableArray *params = [[NSMutableArray alloc] init];
        
        __unsafe_unretained id arg = nil;
        
        if (param1) {
            [params addObject:param1];
            
            while ((arg = va_arg(args, id)) != nil) {
                [params addObject:arg];
            }
            
            va_end(args);
        }
        NSLog(@"DOWNLOAD_PROGRESS %li", (long)[[params objectAtIndex:1] integerValue]);
        if ([[params objectAtIndex:1] integerValue] > kMinFileSize) {
            if (self.progressExpectation) {
                [self.progressExpectation fulfill];
                self.progressExpectation = nil;
            }
        }
        
    }
    
    return true;
}

- (BOOL)invokeCallback:(USRVInvocation *)invocation {
    return true;
}
@end

@interface CacheQueueTests : XCTestCase
@end

@implementation CacheQueueTests

- (void)setUp {
    [super setUp];
    MockWebViewApp *webApp = [[MockWebViewApp alloc] init];
    [USRVWebViewApp setCurrentApp:webApp];
    [USRVCacheQueue start];
}

- (void)testDownloadFile {
    XCTestExpectation *expectation = [self expectationWithDescription:@"downloadFinishExpectation"];
    MockWebViewApp *mockApp = (MockWebViewApp *)[USRVWebViewApp getCurrentApp];
    [mockApp setExpectation:expectation];
    NSString *fileName = [NSString stringWithFormat:@"%@/%@", [USRVSdkProperties getCacheDirectory], @"test.mp4"];
    [[NSFileManager defaultManager]removeItemAtPath:fileName error:nil];
    
    [USRVCacheQueue download:[TestUtilities getTestVideoUrl] target:fileName headers:nil append:false];
    
    [self waitForExpectationsWithTimeout:60 handler:^(NSError * _Nullable error) {
    }];
    
    NSFileManager *fileManager = [NSFileManager defaultManager];
    XCTAssertTrue([fileManager fileExistsAtPath:fileName], "File should exist after downloading");
}

- (void)testSetConnectTimeout {
    [USRVCacheQueue setConnectTimeout:15000];
    XCTAssertEqual([USRVCacheQueue getConnectTimeout], 15000, "Connect timeout was not the same as expected");
}

- (void)testResumeDownload {
    XCTestExpectation *expectation = [self expectationWithDescription:@"downloadProgressExpectation"];
    MockWebViewApp *mockApp = (MockWebViewApp *)[USRVWebViewApp getCurrentApp];
    [mockApp setProgressExpectation:expectation];
    NSString *fileName = [NSString stringWithFormat:@"%@/%@", [USRVSdkProperties getCacheDirectory], @"resume_test.mp4"];
    [[NSFileManager defaultManager] removeItemAtPath:fileName error:nil];
    
    [USRVCacheQueue setProgressInterval:50];
    [USRVCacheQueue download:[TestUtilities getTestVideoUrl] target:fileName headers:nil append:false];

    [self waitForExpectationsWithTimeout:60 handler:^(NSError * _Nullable error) {
        [mockApp setProgressExpectation:nil];
    }];
    
    [USRVCacheQueue cancelAllDownloads];
    XCTAssertTrue([[NSFileManager defaultManager] fileExistsAtPath:fileName], "File should exist");

    XCTestExpectation *delayExpectation  = [self expectationWithDescription:@"delayEndExpectation"];
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [delayExpectation fulfill];
    });
    
    [self waitForExpectationsWithTimeout:2 handler:^(NSError * _Nullable error) {
    }];
    
    NSFileHandle *fileHandle = [NSFileHandle fileHandleForUpdatingAtPath:fileName];
    unsigned long long fileSize = [fileHandle seekToEndOfFile];
    XCTAssertTrue(fileSize > kMinFileSize, "File size should be over 5000 %llu", fileSize);
    XCTAssertTrue(fileSize < [TestUtilities getTestVideoExpectedSize], "File size should be less than kVideoSize (%d)", [TestUtilities getTestVideoExpectedSize]);
        
    XCTestExpectation *endExpectation  = [self expectationWithDescription:@"downloadEndExpectation"];
    [mockApp setResumeEndExpectation:endExpectation];

    NSDictionary *headers = [NSDictionary dictionaryWithObject:[NSArray arrayWithObject:[NSString stringWithFormat:@"bytes=%llu-", fileSize]] forKey:@"Range"];
    
    [USRVCacheQueue download:[TestUtilities getTestVideoUrl] target:fileName headers:headers append:true];

    [self waitForExpectationsWithTimeout:60 handler:^(NSError * _Nullable error) {
    }];

    XCTAssertTrue([[NSFileManager defaultManager] fileExistsAtPath:fileName], "File should exist");
    NSFileHandle *fileHandle2 = [NSFileHandle fileHandleForUpdatingAtPath:fileName];
    unsigned long long fileSize2 = [fileHandle2 seekToEndOfFile];
    XCTAssertEqual(fileSize2, [TestUtilities getTestVideoExpectedSize], "File size should be kVideoSize (%d)", [TestUtilities getTestVideoExpectedSize]);
}


- (void)testSetProgressInterval {
    [USRVCacheQueue setProgressInterval:500];
    XCTAssertEqual(500, [USRVCacheQueue getProgressInterval], @"Progress interval should be equal to 500");
}
@end
