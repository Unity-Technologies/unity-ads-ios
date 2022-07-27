#import <Foundation/Foundation.h>
#import "UADSLogRecord.h"
#import "UADSTools.h"
NS_ASSUME_NONNULL_BEGIN

@protocol UADSLogger <NSObject>
@property (nonatomic, assign) UADSLogLevel currentLogLevel;
- (void)logRecord: (id<UADSLogRecord>)record;
@end

@interface UADSConsoleLogger : NSObject<UADSLogger>
@property (nonatomic, assign) UADSLogLevel currentLogLevel;
+ (instancetype)newWithSystemList: (NSArray<NSString *> *)allowedList;
@end

NS_ASSUME_NONNULL_END
