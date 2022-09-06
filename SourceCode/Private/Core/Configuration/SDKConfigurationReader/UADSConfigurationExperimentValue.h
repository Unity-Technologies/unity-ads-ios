#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface UADSConfigurationExperimentValue : NSObject
+ (instancetype)newWithKey: (NSString *)key json: (id)value;

@property (nonatomic, assign) BOOL enabled;
@property (nonatomic, assign) BOOL nextSession;

@end

NS_ASSUME_NONNULL_END
