#import <Foundation/Foundation.h>
#import "GADQueryInfoBridge.h"
NS_ASSUME_NONNULL_BEGIN

@interface GMAAdMetaData : NSObject
@property (nonatomic) GADQueryInfoAdType type;
@property (nonatomic, copy) NSString *placementID;
@property (nonatomic, copy) NSString *adString;
@property (nonatomic, copy) NSString *adUnitID;
@property (nonatomic, copy) NSString *queryID;
@property (nonatomic, strong) NSNumber *videoLength;

- (NSTimeInterval)videoLengthInSeconds;
@end

NS_ASSUME_NONNULL_END
