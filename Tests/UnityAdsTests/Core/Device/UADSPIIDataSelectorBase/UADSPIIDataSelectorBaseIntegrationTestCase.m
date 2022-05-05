#import <XCTest/XCTest.h>
#import "UADSPIIDataSelectorBaseTestCase.h"
#import "USRVJsonStorageAggregator.h"
#import "UADSDeviceTestsHelper.h"
#import "NSDictionary+Merge.h"
#import "UADSJsonStorageKeyNames.h"
@interface UADSPIIDataSelectorBaseIntegrationTestCase : UADSPIIDataSelectorBaseTestCase
@property (nonatomic, strong) UADSDeviceTestsHelper *testHelper;
@end

@implementation UADSPIIDataSelectorBaseIntegrationTestCase

- (void)setUp {
    [super setUp];
    _testHelper = [UADSDeviceTestsHelper new];
    [_testHelper clearAllStorages];
}

- (id<UADSJsonStorageReader>)storageReaderForSut {
    self.jsonReaderMock.original =  [USRVJsonStorageAggregator defaultAggregator];
    return self.jsonReaderMock;
}

- (id<UADSPIITrackingStatusReader>)statusReaderForSut {
    return [UADSPIITrackingStatusReaderBase newWithStorageReader: self.storageReaderForSut];
}

- (void)test_spm_app_mode_takes_over_user_mixed_mode {
    UADSPIIDecisionData *expectedDecision =  [UADSPIIDecisionData newExclude];

    [self runTestWithSPMMode: kUADSPrivacyModeApp
                 andUserMode: kUADSPrivacyModeMixed
          userNonBehavioural: true
          expectAccessToFlag: false
            expectedDecision: expectedDecision];
}

- (void)test_user_app_mode_takes_over_spm_mixed_mode {
    UADSPIIDecisionData *expectedDecision =  [UADSPIIDecisionData newExclude];

    [self runTestWithSPMMode: kUADSPrivacyModeMixed
                 andUserMode: kUADSPrivacyModeApp
          userNonBehavioural: true
          expectAccessToFlag: false
            expectedDecision: expectedDecision];
}

- (void)test_user_mixed_takes_over_spm_none {
    NSDictionary *expectedAttributes = [self appendUserNonBehavioral: true
                                                        toDictionary: @{}];
    UADSPIIDecisionData *expectedDecision =  [UADSPIIDecisionData newIncludeWithAttributes: expectedAttributes];

    [self runTestWithSPMMode: kUADSPrivacyModeNone
                 andUserMode: kUADSPrivacyModeMixed
          userNonBehavioural: true
          expectAccessToFlag: true
            expectedDecision: expectedDecision];
}

- (void)test_spm_mixed_takes_over_user_none {
    NSDictionary *expectedAttributes = [self appendUserNonBehavioral: true
                                                        toDictionary: @{}];
    UADSPIIDecisionData *expectedDecision =  [UADSPIIDecisionData newIncludeWithAttributes: expectedAttributes];

    [self runTestWithSPMMode: kUADSPrivacyModeMixed
                 andUserMode: kUADSPrivacyModeNone
          userNonBehavioural: true
          expectAccessToFlag: true
            expectedDecision: expectedDecision];
}

- (void)test_null_in_modes_allows_tracking {
    UADSPIIDecisionData *expectedDecision =  [UADSPIIDecisionData newIncludeWithAttributes: self.expectedPIIContent];

    [self runTestWithSPMMode: kUADSPrivacyModeNull
                 andUserMode: kUADSPrivacyModeNull
          userNonBehavioural: true
          expectAccessToFlag: false
            expectedDecision: expectedDecision];
}

- (void)setExpectedPrivacyModeTo: (UADSPrivacyMode)mode
      withUserNonBehaviouralFlag: (BOOL)flag {
    if (mode == kUADSPrivacyModeNull) {
        return;
    }

    [_testHelper commitPrivacyMode: mode
                  andNonBehavioral: flag];
}

- (void)setExpectedDataFromStorageReader {
    [_testHelper setPIIDataToStorage];
}

- (void)validateReadNonBehavioralFlagWithExpected: (BOOL)expected {
    BOOL result = [self.jsonReaderMock.requestedKeys containsObject: @"user.nonBehavioral.value"] || [self.jsonReaderMock.requestedKeys containsObject: @"user.nonbehavioral.value"];

    XCTAssertEqual(result, expected);
}

- (NSDictionary *)appendUserNonBehavioral: (BOOL)flag
                             toDictionary: (NSDictionary *)dictionary {
    return [dictionary uads_newdictionaryByMergingWith: @{
                [UADSJsonStorageKeyNames userNonBehavioralFlagKey]: @(flag)
    }];
}

- (NSDictionary *)expectedPIIContent {
    return [_testHelper piiDecisionContentData];
}

- (void)runTestWithSPMMode: (UADSPrivacyMode)spmMode
               andUserMode: (UADSPrivacyMode)userMode
        userNonBehavioural: (BOOL)userNonBehavioural
        expectAccessToFlag: (BOOL)expectAccessToUserFlag
          expectedDecision: (UADSPIIDecisionData *)decisionData {
    [self setExpectedPrivacyModeTo: userMode
        withUserNonBehaviouralFlag : userNonBehavioural];
    [_testHelper setSMPPrivacyMode: spmMode];
    [self setExpectedDataFromStorageReader];

    UADSPIIDecisionData *decision = self.sut.whatToDoWithPII;

    [self validateReadNonBehavioralFlagWithExpected: expectAccessToUserFlag];
    XCTAssertEqual(decision.resultType, decisionData.resultType);
    XCTAssertEqualObjects(decision.attributes, decisionData.attributes);
}

@end
