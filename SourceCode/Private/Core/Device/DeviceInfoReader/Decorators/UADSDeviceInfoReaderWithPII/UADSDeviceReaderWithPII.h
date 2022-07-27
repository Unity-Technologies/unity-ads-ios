#import <UIKit/UIKit.h>
#import "UADSDeviceInfoReader.h"
#import "UADSPIIDataProvider.h"
#import "UADSPIIDataSelector.h"
#import "USRVJsonStorage.h"
NS_ASSUME_NONNULL_BEGIN

@interface UADSDeviceReaderWithPII : NSObject<UADSDeviceInfoReader>
+ (id<UADSDeviceInfoReader>)newWithOriginal: (id<UADSDeviceInfoReader>)original
                            andDataProvider: (id<UADSPIIDataProvider>)dataProvider
                         andPIIDataSelector: (id<UADSPIIDataSelector>)dataSelector
                             andJsonStorage: (id<UADSJsonStorageReader>)jsonStorage;
@end

NS_ASSUME_NONNULL_END
