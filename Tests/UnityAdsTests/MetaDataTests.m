#import <XCTest/XCTest.h>
#import "UADSMediationMetaData.h"
#import "UADSPlayerMetaData.h"
#import "UnityAdsTests-Bridging-Header.h"
#import "XCTestCase+Convenience.h"

@interface MetaDataMockWebViewApp : USRVWebViewApp
@property (nonatomic, strong) XCTestExpectation *expectation;
@property (nonatomic, strong) NSMutableArray *params;
@property (nonatomic, strong) dispatch_queue_t syncQueue;
@end

@implementation MetaDataMockWebViewApp

- (instancetype)init {
    self = [super init];

    if (self) {
        _syncQueue = dispatch_queue_create("com.unity.webview.mock", DISPATCH_QUEUE_SERIAL);
    }

    return self;
}

- (BOOL)sendEvent: (NSString *)eventId category: (NSString *)category param1: (id)param1, ... {
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

    return [self sendEvent: eventId
                  category: category
                    params: params];
}

- (BOOL)sendEvent: (NSString *)eventId category: (NSString *)category params: (NSArray *)params {
    if (eventId && [eventId isEqualToString: @"SET"] && category && [category isEqualToString: @"STORAGE"]) {
        dispatch_sync(self.syncQueue, ^{
            self.params = [[NSMutableArray alloc] initWithArray: params];
        });

        if (self.expectation) {
            [self.expectation fulfill];
        }
    }

    return true;
}

- (BOOL)invokeCallback: (USRVInvocation *)invocation {
    return true;
}

@end

@interface MetaDataTests : XCTestCase
@end

@implementation MetaDataTests

- (void)setUp {
    [super setUp];
}

- (void)tearDown {
    USRVStorage *storage = [USRVStorageManager getStorage: kUnityServicesStorageTypePublic];

    [storage clearStorage];
    [storage initStorage];
}

- (void)testMediationMetaData {
    MetaDataMockWebViewApp *webApp = [[MetaDataMockWebViewApp alloc] init];

    [USRVWebViewApp setCurrentApp: webApp];
    UADSMediationMetaData *metadata = [[UADSMediationMetaData alloc] init];

    [metadata setName: @"MediationNetwork"];
    [metadata setOrdinal: 1];
    [metadata setVersion: @"1.1"];
    [metadata commit];

    NSDictionary *webAppMetaDataEntries = [[NSDictionary alloc] initWithDictionary: [webApp.params objectAtIndex: 1]];
    NSDictionary *mediationObject = [webAppMetaDataEntries objectForKey: @"mediation"];
    NSDictionary *nameObject = [mediationObject objectForKey: @"name"];

    XCTAssertNotNil([nameObject objectForKey: @"ts"]);
    XCTAssertEqualObjects([nameObject objectForKey: @"value"], @"MediationNetwork", @"Name is not what was expected");

    NSDictionary *ordinalObject = [mediationObject objectForKey: @"ordinal"];

    XCTAssertNotNil([ordinalObject objectForKey: @"ts"]);
    XCTAssertEqualObjects([ordinalObject objectForKey: @"value"], [NSNumber numberWithInt: 1], @"Ordinal is not what was expected");

    NSDictionary *versionObject = [mediationObject objectForKey: @"version"];

    XCTAssertNotNil([versionObject objectForKey: @"ts"]);
    XCTAssertEqualObjects([versionObject objectForKey: @"value"], @"1.1", @"Version not what was expected");
} /* testMediationMetaData */

- (void)testPlayerMetaData {
    MetaDataMockWebViewApp *webApp = [[MetaDataMockWebViewApp alloc] init];

    [USRVWebViewApp setCurrentApp: webApp];
    UADSPlayerMetaData *metadata = [[UADSPlayerMetaData alloc] init];

    [metadata setServerId: @"bulbasaur"];
    [metadata commit];

    NSDictionary *webAppMetaDataEntries = [[NSDictionary alloc] initWithDictionary: [webApp.params objectAtIndex: 1]];
    NSDictionary *playerObject = [webAppMetaDataEntries objectForKey: @"player"];
    NSDictionary *serverIdObject = [playerObject objectForKey: @"server_id"];

    XCTAssertNotNil([serverIdObject objectForKey: @"ts"]);
    XCTAssertEqualObjects([serverIdObject objectForKey: @"value"], @"bulbasaur", @"server_id not what was expected");
}

- (void)testMetadataBaseClassNoCategory {
    MetaDataMockWebViewApp *webApp = [[MetaDataMockWebViewApp alloc] init];

    [USRVWebViewApp setCurrentApp: webApp];

    UADSMetaData *metadata = [[UADSMetaData alloc] init];

    [metadata set: @"test.one"
            value : [NSNumber numberWithInt: 1]];
    [metadata set: @"test.two"
            value : @"2"];
    [metadata set: @"test.three"
            value : [NSNumber numberWithFloat: 3.333]];
    [metadata commit];

    NSDictionary *webAppMetaDataEntries = [[NSDictionary alloc] initWithDictionary: [webApp.params objectAtIndex: 1]];
    NSDictionary *testObject = [webAppMetaDataEntries objectForKey: @"test"];
    NSDictionary *oneObject = [testObject objectForKey: @"one"];

    XCTAssertNotNil([oneObject objectForKey: @"ts"]);
    XCTAssertEqualObjects([oneObject objectForKey: @"value"], [NSNumber numberWithInt: 1], "'one' value not what was expected");

    NSDictionary *twoObject = [testObject objectForKey: @"two"];

    XCTAssertNotNil([twoObject objectForKey: @"ts"]);
    XCTAssertEqualObjects([twoObject objectForKey: @"value"], @"2", "'two' value not what was expected");

    NSDictionary *threeObject = [testObject objectForKey: @"three"];

    XCTAssertNotNil([threeObject objectForKey: @"ts"]);
    XCTAssertEqualObjects([threeObject objectForKey: @"value"], [NSNumber numberWithFloat: 3.333], "'three' value not what was expected");
} /* testMetadataBaseClassNoCategory */

- (void)testMetadataBaseClassNoCategoryDiskWrite {
    MetaDataMockWebViewApp *webApp = [[MetaDataMockWebViewApp alloc] init];

    [USRVWebViewApp setCurrentApp: webApp];

    UADSMetaData *metadata = [[UADSMetaData alloc] init];

    [metadata set: @"test.one"
            value : [NSNumber numberWithInt: 1]];
    [metadata set: @"test.two"
            value : @"2"];
    [metadata set: @"test.three"
            value : [NSNumber numberWithDouble: 123.123]];
    [metadata commit];

    UADSMetaData *metadata2 = [[UADSMetaData alloc] init];

    [metadata2 set: @"test.four"
             value : [NSNumber numberWithInt: 4]];
    [metadata2 commit];

    USRVStorage *storage = [USRVStorageManager getStorage: kUnityServicesStorageTypePublic];

    [storage clearData];
    [storage readStorage];

    NSDictionary *testDictionary = [storage getValueForKey: @"test"];

    NSLog(@"%@", testDictionary);

    XCTAssertEqualObjects([NSNumber numberWithInt: 1], [[testDictionary valueForKey: @"one"] valueForKey: @"value"], "Incorrect 'one' value");
    XCTAssertEqualObjects(@"2", [[testDictionary valueForKey: @"two"] valueForKey: @"value"], "Incorrect 'two' value");
    XCTAssertEqualObjects([NSNumber numberWithDouble: 123.123], [[testDictionary valueForKey: @"three"] valueForKey: @"value"], "Incorrect 'three' value");
    XCTAssertEqualObjects([NSNumber numberWithInt: 4], [[testDictionary valueForKey: @"four"] valueForKey: @"value"], "Incorrect 'four' value");
} /* testMetadataBaseClassNoCategoryDiskWrite */

- (void)testMetadataBaseClassWithCategory {
    MetaDataMockWebViewApp *webApp = [[MetaDataMockWebViewApp alloc] init];

    [USRVWebViewApp setCurrentApp: webApp];
    UADSMetaData *metadata = [[UADSMetaData alloc] init];

    [metadata setCategory: @"test"];
    [metadata set: @"one"
            value : [NSNumber numberWithInt: 1]];
    [metadata set: @"two"
            value : @"2"];
    [metadata set: @"three"
            value : [NSNumber numberWithFloat: 3.333]];
    [metadata commit];

    NSDictionary *webAppMetaDataEntries = [[NSDictionary alloc] initWithDictionary: [webApp.params objectAtIndex: 1]];
    NSDictionary *testObject = [webAppMetaDataEntries objectForKey: @"test"];
    NSDictionary *oneObject = [testObject objectForKey: @"one"];

    XCTAssertNotNil([oneObject objectForKey: @"ts"]);
    XCTAssertEqualObjects([oneObject objectForKey: @"value"], [NSNumber numberWithInt: 1], "'one' value not what was expected");

    NSDictionary *twoObject = [testObject objectForKey: @"two"];

    XCTAssertNotNil([twoObject objectForKey: @"ts"]);
    XCTAssertEqualObjects([twoObject objectForKey: @"value"], @"2", "'two' value not what was expected");

    NSDictionary *threeObject = [testObject objectForKey: @"three"];

    XCTAssertNotNil([threeObject objectForKey: @"ts"]);
    XCTAssertEqualObjects([threeObject objectForKey: @"value"], [NSNumber numberWithFloat: 3.333], "'three' value not what was expected");
} /* testMetadataBaseClassWithCategory */

- (void)testCommitWithoutMetaDataSet {
    MetaDataMockWebViewApp *webApp = [[MetaDataMockWebViewApp alloc] init];

    [USRVWebViewApp setCurrentApp: webApp];
    UADSMetaData *metadata = [[UADSMetaData alloc] init];

    [metadata setCategory: @"test"];
    [metadata commit];

    XCTAssertNil([metadata storageContents], "Entries should still be NULL");
}

- (void)testCommitFromDifferentThreadsDoNotCrash {
    MetaDataMockWebViewApp *webApp = [[MetaDataMockWebViewApp alloc] init];

    [USRVWebViewApp setCurrentApp: webApp];

    UADSMetaData *metadata = [[UADSMetaData alloc] initWithCategory: @"test"];

    [self asyncExecuteTimes: 1000
                      block:^(XCTestExpectation *_Nonnull expectation, int index) {
                          [metadata set: [NSString stringWithFormat: @"key%d", index]
                                  value : [NSString stringWithFormat: @"value%d", index]];
                          [metadata commit];
                          [expectation fulfill];
                      }];
}

@end
