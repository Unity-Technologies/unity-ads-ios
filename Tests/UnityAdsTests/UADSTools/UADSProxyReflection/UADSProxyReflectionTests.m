#import <XCTest/XCTest.h>
#import "NSPrimitivesBox.h"
#import "UADSProxyReflectionMock.h"
#import "UADSNullInitializedMock.h"
#import "UADSBridgeMock.h"

NSString *const TEST_VALUE = @"TEST_STRING";

@interface UADSProxyReflectionTests : XCTestCase
@property (nonatomic, strong) UADSProxyReflectionMock *sut;
@property (nonatomic, strong) UADSProxyReflection *sutEmpty;
@end

@implementation UADSProxyReflectionTests

- (void)setUp {
    _sut = [UADSProxyReflectionMock getProxyWithObject: TEST_VALUE];
    _sutEmpty = [UADSProxyReflection getProxyWithObject: TEST_VALUE];
}

- (void)tearDown {
    [UADSBridgeMock setMockKeys: @[]];
    [UADSBridgeMock setMockSelectors: @[]];
}

- (void)test_returns_proper_class_nsstring {
    XCTAssertEqualObjects([NSMutableArray class], [UADSProxyReflectionMock getClass]);
}

- (void)test_returns_nil_for_unavailable {
    XCTAssertNil([UADSProxyReflection getClass]);
}

- (void)test_returns_exist_for_available_class {
    XCTAssertTrue([UADSProxyReflectionMock exists]);
}

- (void)test_returns_non_exist_for_available_class {
    XCTAssertFalse([UADSProxyReflection exists]);
}

- (void)test_can_initialize_using_reflection_class_method {
    XCTAssertEqualObjects(self.defaultMock.proxyObject, @[TEST_VALUE]);
}

- (void)test_calls_method_without_arguments_using_reflection_api {
    UADSProxyReflectionMock *newObject = self.defaultMock;

    [newObject callInstanceMethod: @"removeAllObjects"
                             args: @[]];
    XCTAssertEqualObjects(newObject.proxyObject, @[]);
}

- (void)test_calls_method_value_for_key {
    UADSBridgeMock *newObject = [UADSBridgeMock createDefault];
    NSString *obj = [newObject nonExistingKVO];

    XCTAssertNil(obj);
}

- (void)test_calls_non_existed_method {
    NSString *newObject = (NSString *)self.defaultMock;

    XCTAssertEqual(newObject.intValue, 0);
}

- (void)test_calls_method_with_arguments_using_reflection_api {
    UADSProxyReflectionMock *newObject = self.defaultMock;
    NSInteger value = 0;
    NSPrimitivesBox *index = [NSPrimitivesBox newWithBytes: &value
                                                  objCType: @encode(NSInteger)];

    [newObject callInstanceMethod: @"removeObjectAtIndex:"
                             args: @[index]];
    XCTAssertEqualObjects(newObject.proxyObject, @[]);
}

- (void)test_proxy_returns_same_result {
    NSNumber *numberOne = @1;
    id proxy = [UADSProxyReflectionMock getProxyWithObject: numberOne];

    XCTAssertEqualObjects([numberOne stringValue],
                          [proxy stringValue],
                          @"proxy MUST return same result as object");
}

- (void)test_exist_returns_true_if_selector_is_present {
    [UADSBridgeMock setMockSelectors: @[@"fakeSelectorToTest"] ];
    XCTAssertTrue(UADSBridgeMock.exists);
}

- (void)test_exist_returns_false_if_selector_is_present {
    [UADSBridgeMock setMockSelectors: @[@"fakeSelectorToTest", @"selector_is_not_present"] ];
    XCTAssertFalse(UADSBridgeMock.exists);
}

- (void)test_exist_returns_true_if_a_property_is_present {
    [UADSBridgeMock setMockKeys: @[@"testValue"] ];
    XCTAssertTrue(UADSBridgeMock.exists);
}

- (void)test_exist_returns_false_if_a_property_is_not_present {
    [UADSBridgeMock setMockKeys: @[@"value_not_present"] ];
    XCTAssertFalse(UADSBridgeMock.exists);
}

- (void)test_should_not_crash_or_go_into_the_loop_if_value_for_key_is_not_supported {
    UADSProxyReflection *object = [UADSProxyReflection getProxyWithObject: [NSArray new]];

    XCTAssertEqualObjects([object valueForKey: @"This selector doesnt exist"], nil);
}

- (void)test_value_for_key_passes_to_proxy_object_and_returns_value {
    UADSBridgeMock *newObject = [UADSBridgeMock createDefault];
    id proxy = [UADSProxyReflectionMock getProxyWithObject: newObject];

    XCTAssertEqualObjects([proxy valueForKey: @"testValue"],
                          @"TEST_VALUE");
}

- (void)test_initialize_returns_nil_when_reflected_init_returns_nil {
    id obj = [UADSNullInitializedReflectionMock getInstanceUsingMethod: @"init"
                                                                  args: @[]];

    XCTAssertNil(obj);
}

- (void)test_initialize_returns_object_when_initialized_reflectively {
    id obj = [UADSNSObjectReflectionMock getInstanceUsingMethod: @"init"
                                                           args: @[]];

    XCTAssertNotNil(obj);
}

- (void)test_initialize_doesnt_cause_memory_leak_object_when_initialized_reflectively {
    // Autorelease pool is required to force deallocation of the object
    @autoreleasepool {
        [UADSNSObjectReflectionMock getInstanceUsingMethod: @"init"
                                                      args: @[]];
    }
    XCTAssertEqualObjects(UADSNSObjectReflectionMock.proxyDeallocationCount, @1);
}

- (UADSProxyReflectionMock *)defaultMock {
    return [UADSProxyReflectionMock getInstanceUsingClassMethod: @"arrayWithObject:"
                                                           args: @[TEST_VALUE]];
}

@end
