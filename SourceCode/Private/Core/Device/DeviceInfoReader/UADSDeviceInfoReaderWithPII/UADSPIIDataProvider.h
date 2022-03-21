#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN


@protocol UADSPIIDataProvider <NSObject>

- (NSString *)advertisingTrackingID;
- (NSString *)vendorID;

@end

@interface UADSPIIDataProviderBase : NSObject<UADSPIIDataProvider>

@end

NS_ASSUME_NONNULL_END
