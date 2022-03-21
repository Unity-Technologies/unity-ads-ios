#import <XCTest/XCTest.h>
#import "UnityAdsTests-Bridging-Header.h"
#import "UADSMediationMetaData.h"

@interface NSDictionaryMergeTests : XCTestCase
@end

@implementation NSDictionaryMergeTests

- (void)testMergeDictionary {
    NSMutableDictionary *objectOne = [[NSMutableDictionary alloc] init];
    NSMutableDictionary *objectOneSub = [[NSMutableDictionary alloc] init];
    NSMutableDictionary *objectOneSubSub = [[NSMutableDictionary alloc] init];
    NSMutableDictionary *objectOneSubSubSub = [[NSMutableDictionary alloc] init];

    [objectOneSubSubSub setValue: [NSNumber numberWithInt: 111]
                          forKey: @"subsubone"];
    [objectOneSubSub setValue: [NSNumber numberWithInt: 11]
                       forKey: @"subone"];
    [objectOneSubSub setValue: objectOneSubSubSub
                       forKey: @"sub"];
    [objectOneSub setValue: [NSNumber numberWithInt: 1]
                    forKey: @"one"];
    [objectOneSub setValue: objectOneSubSub
                    forKey: @"sub"];
    [objectOneSub setValue: @"primary"
                    forKey: @"override"];
    [objectOne setValue: objectOneSub
                 forKey: @"test"];

    NSMutableDictionary *objectTwo = [[NSMutableDictionary alloc] init];
    NSMutableDictionary *objectTwoSub = [[NSMutableDictionary alloc] init];
    NSMutableDictionary *objectTwoSubSub = [[NSMutableDictionary alloc] init];
    NSMutableDictionary *objectTwoSubSubSub = [[NSMutableDictionary alloc] init];

    [objectTwoSubSubSub setValue: [NSNumber numberWithInt: 222]
                          forKey: @"subsubtwo"];
    [objectTwoSubSub setValue: [NSNumber numberWithInt: 22]
                       forKey: @"subtwo"];
    [objectTwoSubSub setValue: objectTwoSubSubSub
                       forKey: @"sub"];
    [objectTwoSub setValue: [NSNumber numberWithInt: 2]
                    forKey: @"two"];
    [objectTwoSub setValue: objectTwoSubSub
                    forKey: @"sub"];
    [objectTwoSub setValue: @"secondary"
                    forKey: @"override"];
    [objectTwo setValue: objectTwoSub
                 forKey: @"test"];

    NSDictionary *merged = [NSDictionary unityads_dictionaryByMerging: objectOne
                                                            secondary: objectTwo];

    NSLog(@"%@", merged);

    XCTAssertEqualObjects([NSNumber numberWithInt: 111], [[[[merged valueForKey: @"test"] valueForKey: @"sub"] valueForKey: @"sub"] valueForKey: @"subsubone"], @"Incorrect 'subsubone' value");
    XCTAssertEqualObjects([NSNumber numberWithInt: 11], [[[merged valueForKey: @"test"] valueForKey: @"sub"] valueForKey: @"subone"], @"Incorrect 'subone' value");
    XCTAssertEqualObjects([NSNumber numberWithInt: 1], [[merged valueForKey: @"test"] valueForKey: @"one"], @"Incorrect 'one' value");

    XCTAssertEqualObjects([NSNumber numberWithInt: 222], [[[[merged valueForKey: @"test"] valueForKey: @"sub"] valueForKey: @"sub"] valueForKey: @"subsubtwo"], @"Incorrect 'subsubtwo' value");
    XCTAssertEqualObjects([NSNumber numberWithInt: 22], [[[merged valueForKey: @"test"] valueForKey: @"sub"] valueForKey: @"subtwo"], @"Incorrect 'subtwo' value");
    XCTAssertEqualObjects([NSNumber numberWithInt: 2], [[merged valueForKey: @"test"] valueForKey: @"two"], @"Incorrect 'two' value");

    XCTAssertEqualObjects(@"primary", [[merged valueForKey: @"test"] valueForKey: @"override"]);
} /* testMergeDictionary */

- (void)testDeepCopy {
    NSDictionary *innerDict = @{ @"1.1": @"one", @"1.2": @{ @"2": @"two" } };
    NSMutableDictionary *dict = [@{ @"1": innerDict } mutableCopy];
    NSDictionary *dict2 = [dict deepCopy];

    XCTAssertEqualObjects(dict, dict2);

    dict[@"1"] = @{ @"2": @"new" };

    XCTAssertNotEqualObjects(dict, dict2);
    XCTAssertEqualObjects(dict2[@"1"], innerDict);


    NSMutableArray *original = [@[@"1", @"2", @"3"] mutableCopy];
    NSArray *deepCopy = [original deepCopy];

    XCTAssertEqualObjects(original, deepCopy);

    original[0] = @"4";

    XCTAssertNotEqualObjects(original, deepCopy);
    XCTAssertEqualObjects(deepCopy[0], @"1");
}

- (void)test_flat_nested_dictionary_nothing_excluded {
    NSDictionary *result = [self.testDataSet uads_flatUsingSeparator: @"."
                                                 includeTopLevelKeys: @[]
                                                       andReduceKeys: @[]
                                                         andSkipKeys: @[]];

    XCTAssertEqualObjects(result, self.expectedFlattenDataSet);
}

- (void)test_flat_nested_dictionary_nothing_excludes_keys {
    NSDictionary *result = [self.testDataSet uads_flatUsingSeparator: @"."
                                                 includeTopLevelKeys: @[]
                                                       andReduceKeys: @[]
                                                         andSkipKeys: @[@"ts"]];

    XCTAssertEqualObjects(result, self.expectedFlattenDataSetExcludeTS);
}

- (void)test_flat_nested_dictionary_nothing_excludes_keys_and_reduce_and_filters {
    NSDictionary *result = [self.testDataSet uads_flatUsingSeparator: @"."
                                                 includeTopLevelKeys: @[@"mediation"]
                                                       andReduceKeys: @[@"value"]
                                                         andSkipKeys: @[@"ts"]];

    XCTAssertEqualObjects(result, self.expectedFlattenDataSetReduced);
}

- (NSDictionary *)expectedFlattenDataSetExcludeTS {
    return @{
        @"mediation.adapterVersion.value": @"adapter_version",
        @"mediation.name.value": @"Mediation name",
        @"mediation.version.value": @"version",

        @"framework.name.value": @"name",
        @"framework.version.value": @"version",
    };
}

- (NSDictionary *)expectedFlattenDataSetReduced {
    return @{
        @"mediation.adapterVersion": @"adapter_version",
        @"mediation.name": @"Mediation name",
        @"mediation.version": @"version",
    };
}

- (NSDictionary *)expectedFlattenDataSet {
    return @{
        @"mediation.adapterVersion.value": @"adapter_version",
        @"mediation.name.value": @"Mediation name",
        @"mediation.version.value": @"version",

        @"mediation.adapterVersion.ts": @(1642615489109),
        @"mediation.name.ts": @(1642615489109),
        @"mediation.version.ts": @(1642615489109),

        @"framework.name.ts": @(1642615489109),
        @"framework.name.value": @"name",
        @"framework.version.ts": @(1642615489109),
        @"framework.version.value": @"version",
    };
}

- (NSDictionary *)testDataSet {
    return @{
        @"mediation": @{
            @"adapterVersion": @{
                @"ts": @(1642615489109),
                @"value": @"adapter_version"
            },

            @"name": @{
                @"ts":  @(1642615489109),
                @"value": @"Mediation name"
            },
            @"version": @{
                @"ts": @(1642615489109),
                @"value": @"version"
            }
        },
        @"framework": @{
            @"name": @{
                @"ts":  @(1642615489109),
                @"value": @"name"
            },
            @"version": @{
                @"ts": @(1642615489109),
                @"value": @"version"
            }
        },
    };
}

@end
