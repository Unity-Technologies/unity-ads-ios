#import <Foundation/Foundation.h>
#import "UADSIdStore.h"

NS_ASSUME_NONNULL_BEGIN

@interface UADSUserDefaultsStore : NSObject <UADSIdStore>

- (instancetype)initWithKey:(NSString *)key;

@end

NS_ASSUME_NONNULL_END
