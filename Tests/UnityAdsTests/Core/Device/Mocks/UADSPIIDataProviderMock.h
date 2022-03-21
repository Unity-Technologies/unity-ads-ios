#import <Foundation/Foundation.h>
#import "UADSPIIDataProvider.h"
NS_ASSUME_NONNULL_BEGIN

@interface UADSPIIDataProviderMock : NSObject<UADSPIIDataProvider>
@property (nonatomic, strong) NSString *advertisingTrackingID;
@property (nonatomic, strong) NSString *vendorID;
@end

NS_ASSUME_NONNULL_END
