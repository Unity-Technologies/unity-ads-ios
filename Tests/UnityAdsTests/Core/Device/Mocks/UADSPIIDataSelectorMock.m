#import "UADSPIIDataSelectorMock.h"

@implementation UADSPIIDataSelectorMock

- (nonnull UADSPIIDecisionData *)whatToDoWithPII {
    return _expectedData;
}

@end
