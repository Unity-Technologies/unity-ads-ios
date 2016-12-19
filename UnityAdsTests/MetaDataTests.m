#import <XCTest/XCTest.h>
#import "UnityAdsTests-Bridging-Header.h"

@interface MetaDataMockWebViewApp : UADSWebViewApp
@property (nonatomic, strong) XCTestExpectation *expectation;
@property (nonatomic, strong) NSMutableArray *params;
@end

@implementation MetaDataMockWebViewApp

- (BOOL)sendEvent:(NSString *)eventId category:(NSString *)category param1:(id)param1, ... {
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
    
    return [self sendEvent:eventId category:category params:params];
}

- (BOOL)sendEvent:(NSString *)eventId category:(NSString *)category params:(NSArray *)params {
    if (eventId && [eventId isEqualToString:@"SET"] && category && [category isEqualToString:@"STORAGE"]) {
        self.params = [[NSMutableArray alloc] initWithArray:params];
        if (self.expectation) {
            [self.expectation fulfill];
        }
    }
    
    return true;
}

- (BOOL)invokeCallback:(UADSInvocation *)invocation {
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
    UADSStorage *storage = [UADSStorageManager getStorage:kUnityAdsStorageTypePublic];
    [storage clearStorage];
    [storage initStorage];
}

- (void)testMediationMetaData {
    MetaDataMockWebViewApp *webApp = [[MetaDataMockWebViewApp alloc] init];
    [UADSWebViewApp setCurrentApp:webApp];
    UADSMediationMetaData *metadata = [[UADSMediationMetaData alloc] init];
    
    [metadata setName:@"MediationNetwork"];
    [metadata setOrdinal:1];
    [metadata setVersion:@"1.1"];
    [metadata commit];
    
    XCTAssertEqual([[[webApp.params objectAtIndex:1] allKeys] count], [[metadata.entries allKeys] count], "Metadata doesn't have correct amount of values");
    
    NSDictionary *webAppMetaDataEntries = [[NSDictionary alloc] initWithDictionary:[webApp.params objectAtIndex:1]];
    for (NSString *key in [webAppMetaDataEntries allKeys]) {
        XCTAssertTrue([metadata.entries objectForKey:key], "Metadata doesn't contain key: %@", key);
        XCTAssertEqual([webAppMetaDataEntries objectForKey:key], [metadata.entries objectForKey:key], "Metadata key %@ doesn't contain value: %@", key, [webAppMetaDataEntries objectForKey:key]);
    }
}

- (void)testPlayerMetaData {
    MetaDataMockWebViewApp *webApp = [[MetaDataMockWebViewApp alloc] init];
    [UADSWebViewApp setCurrentApp:webApp];
    UADSPlayerMetaData *metadata = [[UADSPlayerMetaData alloc] init];
    [metadata setServerId:@"bulbasaur"];
    [metadata commit];
    
    XCTAssertEqual([[[webApp.params objectAtIndex:1] allKeys] count], [[metadata.entries allKeys] count], "Metadata doesn't have correct amount of values");
    
    NSDictionary *webAppMetaDataEntries = [[NSDictionary alloc] initWithDictionary:[webApp.params objectAtIndex:1]];
    for (NSString *key in [webAppMetaDataEntries allKeys]) {
        XCTAssertTrue([metadata.entries objectForKey:key], "Metadata doesn't contain key: %@", key);
        XCTAssertEqual([webAppMetaDataEntries objectForKey:key], [metadata.entries objectForKey:key], "Metadata key %@ doesn't contain value: %@", key, [webAppMetaDataEntries objectForKey:key]);
    }
}

- (void)testMetadataBaseClassNoCategory {
    MetaDataMockWebViewApp *webApp = [[MetaDataMockWebViewApp alloc] init];
    [UADSWebViewApp setCurrentApp:webApp];
    UADSMetaData *metadata = [[UADSMetaData alloc] init];
    
    [metadata set:@"test.one" value:[NSNumber numberWithInt:1]];
    [metadata set:@"test.two" value:@"2"];
    [metadata set:@"test.tree" value:[NSNumber numberWithFloat:3.333]];
    [metadata commit];
    
    XCTAssertEqual([[[webApp.params objectAtIndex:1] allKeys] count], [[metadata.entries allKeys] count], "Metadata doesn't have correct amount of values");
    
    NSDictionary *webAppMetaDataEntries = [[NSDictionary alloc] initWithDictionary:[webApp.params objectAtIndex:1]];
    for (NSString *key in [webAppMetaDataEntries allKeys]) {
        XCTAssertTrue([metadata.entries objectForKey:key], "Metadata doesn't contain key: %@", key);
        XCTAssertEqual([webAppMetaDataEntries objectForKey:key], [metadata.entries objectForKey:key], "Metadata key %@ doesn't contain value: %@", key, [webAppMetaDataEntries objectForKey:key]);
    }
}

- (void)testMetadataBaseClassWithCategory {
    MetaDataMockWebViewApp *webApp = [[MetaDataMockWebViewApp alloc] init];
    [UADSWebViewApp setCurrentApp:webApp];
    UADSMetaData *metadata = [[UADSMetaData alloc] init];
    
    [metadata setCategory:@"test"];
    [metadata set:@"one" value:[NSNumber numberWithInt:1]];
    [metadata set:@"two" value:@"2"];
    [metadata set:@"tree" value:[NSNumber numberWithFloat:3.333]];
    [metadata commit];
    
    XCTAssertEqual([[[webApp.params objectAtIndex:1] allKeys] count], [[metadata.entries allKeys] count], "Metadata doesn't have correct amount of values");
    
    NSDictionary *webAppMetaDataEntries = [[NSDictionary alloc] initWithDictionary:[webApp.params objectAtIndex:1]];
    for (NSString *key in [webAppMetaDataEntries allKeys]) {
        XCTAssertTrue([metadata.entries objectForKey:key], "Metadata doesn't contain key: %@", key);
        XCTAssertEqual([webAppMetaDataEntries objectForKey:key], [metadata.entries objectForKey:key], "Metadata key %@ doesn't contain value: %@", key, [webAppMetaDataEntries objectForKey:key]);
    }
}

- (void)testCommitWithoutMetaDataSet {
    MetaDataMockWebViewApp *webApp = [[MetaDataMockWebViewApp alloc] init];
    [UADSWebViewApp setCurrentApp:webApp];
    UADSMetaData *metadata = [[UADSMetaData alloc] init];
    
    [metadata setCategory:@"test"];
    [metadata commit];
    
    XCTAssertNil([metadata entries], "Entries should still be NULL");
}

@end
