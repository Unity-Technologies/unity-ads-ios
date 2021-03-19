#import "NSInvocationTargetMock.h"
#import "NSInvocation+Convenience.h"
#import <XCTest/XCTest.h>
#import "NSPrimitivesBox.h"
#define TEST_PASSED_VALUE @5
@interface NSInvocationTests : XCTestCase

@end

@implementation NSInvocationTests

- (void)setUp {
    [NSInvocationTargetMock reset];
    // Put setup code here. This method is called before the invocation of each test method in the class.
}

- (void)test_executes_instance_function_with_an_argument {
    NSInvocationTargetMock *mock = [NSInvocationTargetMock new];
    [NSInvocation uads_invokeUsingMethod: @"mockFunctionWithArg:"
                               classType: [NSInvocationTargetMock class]
                                  target: mock
                                    args: @[TEST_PASSED_VALUE]];
    XCTAssertEqualObjects(mock.mockFunctionArgument, TEST_PASSED_VALUE);
}

- (void)test_executes_class_function_with_an_argument {
    [NSInvocation uads_invokeUsingMethod: @"mockFunctionWithArg:"
                               classType: [NSInvocationTargetMock class]
                                  target: nil
                                    args: @[TEST_PASSED_VALUE]];
    XCTAssertEqualObjects(NSInvocationTargetMock.mockFunctionArgument, TEST_PASSED_VALUE);
}


- (void)test_executes_instance_function_with_returned_value_with_an_argument {
    NSInvocationTargetMock *mock = [NSInvocationTargetMock new];
    NSNumber *returnedValue = [NSInvocation uads_invokeWithReturnedUsingMethod: @"getNumberWithArg:"
                                                                     classType: [NSInvocationTargetMock class]
                                                                        target: mock
                                                                          args: @[TEST_PASSED_VALUE]];
    XCTAssertEqualObjects(returnedValue, NSINVOCATION_MOCK_RETURNED_VALUE);
}

- (void)test_executes_class_function_with_returned_value_and_argument {
    NSNumber *returnedValue = [NSInvocation uads_invokeWithReturnedUsingMethod: @"getNumberWithArg:"
                                                                     classType: [NSInvocationTargetMock class]
                                                                        target: nil
                                                                          args: @[TEST_PASSED_VALUE]];
    XCTAssertEqualObjects(returnedValue, NSINVOCATION_MOCK_RETURNED_VALUE);
}

- (void)test_passes_enum_to_the_invocation {
    NSInvocationTargetMock *mock = [NSInvocationTargetMock new];
    NSInvocationTarget arg = NSInvocationTargetArgument1;
    NSPrimitivesBox *box = [NSPrimitivesBox newWithBytes:&arg objCType:@encode(NSInvocationTarget)];
    [NSInvocation uads_invokeUsingMethod: @"mockFunctionWithArg:"
                               classType: [NSInvocationTargetMock class]
                                  target: mock
                                    args: @[box]];
    XCTAssertEqual(mock.enumArgument, arg);
}


- (void)test_invocation_can_call_using_double {
    NSInvocationTargetMock *mock = [NSInvocationTargetMock new];
    double arg = 10.5;
    NSPrimitivesBox *box = [NSPrimitivesBox newWithBytes: &arg objCType: @encode(double)];
    [NSInvocation uads_invokeUsingMethod: @"callWithDouble:"
                               classType: [NSInvocationTargetMock class]
                                  target: mock
                                    args: @[box]];
    XCTAssertEqual(mock.doubleValue, arg);
}


- (void)test_calls_non_existed_selector_on_instance_should_resist_to_crash {
    NSInvocationTargetMock *mock = [NSInvocationTargetMock new];
    [NSInvocation uads_invokeUsingMethod: @"selectorThatDoesntExist:"
                               classType: [NSInvocationTargetMock class]
                                  target: mock
                                    args: @[]];
}


- (void)test_calls_non_existed_selector_on_class_should_resist_to_crash {
    [NSInvocation uads_invokeUsingMethod: @"selectorThatDoesntExist:"
                               classType: [NSInvocationTargetMock class]
                                  target: nil
                                    args: @[]];
}



- (void)test_calls_non_existed_selector_on_instance_should_return_nil {
    NSInvocationTargetMock *mock = [NSInvocationTargetMock new];
    id val = [NSInvocation uads_invokeWithReturnedUsingMethod: @"selectorThatDoesntExist:"
                                                    classType: [NSInvocationTargetMock class]
                                                       target: mock
                                                         args: @[]];
    XCTAssertNil(val);
}


- (void)test_calls_non_existed_selector_on_class_should_return_nil {
    id val = [NSInvocation uads_invokeWithReturnedUsingMethod: @"selectorThatDoesntExist:"
                                                    classType: [NSInvocationTargetMock class]
                                                       target: nil
                                                         args: @[]];
    XCTAssertNil(val);
}



@end
