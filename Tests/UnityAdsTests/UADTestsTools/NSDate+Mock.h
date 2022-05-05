#import <Foundation/Foundation.h>

@interface NSDate (Mock)
+ (instancetype)  date;
+ (NSTimeInterval)currentTimeInterval;
+ (void)          setMockDate: (BOOL)mock;
@end
