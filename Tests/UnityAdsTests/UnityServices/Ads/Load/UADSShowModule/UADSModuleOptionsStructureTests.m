#import "UADSTools.h"
#import "UADSShowModuleOperation.h"
#import "UADSLoadModuleOperationObject.h"
#import <XCTest/XCTest.h>
#import "UADSShowModuleOptions.h"
#import "UADSLoadOptions.h"
#import "USRVClientProperties.h"

static NSString *const kFakeObjectID = @"kFakeObjectID";
static NSString *const kFakeOperationID = @"kFakeOperationID";
static NSString *const kFakePlacementID = @"kFakePlacementID";
#define FAKE_TIMESTAMP @10.0

@interface UADSModuleOptionsStructureTests : XCTestCase

@end

@implementation UADSModuleOptionsStructureTests

- (void)test_dictionary_structure_of_show_options {
    NSDictionary *dict = self.defaultShowOperation.dictionary;
    NSDictionary *options = dict[kUADSOptionsDictionaryKey];

    XCTAssertEqualObjects([self.defaultShowOperation methodName], @"show");

    [self validateRootElements: dict];
    [self validateShowHeaderBiddingDictionary: options[kUADSHeaderBiddingOptionsDictionaryKey]];
    [self validateDisplayDictionary: options[kUADSShowModuleStateDisplayOptionsKey]];

    NSLog(@"%@", dict);
}

- (void)test_dictionary_structure_of_load_options {
    NSDictionary *dict = self.defaultLoadOperation.dictionary;
    NSDictionary *headerBiddingDict = dict[kUADSOptionsDictionaryKey];

    XCTAssertEqualObjects([self.defaultLoadOperation methodName], @"load");

    [self validateRootElements: dict];
    [self validateLoadHeaderBiddingDictionary: headerBiddingDict[kUADSHeaderBiddingOptionsDictionaryKey]];

    NSLog(@"%@", dict);
}

- (void)validateRootElements: (NSDictionary *)dict {
    XCTAssertEqualObjects(dict[kUADSTimestampKey], FAKE_TIMESTAMP);
    XCTAssertEqualObjects(dict[kUADSPlacementIDKey], kFakePlacementID);
}

- (void)validateShowHeaderBiddingDictionary: (NSDictionary *)headerBiddingOptions  {
    XCTAssertEqualObjects(headerBiddingOptions[@"objectId"], kFakeObjectID);
}

- (void)validateLoadHeaderBiddingDictionary: (NSDictionary *)headerBiddingOptions  {
    XCTAssertEqualObjects(headerBiddingOptions[@"adMarkup"], kFakeObjectID);
}

- (void)validateDisplayDictionary: (NSDictionary *)displayOptions {
    XCTAssertEqualObjects(displayOptions[kStatusBarHiddenKey],
                          [NSNumber numberWithBool: self.app.isStatusBarHidden]);
    XCTAssertEqualObjects(displayOptions[kStatusBarOrientationKey],
                          [NSNumber numberWithInteger: self.app.statusBarOrientation]);

    XCTAssertEqualObjects(displayOptions[kSupportedOrientationsKey],
                          [NSNumber numberWithInt: [USRVClientProperties getSupportedOrientations]]);

    XCTAssertEqualObjects(displayOptions[kSupportedOrientationsPlistKey],
                          [USRVClientProperties getSupportedOrientationsPlist]);

    XCTAssertEqualObjects(displayOptions[kUADSShowModuleStateRotationKey],
                          [NSNumber numberWithBool: true]);
}

- (UADSShowModuleOperation *)defaultShowOperation {
    UADSShowModuleOperation *operation = [UADSShowModuleOperation new];

    operation.time = FAKE_TIMESTAMP;
    operation.placementID = kFakePlacementID;
    operation.options = self.defaultTestOptions;

    return operation;
}

- (UADSShowModuleOptions *)defaultTestOptions {
    UADSShowOptions *showOptions = [UADSShowOptions new];

    showOptions.objectId = kFakeObjectID;
    UADSShowModuleOptions *wrappedOptions = [UADSShowModuleOptions new];

    wrappedOptions.options = showOptions;
    wrappedOptions.shouldAutorotate = true;
    wrappedOptions.isStatusBarHidden = self.app.isStatusBarHidden;
    wrappedOptions.supportedOrientations = [USRVClientProperties getSupportedOrientations];
    wrappedOptions.statusBarOrientation = self.app.statusBarOrientation;
    wrappedOptions.supportedOrientationsPlist = [USRVClientProperties getSupportedOrientationsPlist];
    return wrappedOptions;
}

- (UADSLoadModuleOperationObject *)defaultLoadOperation {
    UADSLoadOptions *loadOptions = [UADSLoadOptions new];

    loadOptions.adMarkup = kFakeObjectID;
    UADSLoadModuleOperationObject *operation = [UADSLoadModuleOperationObject new];

    operation.time = FAKE_TIMESTAMP;
    operation.placementID = kFakePlacementID;

    operation.options = loadOptions;
    return operation;
}

- (UIApplication *)app {
    return UIApplication.sharedApplication;
}

@end
