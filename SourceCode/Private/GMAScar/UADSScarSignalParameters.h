#import <Foundation/Foundation.h>
#import "GADQueryInfoBridge.h"

NS_ASSUME_NONNULL_BEGIN

@interface UADSScarSignalParameters: NSObject
@property (nonatomic, assign) GADQueryInfoAdType adFormat;
@property (nonatomic, strong) NSString *placementId;

- (instancetype)initWithPlacementId: (NSString *)placementId
                           adFormat: (GADQueryInfoAdType)adFormat;


@end

NS_ASSUME_NONNULL_END
