

@interface USRVNotificationObserver : NSObject

+ (void)addObserver:(NSString *)name userInfoKeys:(NSArray *)keys targetObject:(id)targetObject;

+ (void)removeObserver:(NSString *)name targetObject:(id)targetObject;

+ (void)unregisterNotificationObserver;

@end
