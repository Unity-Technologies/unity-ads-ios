#import <Foundation/Foundation.h>
#import "UADSPIIDataSelector.h"
NS_ASSUME_NONNULL_BEGIN

@interface UADSPIIDataSelectorMock : NSObject<UADSPIIDataSelector>
@property (nonatomic, strong) UADSPIIDecisionData *expectedData;
@end

NS_ASSUME_NONNULL_END
