#import "UADSWebRequest.h"

@interface UADSCacheOperation : NSOperation

@property (nonatomic, strong) NSString *source;
@property (nonatomic, strong) NSString *target;
@property (nonatomic, assign) int connectTimeout;
@property (nonatomic, assign) int progressEventInterval;
@property (nonatomic, assign) id progressTimer;
@property (nonatomic, assign) long lastProgressEvent;
@property (nonatomic, assign) long long expectedContentSize;
@property (nonatomic, strong) UADSWebRequest *request;

- (instancetype)initWithSource:(NSString *)source target:(NSString *)target connectTimeout:(int)connectTimeout;
@end