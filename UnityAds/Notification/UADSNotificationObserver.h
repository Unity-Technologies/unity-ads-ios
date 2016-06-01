

@interface UADSNotificationObserver : NSObject

+ (void)addObserver:(NSString *)name userInfoKeys:(NSArray *)keys;

+ (void)removeObserver:(NSString *)name;

+ (void)unregisterNotificationObserver;

@end
