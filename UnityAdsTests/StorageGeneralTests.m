#import <XCTest/XCTest.h>
#import "UnityAdsTests-Bridging-Header.h"

@interface StorageGeneralTests : XCTestCase
@end

@implementation StorageGeneralTests

- (void)setUp {
    [super setUp];
    NSString *cacheDir = [UADSSdkProperties getCacheDirectory];
    [UADSStorageManager addStorageLocation:[NSString stringWithFormat:@"%@/test.data", cacheDir] forStorageType:kUnityAdsStorageTypePublic];
    [UADSStorageManager initStorage:kUnityAdsStorageTypePublic];
    
    UADSStorage *storage = [UADSStorageManager getStorage:kUnityAdsStorageTypePublic];
    if (storage) {
        NSLog(@"Clearing storage");
        [storage clearStorage];
        [storage initStorage];
    }
    else {
        NSLog(@"Storage is NULL");
    }
}

- (void)tearDown {
    [super tearDown];
}

- (void)testSetAndGetInteger {
    UADSStorage *storage = [UADSStorageManager getStorage:kUnityAdsStorageTypePublic];
    NSNumber *value = [NSNumber numberWithInt:12345];

    [storage setValue:value forKey:@"tests.integer"];
    [storage writeStorage];
    [storage clearData];
    [storage readStorage];
    
    NSNumber *valueInStorage = [storage getValueForKey:@"tests.integer"];

    XCTAssertNotNil(value, "Current value should not be NULL");
    XCTAssertNotNil(valueInStorage, "Value from storage should not be NULL");
    XCTAssertEqualObjects(valueInStorage, value, "Value not what was expected");
}

- (void)testSetAndGetBoolean {
    UADSStorage *storage = [UADSStorageManager getStorage:kUnityAdsStorageTypePublic];
    NSNumber *value = [NSNumber numberWithBool:true];
    
    [storage setValue:value forKey:@"tests.boolean"];
    [storage writeStorage];
    [storage clearData];
    [storage readStorage];
    
    NSNumber *valueInStorage = [storage getValueForKey:@"tests.boolean"];
    
    XCTAssertNotNil(value, "Current value should not be NULL");
    XCTAssertNotNil(valueInStorage, "Value from storage should not be NULL");
    XCTAssertEqualObjects(valueInStorage, value, "Value not what was expected");
}

- (void)testSetAndGetLong {
    UADSStorage *storage = [UADSStorageManager getStorage:kUnityAdsStorageTypePublic];
    NSNumber *value = [NSNumber numberWithLongLong:123451234512345];
    
    [storage setValue:value forKey:@"tests.long"];
    [storage writeStorage];
    [storage clearData];
    [storage readStorage];
    
    NSNumber *valueInStorage = [storage getValueForKey:@"tests.long"];
    
    XCTAssertNotNil(value, "Current value should not be NULL");
    XCTAssertNotNil(valueInStorage, "Value from storage should not be NULL");
    XCTAssertEqualObjects(valueInStorage, value, "Value not what was expected");
}

- (void)testSetAndGetDouble {
    UADSStorage *storage = [UADSStorageManager getStorage:kUnityAdsStorageTypePublic];
    NSNumber *value = [NSNumber numberWithDouble:12345.12345];
    
    [storage setValue:value forKey:@"tests.double"];
    [storage writeStorage];
    [storage clearData];
    [storage readStorage];
    
    NSNumber *valueInStorage = [storage getValueForKey:@"tests.double"];
    
    XCTAssertNotNil(value, "Current value should not be NULL");
    XCTAssertNotNil(valueInStorage, "Value from storage should not be NULL");
    XCTAssertEqualObjects(valueInStorage, value, "Value not what was expected");
}

- (void)testSetAndGetString {
    UADSStorage *storage = [UADSStorageManager getStorage:kUnityAdsStorageTypePublic];
    NSString *value = @"Hello World";
    
    [storage setValue:value forKey:@"tests.string"];
    [storage writeStorage];
    [storage clearData];
    [storage readStorage];
    
    NSString *valueInStorage = [storage getValueForKey:@"tests.string"];
    
    XCTAssertNotNil(value, "Current value should not be NULL");
    XCTAssertNotNil(valueInStorage, "Value from storage should not be NULL");
    XCTAssertEqualObjects(valueInStorage, value, "Value not what was expected");
}

- (void)testSetAndGetDictionary {
    UADSStorage *storage = [UADSStorageManager getStorage:kUnityAdsStorageTypePublic];
    NSDictionary *value = @{@"testkey": @"testvalue"};
    
    [storage setValue:value forKey:@"tests.dictionary"];
    [storage writeStorage];
    [storage clearData];
    [storage readStorage];
    
    NSDictionary *valueInStorage = [storage getValueForKey:@"tests.dictionary"];
    
    XCTAssertNotNil(value, "Current value should not be NULL");
    XCTAssertNotNil(valueInStorage, "Value from storage should not be NULL");
    XCTAssertEqualObjects(valueInStorage, value, "Value not what was expected");
}

- (void)testSetAndGetArray {
    UADSStorage *storage = [UADSStorageManager getStorage:kUnityAdsStorageTypePublic];
    NSArray *value = @[@"testvalue1", @"testvalue2"];
    
    [storage setValue:value forKey:@"tests.array"];
    [storage writeStorage];
    [storage clearData];
    [storage readStorage];
    
    NSArray *valueInStorage = [storage getValueForKey:@"tests.array"];
    
    XCTAssertNotNil(value, "Current value should not be NULL");
    XCTAssertNotNil(valueInStorage, "Value from storage should not be NULL");
    XCTAssertEqualObjects(valueInStorage, value, "Value not what was expected");
}

- (void)testWriteAndRead {
    UADSStorage *storage = [UADSStorageManager getStorage:kUnityAdsStorageTypePublic];
    NSNumber *value1 = [NSNumber numberWithInt:12345];
    NSString *value2 = [NSString stringWithFormat:@"Testing"];
    NSNumber *value3 = [NSNumber numberWithDouble:12345.12345];

    XCTAssertEqual(false, [storage hasData], "Storage should hold no data in the beginning of the test");
    XCTAssertEqual(true, [storage setValue:value1 forKey:@"tests.value1"], "Should have been able to set key \"tests.value1\" with value: 12345");
    XCTAssertEqual(true, [storage setValue:value2 forKey:@"tests.value2"], "Should have been able to set key \"tests.value2\" with value: Testing");
    XCTAssertEqual(true, [storage setValue:value3 forKey:@"tests.value3"], "Should have been able to set key \"tests.value3\" with value: 12345.12345");
    XCTAssertEqual(true, [storage writeStorage], "Write storage should have succeeded");
    
    [storage clearData];
    
    XCTAssertEqual(false, [storage hasData], "Storage was reset, should hold no data");
    XCTAssertEqual(true, [storage readStorage], "Read storage failed for some reason even though it shouldn't have");
    XCTAssertEqual(true, [storage hasData], "Storage should contain data since some keys were written into it");
    
    XCTAssertNotNil([storage getValueForKey:@"tests.value1"], "First value should not be NULL");
    XCTAssertEqualObjects(value1, [storage getValueForKey:@"tests.value1"], "First value was not what was expected");
    XCTAssertNotNil([storage getValueForKey:@"tests.value2"], "Second value should not be NULL");
    XCTAssertTrue([value2 isEqualToString:[storage getValueForKey:@"tests.value2"]], "Second value was not what was expected");
    XCTAssertNotNil([storage getValueForKey:@"tests.value3"], "Third value should not be NULL");
    XCTAssertEqualObjects(value3, [storage getValueForKey:@"tests.value3"], "Third value was not what was expected");
}

- (void)testMultiLevelValue {
    UADSStorage *storage = [UADSStorageManager getStorage:kUnityAdsStorageTypePublic];
    NSNumber *value1 = [NSNumber numberWithInt:12345];
    
    XCTAssertEqual(false, [storage hasData], "Storage should hold no data in the beginning of the test");
    XCTAssertEqual(true, [storage setValue:value1 forKey:@"level1.level2.level3.level4.level5"], "Should have been able to set key \"level1.level2.level3.level4.level5\" with value: 12345");
    XCTAssertEqual(true, [storage writeStorage], "Write storage should have succeeded");
    
    [storage clearData];
    
    XCTAssertEqual(false, [storage hasData], "Storage was reset, should hold no data");
    XCTAssertEqual(true, [storage readStorage], "Read storage failed for some reason even though it shouldn't have");
    XCTAssertEqual(true, [storage hasData], "Storage should contain data since some keys were written into it");
    XCTAssertEqualObjects(value1, [storage getValueForKey:@"level1.level2.level3.level4.level5"], "Third value was not what was expected");
}

- (void)testSingleLevelValue {
    UADSStorage *storage = [UADSStorageManager getStorage:kUnityAdsStorageTypePublic];
    NSNumber *value1 = [NSNumber numberWithInt:12345];
    
    XCTAssertEqual(false, [storage hasData], "Storage should hold no data in the beginning of the test");
    XCTAssertEqual(true, [storage setValue:value1 forKey:@"level1"], "Should have been able to set key \"level1.level2.level3.level4.level5\" with value: 12345");
    XCTAssertEqual(true, [storage writeStorage], "Write storage should have succeeded");
    
    [storage clearData];
    
    XCTAssertEqual(false, [storage hasData], "Storage was reset, should hold no data");
    XCTAssertEqual(true, [storage readStorage], "Read storage failed for some reason even though it shouldn't have");
    XCTAssertEqual(true, [storage hasData], "Storage should contain data since some keys were written into it");
    XCTAssertEqualObjects(value1, [storage getValueForKey:@"level1"], "Third value was not what was expected");
}

- (void)testGetKeys {
    UADSStorage *storage = [UADSStorageManager getStorage:kUnityAdsStorageTypePublic];
    NSNumber *value = [NSNumber numberWithInt:12345];
    NSArray *expected = @[@"DB62D2FF-F4F3-4050-BC22-EE7242638F71", @"EC71F5DB-D8B8-466B-B878-FEF018298493", @"7D2526C4-8123-4068-B481-0EB9680BE974"];
    
    [storage setValue:value forKey:@"session.DB62D2FF-F4F3-4050-BC22-EE7242638F71.ts"];
    [storage setValue:value forKey:@"session.DB62D2FF-F4F3-4050-BC22-EE7242638F71.operative.179BBFDA-D3C1-4137-8485-F8ECADE5E605.data"];
    
    [storage writeStorage];
    [storage clearData];
    [storage readStorage];
    
    [storage setValue:value forKey:@"session.EC71F5DB-D8B8-466B-B878-FEF018298493.ts"];
    [storage setValue:value forKey:@"session.EC71F5DB-D8B8-466B-B878-FEF018298493.operative.179BBFDA-D3C1-4137-8485-F8ECADE5E605.data"];
    
    [storage writeStorage];
    [storage clearData];
    [storage readStorage];
    
    [storage setValue:value forKey:@"session.7D2526C4-8123-4068-B481-0EB9680BE974.ts"];
    [storage setValue:value forKey:@"session.7D2526C4-8123-4068-B481-0EB9680BE974.operative.179BBFDA-D3C1-4137-8485-F8ECADE5E605.data"];
    
    NSArray *keys = [storage getKeys:@"session" recursive:false];
    
    XCTAssertEqual(expected.count, keys.count, "Expected an actual key amount differ");
    
    for (NSString *key in keys) {
        XCTAssertTrue([expected containsObject:key], "Expected keys don't contain key");
    }
}

- (void)testGetKeysNonRecursive {
    UADSStorage *storage = [UADSStorageManager getStorage:kUnityAdsStorageTypePublic];
    NSNumber *value = [NSNumber numberWithInt:12345];
    NSArray *expected = @[@"DB62D2FF-F4F3-4050-BC22-EE7242638F71", @"EC71F5DB-D8B8-466B-B878-FEF018298493", @"7D2526C4-8123-4068-B481-0EB9680BE974"];
    
    [storage setValue:value forKey:@"session.DB62D2FF-F4F3-4050-BC22-EE7242638F71.ts"];
    [storage setValue:@"heips" forKey:@"session.DB62D2FF-F4F3-4050-BC22-EE7242638F71.operative.179BBFDA-D3C1-4137-8485-F8ECADE5E605.data"];
    [storage setValue:@"http://moi.com" forKey:@"session.DB62D2FF-F4F3-4050-BC22-EE7242638F71.operative.179BBFDA-D3C1-4137-8485-F8ECADE5E605.url"];
    
    [storage writeStorage];
    [storage deleteKey:@"session.DB62D2FF-F4F3-4050-BC22-EE7242638F71.operative.179BBFDA-D3C1-4137-8485-F8ECADE5E605"];
    [storage writeStorage];
    [storage clearData];
    
    [storage readStorage];
    
    [storage setValue:value forKey:@"session.EC71F5DB-D8B8-466B-B878-FEF018298493.ts"];
    [storage setValue:value forKey:@"session.EC71F5DB-D8B8-466B-B878-FEF018298493.operative.179B2FDA-D3C1-4137-8485-F8ECADE5E605.data"];
    [storage setValue:@"http://moi.com" forKey:@"session.EC71F5DB-D8B8-466B-B878-FEF018298493.operative.179B2FDA-D3C1-4137-8485-F8ECADE5E605.url"];
    
    [storage writeStorage];
    [storage deleteKey:@"session.EC71F5DB-D8B8-466B-B878-FEF018298493.operative.179B2FDA-D3C1-4137-8485-F8ECADE5E605"];
    [storage writeStorage];
    [storage clearData];
    
    [storage readStorage];
    
    [storage setValue:value forKey:@"session.7D2526C4-8123-4068-B481-0EB9680BE974.ts"];
    [storage setValue:value forKey:@"session.7D2526C4-8123-4068-B481-0EB9680BE974.operative.179B4FDA-D3C1-4137-8485-F8ECADE5E605.data"];
    [storage setValue:@"http://moi.com" forKey:@"session.7D2526C4-8123-4068-B481-0EB9680BE974.operative.179B4FDA-D3C1-4137-8485-F8ECADE5E605.url"];
    
    [storage writeStorage];
    [storage deleteKey:@"session.7D2526C4-8123-4068-B481-0EB9680BE974.operative.179B4FDA-D3C1-4137-8485-F8ECADE5E605"];
    [storage writeStorage];
    [storage clearData];
    
    [storage readStorage];
    
    NSArray *keys = [storage getKeys:@"session" recursive:false];
    
    XCTAssertEqual(expected.count, keys.count, "Expected an actual key amount differ");
    
    for (NSString *key in keys) {
        XCTAssertTrue([expected containsObject:key], "Expected keys don't contain key");
    }
}

- (void)testGetKeysRecursive {
    UADSStorage *storage = [UADSStorageManager getStorage:kUnityAdsStorageTypePublic];
    NSNumber *value = [NSNumber numberWithInt:12345];
    NSArray *expected = @[@"DB62D2FF-F4F3-4050-BC22-EE7242638F71",
                          @"DB62D2FF-F4F3-4050-BC22-EE7242638F71.ts",
                          @"DB62D2FF-F4F3-4050-BC22-EE7242638F71.operative",
                            
                          @"EC71F5DB-D8B8-466B-B878-FEF018298493",
                          @"EC71F5DB-D8B8-466B-B878-FEF018298493.ts",
                          @"EC71F5DB-D8B8-466B-B878-FEF018298493.operative",
                            
                          @"7D2526C4-8123-4068-B481-0EB9680BE974",
                          @"7D2526C4-8123-4068-B481-0EB9680BE974.ts",
                          @"7D2526C4-8123-4068-B481-0EB9680BE974.operative"
                        ];
    
    [storage setValue:value forKey:@"session.DB62D2FF-F4F3-4050-BC22-EE7242638F71.ts"];
    [storage setValue:@"heips" forKey:@"session.DB62D2FF-F4F3-4050-BC22-EE7242638F71.operative.179BBFDA-D3C1-4137-8485-F8ECADE5E605.data"];
    [storage setValue:@"http://moi.com" forKey:@"session.DB62D2FF-F4F3-4050-BC22-EE7242638F71.operative.179BBFDA-D3C1-4137-8485-F8ECADE5E605.url"];
    
    [storage writeStorage];
    [storage deleteKey:@"session.DB62D2FF-F4F3-4050-BC22-EE7242638F71.operative.179BBFDA-D3C1-4137-8485-F8ECADE5E605"];
    [storage writeStorage];
    [storage clearData];
    
    [storage readStorage];
    
    [storage setValue:value forKey:@"session.EC71F5DB-D8B8-466B-B878-FEF018298493.ts"];
    [storage setValue:value forKey:@"session.EC71F5DB-D8B8-466B-B878-FEF018298493.operative.179B2FDA-D3C1-4137-8485-F8ECADE5E605.data"];
    [storage setValue:@"http://moi.com" forKey:@"session.EC71F5DB-D8B8-466B-B878-FEF018298493.operative.179B2FDA-D3C1-4137-8485-F8ECADE5E605.url"];
    
    [storage writeStorage];
    [storage deleteKey:@"session.EC71F5DB-D8B8-466B-B878-FEF018298493.operative.179B2FDA-D3C1-4137-8485-F8ECADE5E605"];
    [storage writeStorage];
    [storage clearData];
    
    [storage readStorage];
    
    [storage setValue:value forKey:@"session.7D2526C4-8123-4068-B481-0EB9680BE974.ts"];
    [storage setValue:value forKey:@"session.7D2526C4-8123-4068-B481-0EB9680BE974.operative.179B4FDA-D3C1-4137-8485-F8ECADE5E605.data"];
    [storage setValue:@"http://moi.com" forKey:@"session.7D2526C4-8123-4068-B481-0EB9680BE974.operative.179B4FDA-D3C1-4137-8485-F8ECADE5E605.url"];
    
    [storage writeStorage];
    [storage deleteKey:@"session.7D2526C4-8123-4068-B481-0EB9680BE974.operative.179B4FDA-D3C1-4137-8485-F8ECADE5E605"];
    [storage writeStorage];
    [storage clearData];
    
    [storage readStorage];
    
    NSArray *keys = [storage getKeys:@"session" recursive:true];
    
    XCTAssertEqual(expected.count, keys.count, "Expected an actual key amount differ");
    
    for (NSString *key in keys) {
        XCTAssertTrue([expected containsObject:key], "Expected keys don't contain key");
    }
}

@end
