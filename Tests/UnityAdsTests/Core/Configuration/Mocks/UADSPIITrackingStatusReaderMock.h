#import <Foundation/Foundation.h>
#import "UADSPIITrackingStatusReader.h"

NS_ASSUME_NONNULL_BEGIN

@interface UADSPIITrackingStatusReaderMock : NSObject<UADSPIITrackingStatusReader>
@property (nonatomic, assign) BOOL expectedUserBehaviouralFlag;
@property (nonatomic, assign) UADSPrivacyMode expectedMode;
@property (nonatomic) NSInteger userBehavioralCount;
@end

NS_ASSUME_NONNULL_END
