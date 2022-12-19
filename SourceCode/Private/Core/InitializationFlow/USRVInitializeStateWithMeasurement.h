#import <Foundation/Foundation.h>
#import "USRVInitializeStateFactory.h"

NS_ASSUME_NONNULL_BEGIN

@interface USRVInitializeStateWithMeasurement : NSObject<USRVInitializeTask>
+(instancetype)newWithOriginal: (id<USRVInitializeTask>)original;
@end

NS_ASSUME_NONNULL_END
