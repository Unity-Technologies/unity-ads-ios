#import <XCTest/XCTest.h>
#import "UADSPIIDataSelector.h"
#import "UADSFactoryConfigMock.h"
#import "UADSJsonStorageKeyNames.h"
#import "UADSPIITrackingStatusReaderMock.h"
#import "UADSPIIDataSelectorBaseTestCase.h"
#import "NSDictionary+Merge.h"
#import "NSDictionary+Filter.h"
@interface UADSPIIDataSelectorBaseTestCase ()

@property (nonatomic, strong) UADSFactoryConfigMock *configMock;

@property (nonatomic, strong) UADSPIITrackingStatusReaderMock *statusReaderMock;

@end

@implementation UADSPIIDataSelectorBaseTestCase

- (void)setUp {
    self.jsonReaderMock = [UADSJsonStorageReaderMock new];
    self.configMock = [UADSFactoryConfigMock new];
    self.statusReaderMock = [UADSPIITrackingStatusReaderMock new];
    self.sut = [self getSut];
}

- (id<UADSPIIDataSelector>)getSut {
    return [UADSPIIDataSelectorBase newWithJsonStorage: self.storageReaderForSut
                                       andStatusReader: self.statusReaderForSut
                                          andPIIConfig: self.configMock];
}

- (id<UADSJsonStorageReader>)storageReaderForSut {
    return self.jsonReaderMock;
}

- (id<UADSPIITrackingStatusReader>)statusReaderForSut {
    return self.statusReaderMock;
}

- (void)test_should_exclude_pii_if_tracking_is_disabled {
    UADSPIIDecisionData *expectedDecision =  [UADSPIIDecisionData newExclude];

    [self runTestWithUserMode: kUADSPrivacyModeApp
           userNonBehavioural: false
             forcedUpdateFlag: false
           expectAccessToFlag: false
             expectedDecision: expectedDecision];
}

- (void)test_if_mode_is_app_and_forces_is_off_return_include_attributes {
    UADSPIIDecisionData *expectedDecision =  [UADSPIIDecisionData newIncludeWithAttributes: self.expectedPIIContent];

    [self runTestWithUserMode: kUADSPrivacyModeNone
           userNonBehavioural: false
             forcedUpdateFlag: false
           expectAccessToFlag: false
             expectedDecision: expectedDecision];
}

- (void)test_if_flag_is_on_and_mode_is_none_return_update_with_attributes {
    BOOL userBehavioral = true;

    UADSPIIDecisionData *expectedDecision =  [UADSPIIDecisionData newUpdateWithAttributes: self.expectedPIIContent];

    [self runTestWithUserMode: kUADSPrivacyModeNone
           userNonBehavioural: userBehavioral
             forcedUpdateFlag: true
           expectAccessToFlag: false
             expectedDecision: expectedDecision];
}

- (void)test_user_off_force_on_mixed_mode_should_update_with_attributes {
    BOOL userBehavioral = false;

    UADSPIIDecisionData *expectedDecision =  [UADSPIIDecisionData newUpdateWithAttributes: [self expectedPIIContentWithBehavioral: userBehavioral]];

    [self runTestWithUserMode: kUADSPrivacyModeMixed
           userNonBehavioural: userBehavioral
             forcedUpdateFlag: true
           expectAccessToFlag: true
             expectedDecision: expectedDecision];
}

- (void)test_user_off_force_off_mixed_mode_should_include_attributes {
    BOOL userBehavioral = false;

    UADSPIIDecisionData *expectedDecision =  [UADSPIIDecisionData newIncludeWithAttributes: [self expectedPIIContentWithBehavioral: userBehavioral]];

    [self runTestWithUserMode: kUADSPrivacyModeMixed
           userNonBehavioural: userBehavioral
             forcedUpdateFlag: false
           expectAccessToFlag: true
             expectedDecision: expectedDecision];
}

- (void)test_no_privacy_set_should_flag_on_should_include_value {
    UADSPIIDecisionData *expectedDecision =  [UADSPIIDecisionData newIncludeWithAttributes: self.expectedPIIContent];

    [self runTestWithUserMode: kUADSPrivacyModeNull
           userNonBehavioural: false
             forcedUpdateFlag: false
           expectAccessToFlag: false
             expectedDecision: expectedDecision];
}

- (void)test_user_on_force_off_mixed_mode_should_exclude_pii_attributes_while_sending_nonbehavioural {
    BOOL userBehavioral = true;
    UADSPIIDecisionData *expectedDecision =  [UADSPIIDecisionData newIncludeWithAttributes: @{
                                                  [UADSJsonStorageKeyNames userNonBehavioralFlagKey]: @(userBehavioral)
    }];

    [self runTestWithUserMode: kUADSPrivacyModeMixed
           userNonBehavioural: userBehavioral
             forcedUpdateFlag: false
           expectAccessToFlag: true
             expectedDecision: expectedDecision];
}

- (void)test_if_flag_is_on_and_mode_is_undefined_exclude {
    UADSPIIDecisionData *expectedDecision =  [UADSPIIDecisionData newExclude];

    [self runTestWithUserMode: kUADSPrivacyModeUndefined
           userNonBehavioural: true
             forcedUpdateFlag: true
           expectAccessToFlag: false
             expectedDecision: expectedDecision];
}

- (void)setExpectedDataFromStorageReader {
    self.jsonReaderMock.expectedContent = self.expectedDataFromStorage;
}

- (void)validateReadNonBehavioralFlagWithExpected: (BOOL)expected {
    XCTAssertEqual(_statusReaderMock.userBehavioralCount > 0, expected);
}

- (void)setExpectedPrivacyModeTo: (UADSPrivacyMode)mode
      withUserNonBehaviouralFlag: (BOOL)flag {
    self.statusReaderMock.expectedUserBehaviouralFlag = flag;
    self.statusReaderMock.expectedMode = mode;
}

- (void)runTestWithUserMode: (UADSPrivacyMode)userMode
         userNonBehavioural: (BOOL)userNonBehavioural
           forcedUpdateFlag: (BOOL)forceUpdate
         expectAccessToFlag: (BOOL)expectAccessToUserFlag
           expectedDecision: (UADSPIIDecisionData *)expectedDecisionData {
    [self setExpectedPrivacyModeTo: userMode
        withUserNonBehaviouralFlag : userNonBehavioural];
    [self setExpectedDataFromStorageReader];
    self.configMock.isForcedUpdatePIIEnabled = forceUpdate;
    UADSPIIDecisionData *decision = self.sut.whatToDoWithPII;

    [self validateReadNonBehavioralFlagWithExpected: expectAccessToUserFlag];
    XCTAssertEqual(decision.resultType, expectedDecisionData.resultType);
    XCTAssertEqualObjects(decision.attributes, expectedDecisionData.attributes);
}

- (NSDictionary *)expectedDataFromStorage {
    return @{
        self.rootKey: self.piiContentForStorage
    };
}

- (NSDictionary *)piiContentForStorage {
    return @{
        @"key1": @"value1",
    };
}

- (NSDictionary *)expectedPIIContent {
    return [self.piiContentForStorage uads_mapKeys:^id _Nonnull (id _Nonnull key) {
        return [UADSJsonStorageKeyNames attributeKeyForPIIContainer: key];
    }];
}

- (NSDictionary *)expectedPIIContentWithBehavioral: (BOOL)expected {
    return [self.expectedPIIContent uads_newdictionaryByMergingWith: @{
                [UADSJsonStorageKeyNames userNonBehavioralFlagKey]: @(expected)
    }];
}

- (NSString *)rootKey {
    return [UADSJsonStorageKeyNames piiContainerKey];
}

@end
