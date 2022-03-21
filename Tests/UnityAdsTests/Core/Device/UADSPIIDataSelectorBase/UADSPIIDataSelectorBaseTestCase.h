#import <XCTest/XCTest.h>
#import "UADSPIIDataSelector.h"
#import "UADSJsonStorageReaderMock.h"

#ifndef UADSPIIDataSelectorBaseTestCase_h
#define UADSPIIDataSelectorBaseTestCase_h

@interface UADSPIIDataSelectorBaseTestCase : XCTestCase
@property (nonatomic, strong) UADSJsonStorageReaderMock *jsonReaderMock;
@property (nonatomic, strong) id<UADSPIIDataSelector> sut;
- (id<UADSJsonStorageReader>)      storageReaderForSut;

- (id<UADSPIITrackingStatusReader>)statusReaderForSut;
- (void)                           validateReadNonBehavioralFlagWithExpected: (BOOL)expected;
- (void)                           setExpectedDataFromStorageReader;
- (void)setExpectedPrivacyModeTo: (UADSPrivacyMode)mode
      withUserNonBehaviouralFlag: (BOOL)flag;
- (NSDictionary *)                 expectedPIIContent;
- (NSDictionary *)expectedPIIContentWithBehavioral: (BOOL)expected;

@end
#endif /* UADSPIIDataSelectorBaseTestCase_h */
