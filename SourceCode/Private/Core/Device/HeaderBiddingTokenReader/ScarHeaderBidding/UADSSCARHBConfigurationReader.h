#ifndef UADSSCARHBConfigurationReader_h
#define UADSSCARHBConfigurationReader_h

#import "UADSSCARHBStrategyType.h"

@protocol UADSSCARHBConfigurationReader <NSObject>

- (UADSSCARHBStrategyType) selectedSCARHBStrategyType;
- (NSString *)getCurrentScarHBURL;
@end

#endif /* UADSSCARHBConfigurationReader_h */
