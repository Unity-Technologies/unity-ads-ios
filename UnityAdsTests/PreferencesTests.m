#import <XCTest/XCTest.h>
#import "UnityAdsTests-Bridging-Header.h"
#import "UADSPreferences.h"

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
    XCTAssertFalse([UADSPreferences hasKey:uadsTestStringKey], @"Preferences contained a key before one was written");
    [[NSUserDefaults standardUserDefaults] setValue:testValue forKey:uadsTestStringKey];
    [[NSUserDefaults standardUserDefaults] synchronize];
    XCTAssertTrue([UADSPreferences hasKey:uadsTestStringKey], @"Preferences did not contain previously committed value");
    XCTAssertTrue([[UADSPreferences getString:uadsTestStringKey] isEqualToString:testValue], @"Proper string value was not read from user default");
    XCTAssertNil([UADSPreferences getString:uadsTestNonExistingKey], @"Non-nil value returned for a non-existing key");
}

- (void)testPreferencesIntGetter {
    NSInteger testValue = 12345;
    XCTAssertFalse([UADSPreferences hasKey:uadsTestIntKey], @"Preferences contained a key before one was written");
    [[NSUserDefaults standardUserDefaults] setValue:[NSNumber numberWithInteger:testValue] forKey:uadsTestIntKey];
    [[NSUserDefaults standardUserDefaults] synchronize];
    XCTAssertTrue([UADSPreferences hasKey:uadsTestIntKey], @"Preferences did not contain previously committed value");
    XCTAssertTrue([[UADSPreferences getInteger:uadsTestIntKey] integerValue] == testValue , @"Proper int value was not read from user default");
    XCTAssertNil([UADSPreferences getString:uadsTestNonExistingKey], @"Non-nil value returned for a non-existing key");
}

- (void)testPreferencesLongGetter {
    long testValue = 12345678;
    XCTAssertFalse([UADSPreferences hasKey:uadsTestLongKey], @"Preferences contained a key before one was written");
    [[NSUserDefaults standardUserDefaults] setValue:[NSNumber numberWithLong:testValue] forKey:uadsTestLongKey];
    [[NSUserDefaults standardUserDefaults] synchronize];
    XCTAssertTrue([UADSPreferences hasKey:uadsTestLongKey], @"Preferences did not contain previously committed value");
    XCTAssertTrue([[UADSPreferences getLong:uadsTestLongKey] longValue] == testValue , @"Proper long value was not read from user default");
    XCTAssertNil([UADSPreferences getString:uadsTestNonExistingKey], @"Non-nil value returned for a non-existing key");
}

- (void)testPreferencesFloatGetter {
    float testValue = 1.2345;
    XCTAssertFalse([UADSPreferences hasKey:uadsTestFloatKey], @"Preferences contained a key before one was written");
    [[NSUserDefaults standardUserDefaults] setValue:[NSNumber numberWithFloat:testValue] forKey:uadsTestFloatKey];
    [[NSUserDefaults standardUserDefaults] synchronize];
    XCTAssertTrue([UADSPreferences hasKey:uadsTestFloatKey], @"Preferences did not contain previously committed value");
    XCTAssertTrue([[UADSPreferences getFloat:uadsTestFloatKey] floatValue] == testValue , @"Proper float value was not read from user default");
    XCTAssertNil([UADSPreferences getString:uadsTestNonExistingKey], @"Non-nil value returned for a non-existing key");
}

- (void)testPreferencesBooleanGetter {
    bool testValue = YES;
    XCTAssertFalse([UADSPreferences hasKey:uadsTestBoolKey], @"Preferences contained a key before one was written");
    [[NSUserDefaults standardUserDefaults] setValue:[NSNumber numberWithBool:testValue] forKey:uadsTestBoolKey];
    [[NSUserDefaults standardUserDefaults] synchronize];
    XCTAssertTrue([UADSPreferences hasKey:uadsTestBoolKey], @"Preferences did not contain previously committed value");
    XCTAssertTrue([UADSPreferences getBoolean:uadsTestBoolKey] , @"Proper bool value was not read from user default");
    XCTAssertNil([UADSPreferences getString:uadsTestNonExistingKey], @"Non-nil value returned for a non-existing key");
}

- (void)testPreferencesGetterTypeCoercion {
    [[NSUserDefaults standardUserDefaults] setValue:@"testString" forKey:uadsTestStringKey];
    [[NSUserDefaults standardUserDefaults] setInteger:12345 forKey:uadsTestIntKey];
    [[NSUserDefaults standardUserDefaults] synchronize];

    XCTAssertTrue([[UADSPreferences getString:uadsTestIntKey] isEqualToString:@"12345"], @"Coercion of int to string failed, should result in \"12345\"");
    XCTAssert([[UADSPreferences getInteger:uadsTestStringKey] intValue] == 0, @"Attempted coercion of invalid string value to integer should result in 0");
}

- (void)testPreferencesBooleanSetter {
    bool testValue = YES;
    XCTAssertFalse([UADSPreferences hasKey:uadsTestBoolKey], @"Preferences contained a key before one was written");
    [UADSPreferences setBoolean:testValue forKey:uadsTestBoolKey];
    XCTAssertEqual([[NSUserDefaults standardUserDefaults] boolForKey:uadsTestBoolKey], testValue, @"Preferences did not contain previously committed value");
}

- (void)testPreferencesFloatSetter {
    float testValue = 1.2345;
    XCTAssertFalse([UADSPreferences hasKey:uadsTestFloatKey], @"Preferences contained a key before one was written");
    [UADSPreferences setFloat:testValue forKey:uadsTestBoolKey];
    XCTAssertEqual([[NSUserDefaults standardUserDefaults] floatForKey:uadsTestBoolKey], testValue, @"Preferences did not contain previously committed value");
}

- (void)testPreferencesLongSetter {
    long testValue = 12345678;
    XCTAssertFalse([UADSPreferences hasKey:uadsTestLongKey], @"Preferences contained a key before one was written");
    [UADSPreferences setLong:testValue forKey:uadsTestLongKey];
    XCTAssertEqual([[[NSUserDefaults standardUserDefaults] objectForKey:uadsTestLongKey] longValue], testValue, @"Preferences did not contain previously committed value");
}

- (void)testPreferencesIntSetter {
    NSInteger testValue = 12345;
    XCTAssertFalse([UADSPreferences hasKey:uadsTestIntKey], @"Preferences contained a key before one was written");
    [UADSPreferences setInteger:[[NSNumber numberWithInteger:testValue] intValue] forKey:uadsTestIntKey];
    XCTAssertEqual([[NSUserDefaults standardUserDefaults] integerForKey:uadsTestIntKey], testValue, @"Preferences did not contain previously committed value");
}

- (void)testPreferencesStringSetter {
    NSString *testValue = @"testString";
    XCTAssertFalse([UADSPreferences hasKey:uadsTestStringKey], @"Preferences contained a key before one was written");
    [UADSPreferences setString:testValue forKey:uadsTestStringKey];
    XCTAssertEqualObjects([[NSUserDefaults standardUserDefaults] objectForKey:uadsTestStringKey], testValue, @"Preferences did not contain previously committed value");
}

- (void)testPreferencesRemoveKey {
    NSString *testKey = @"testKey";
    NSString *testValue = @"testString";
    [UADSPreferences setString:testValue forKey:testKey];
    XCTAssertTrue([UADSPreferences hasKey:testKey], @"Preferences do not have a key that was just written");
    [UADSPreferences removeKey:testKey];
    XCTAssertFalse([UADSPreferences hasKey:testKey], @"Preferences contains a key that was just deleted");
}

@end
