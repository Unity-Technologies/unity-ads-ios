#import <XCTest/XCTest.h>
#import "UnityAdsTests-Bridging-Header.h"
#import "USRVPreferences.h"

static NSString *uadsTestStringKey = @"test.string";
static NSString *uadsTestIntKey = @"test.int";
static NSString *uadsTestLongKey = @"test.long";
static NSString *uadsTestBoolKey = @"test.boolean";
static NSString *uadsTestFloatKey = @"test.float";
static NSString *uadsTestNonExistingKey = @"non.existing.key";

@interface PreferencesTests : XCTestCase
@end

@implementation PreferencesTests

- (void)deleteKey:(NSString*)key {
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:key];
}

- (void)setUp {
    [super setUp];
    [self deleteKey:uadsTestStringKey];
    [self deleteKey:uadsTestIntKey];
    [self deleteKey:uadsTestLongKey];
    [self deleteKey:uadsTestBoolKey];
    [self deleteKey:uadsTestFloatKey];
}

- (void)tearDown {
    [super tearDown];
}

- (void)testPreferencesStringGetter {
    NSString *testValue = @"testString";
    XCTAssertFalse([USRVPreferences hasKey:uadsTestStringKey], @"Preferences contained a key before one was written");
    [[NSUserDefaults standardUserDefaults] setValue:testValue forKey:uadsTestStringKey];
    [[NSUserDefaults standardUserDefaults] synchronize];
    XCTAssertTrue([USRVPreferences hasKey:uadsTestStringKey], @"Preferences did not contain previously committed value");
    XCTAssertTrue([[USRVPreferences getString:uadsTestStringKey] isEqualToString:testValue], @"Proper string value was not read from user default");
    XCTAssertNil([USRVPreferences getString:uadsTestNonExistingKey], @"Non-nil value returned for a non-existing key");
}

- (void)testPreferencesIntGetter {
    NSInteger testValue = 12345;
    XCTAssertFalse([USRVPreferences hasKey:uadsTestIntKey], @"Preferences contained a key before one was written");
    [[NSUserDefaults standardUserDefaults] setValue:[NSNumber numberWithInteger:testValue] forKey:uadsTestIntKey];
    [[NSUserDefaults standardUserDefaults] synchronize];
    XCTAssertTrue([USRVPreferences hasKey:uadsTestIntKey], @"Preferences did not contain previously committed value");
    XCTAssertTrue([[USRVPreferences getInteger:uadsTestIntKey] integerValue] == testValue , @"Proper int value was not read from user default");
    XCTAssertNil([USRVPreferences getString:uadsTestNonExistingKey], @"Non-nil value returned for a non-existing key");
}

- (void)testPreferencesLongGetter {
    long testValue = 12345678;
    XCTAssertFalse([USRVPreferences hasKey:uadsTestLongKey], @"Preferences contained a key before one was written");
    [[NSUserDefaults standardUserDefaults] setValue:[NSNumber numberWithLong:testValue] forKey:uadsTestLongKey];
    [[NSUserDefaults standardUserDefaults] synchronize];
    XCTAssertTrue([USRVPreferences hasKey:uadsTestLongKey], @"Preferences did not contain previously committed value");
    XCTAssertTrue([[USRVPreferences getLong:uadsTestLongKey] longValue] == testValue , @"Proper long value was not read from user default");
    XCTAssertNil([USRVPreferences getString:uadsTestNonExistingKey], @"Non-nil value returned for a non-existing key");
}

- (void)testPreferencesFloatGetter {
    float testValue = 1.2345;
    XCTAssertFalse([USRVPreferences hasKey:uadsTestFloatKey], @"Preferences contained a key before one was written");
    [[NSUserDefaults standardUserDefaults] setValue:[NSNumber numberWithFloat:testValue] forKey:uadsTestFloatKey];
    [[NSUserDefaults standardUserDefaults] synchronize];
    XCTAssertTrue([USRVPreferences hasKey:uadsTestFloatKey], @"Preferences did not contain previously committed value");
    XCTAssertTrue([[USRVPreferences getFloat:uadsTestFloatKey] floatValue] == testValue , @"Proper float value was not read from user default");
    XCTAssertNil([USRVPreferences getString:uadsTestNonExistingKey], @"Non-nil value returned for a non-existing key");
}

- (void)testPreferencesBooleanGetter {
    bool testValue = YES;
    XCTAssertFalse([USRVPreferences hasKey:uadsTestBoolKey], @"Preferences contained a key before one was written");
    [[NSUserDefaults standardUserDefaults] setValue:[NSNumber numberWithBool:testValue] forKey:uadsTestBoolKey];
    [[NSUserDefaults standardUserDefaults] synchronize];
    XCTAssertTrue([USRVPreferences hasKey:uadsTestBoolKey], @"Preferences did not contain previously committed value");
    XCTAssertTrue([USRVPreferences getBoolean:uadsTestBoolKey] , @"Proper bool value was not read from user default");
    XCTAssertNil([USRVPreferences getString:uadsTestNonExistingKey], @"Non-nil value returned for a non-existing key");
}

- (void)testPreferencesGetterTypeCoercion {
    [[NSUserDefaults standardUserDefaults] setValue:@"testString" forKey:uadsTestStringKey];
    [[NSUserDefaults standardUserDefaults] setInteger:12345 forKey:uadsTestIntKey];
    [[NSUserDefaults standardUserDefaults] synchronize];

    XCTAssertTrue([[USRVPreferences getString:uadsTestIntKey] isEqualToString:@"12345"], @"Coercion of int to string failed, should result in \"12345\"");
    XCTAssert([[USRVPreferences getInteger:uadsTestStringKey] intValue] == 0, @"Attempted coercion of invalid string value to integer should result in 0");
}

- (void)testPreferencesBooleanSetter {
    bool testValue = YES;
    XCTAssertFalse([USRVPreferences hasKey:uadsTestBoolKey], @"Preferences contained a key before one was written");
    [USRVPreferences setBoolean:testValue forKey:uadsTestBoolKey];
    XCTAssertEqual([[NSUserDefaults standardUserDefaults] boolForKey:uadsTestBoolKey], testValue, @"Preferences did not contain previously committed value");
}

- (void)testPreferencesFloatSetter {
    float testValue = 1.2345;
    XCTAssertFalse([USRVPreferences hasKey:uadsTestFloatKey], @"Preferences contained a key before one was written");
    [USRVPreferences setFloat:testValue forKey:uadsTestBoolKey];
    XCTAssertEqual([[NSUserDefaults standardUserDefaults] floatForKey:uadsTestBoolKey], testValue, @"Preferences did not contain previously committed value");
}

- (void)testPreferencesLongSetter {
    long testValue = 12345678;
    XCTAssertFalse([USRVPreferences hasKey:uadsTestLongKey], @"Preferences contained a key before one was written");
    [USRVPreferences setLong:testValue forKey:uadsTestLongKey];
    XCTAssertEqual([[[NSUserDefaults standardUserDefaults] objectForKey:uadsTestLongKey] longValue], testValue, @"Preferences did not contain previously committed value");
}

- (void)testPreferencesIntSetter {
    NSInteger testValue = 12345;
    XCTAssertFalse([USRVPreferences hasKey:uadsTestIntKey], @"Preferences contained a key before one was written");
    [USRVPreferences setInteger:[[NSNumber numberWithInteger:testValue] intValue] forKey:uadsTestIntKey];
    XCTAssertEqual([[NSUserDefaults standardUserDefaults] integerForKey:uadsTestIntKey], testValue, @"Preferences did not contain previously committed value");
}

- (void)testPreferencesStringSetter {
    NSString *testValue = @"testString";
    XCTAssertFalse([USRVPreferences hasKey:uadsTestStringKey], @"Preferences contained a key before one was written");
    [USRVPreferences setString:testValue forKey:uadsTestStringKey];
    XCTAssertEqualObjects([[NSUserDefaults standardUserDefaults] objectForKey:uadsTestStringKey], testValue, @"Preferences did not contain previously committed value");
}

- (void)testPreferencesRemoveKey {
    NSString *testKey = @"testKey";
    NSString *testValue = @"testString";
    [USRVPreferences setString:testValue forKey:testKey];
    XCTAssertTrue([USRVPreferences hasKey:testKey], @"Preferences do not have a key that was just written");
    [USRVPreferences removeKey:testKey];
    XCTAssertFalse([USRVPreferences hasKey:testKey], @"Preferences contains a key that was just deleted");
}

@end
