#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@protocol UADSRepeatableTimer <NSObject>

- (void)scheduleWithTimeInterval: (NSTimeInterval)ti repeatCount: (NSInteger)repeat block: (void (^)(NSInteger index))block;
- (void)invalidate;
- (void)pause;
- (void)resume;

@end

@interface UADSTimer : NSObject <UADSRepeatableTimer>
- (void)scheduleWithTimeIntervals: (NSArray *)ti block: (void (^)(NSInteger index))block;
@end

NS_ASSUME_NONNULL_END
