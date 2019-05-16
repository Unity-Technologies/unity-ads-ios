#import <XCTest/XCTest.h>
#import "UnityAdsTests-Bridging-Header.h"

@interface NSDictionaryMergeTests : XCTestCase
@end

@implementation NSDictionaryMergeTests

- (void)testMergeDictionary {
    NSMutableDictionary *objectOne = [[NSMutableDictionary alloc] init];
    NSMutableDictionary *objectOneSub = [[NSMutableDictionary alloc] init];
    NSMutableDictionary *objectOneSubSub = [[NSMutableDictionary alloc] init];
    NSMutableDictionary *objectOneSubSubSub = [[NSMutableDictionary alloc] init];
    
    [objectOneSubSubSub setValue:[NSNumber numberWithInt:111] forKey:@"subsubone"];
    [objectOneSubSub setValue:[NSNumber numberWithInt:11] forKey:@"subone"];
    [objectOneSubSub setValue:objectOneSubSubSub forKey:@"sub"];
    [objectOneSub setValue:[NSNumber numberWithInt:1] forKey:@"one"];
    [objectOneSub setValue:objectOneSubSub forKey:@"sub"];
    [objectOneSub setValue:@"primary" forKey:@"override"];
    [objectOne setValue:objectOneSub forKey:@"test"];
    
    NSMutableDictionary *objectTwo = [[NSMutableDictionary alloc] init];
    NSMutableDictionary *objectTwoSub = [[NSMutableDictionary alloc] init];
    NSMutableDictionary *objectTwoSubSub = [[NSMutableDictionary alloc] init];
    NSMutableDictionary *objectTwoSubSubSub = [[NSMutableDictionary alloc] init];
    
    [objectTwoSubSubSub setValue:[NSNumber numberWithInt:222] forKey:@"subsubtwo"];
    [objectTwoSubSub setValue:[NSNumber numberWithInt:22] forKey:@"subtwo"];
    [objectTwoSubSub setValue:objectTwoSubSubSub forKey:@"sub"];
    [objectTwoSub setValue:[NSNumber numberWithInt:2] forKey:@"two"];
    [objectTwoSub setValue:objectTwoSubSub forKey:@"sub"];
    [objectTwoSub setValue:@"secondary" forKey:@"override"];
    [objectTwo setValue:objectTwoSub forKey:@"test"];
    
    NSDictionary *merged = [NSDictionary dictionaryByMerging:objectOne secondary:objectTwo];
    
    NSLog(@"%@", merged);
    
    XCTAssertEqualObjects([NSNumber numberWithInt:111], [[[[merged valueForKey:@"test"] valueForKey:@"sub"] valueForKey:@"sub"] valueForKey:@"subsubone"], @"Incorrect 'subsubone' value");
    XCTAssertEqualObjects([NSNumber numberWithInt:11], [[[merged valueForKey:@"test"] valueForKey:@"sub"] valueForKey:@"subone"], @"Incorrect 'subone' value");
    XCTAssertEqualObjects([NSNumber numberWithInt:1], [[merged valueForKey:@"test"] valueForKey:@"one"], @"Incorrect 'one' value");
    
    XCTAssertEqualObjects([NSNumber numberWithInt:222], [[[[merged valueForKey:@"test"] valueForKey:@"sub"] valueForKey:@"sub"] valueForKey:@"subsubtwo"], @"Incorrect 'subsubtwo' value");
    XCTAssertEqualObjects([NSNumber numberWithInt:22], [[[merged valueForKey:@"test"] valueForKey:@"sub"] valueForKey:@"subtwo"], @"Incorrect 'subtwo' value");
    XCTAssertEqualObjects([NSNumber numberWithInt:2], [[merged valueForKey:@"test"] valueForKey:@"two"], @"Incorrect 'two' value");
    
    XCTAssertEqualObjects(@"primary", [[merged valueForKey:@"test"] valueForKey:@"override"]);

}

@end
