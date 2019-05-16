

@interface USRVCacheQueue : NSObject

+ (void)start;
+ (BOOL)download:(NSString *)source target:(NSString *)target headers:(NSDictionary<NSString*, NSArray*> *)headers append:(BOOL)append;
+ (void)cancelAllDownloads;
+ (void)setProgressInterval:(int)interval;
+ (int)getProgressInterval;
+ (void)setConnectTimeout:(int)timeout;
+ (int)getConnectTimeout;
+ (BOOL)hasOperations;

@end
