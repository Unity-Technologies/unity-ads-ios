

@interface UADSCacheQueue : NSObject

+ (void)start;
+ (BOOL)download:(NSString *)source target:(NSString *)target;
+ (void)cancelAllDownloads;
+ (void)setProgressInterval:(int)interval;
+ (int)getProgressInterval;
+ (void)setConnectTimeout:(int)timeout;
+ (int)getConnectTimeout;
+ (BOOL)hasOperations;

@end