#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@protocol UADSIdStore

- (NSString *_Nullable)getValue;

- (void)commitValue:(NSString *)value;

@end

NS_ASSUME_NONNULL_END
