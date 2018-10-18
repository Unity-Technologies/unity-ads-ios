@interface USRVPreferences : NSObject
+ (BOOL)hasKey:(NSString *)key;
+ (NSString *)getString:(NSString *)key;
+ (NSNumber *)getInteger:(NSString *)key;
+ (NSNumber *)getLong:(NSString *)key;
+ (NSNumber *)getBoolean:(NSString*)key;
+ (NSNumber *)getFloat:(NSString*)key;
+ (void)setString:(NSString*)value forKey:(NSString*)key;
+ (void)setInteger:(int)value forKey:(NSString*)key;
+ (void)setFloat:(float)value forKey:(NSString*)key;
+ (void)setBoolean:(BOOL)value forKey:(NSString*)key;
+ (void)setLong:(long)value forKey:(NSString*)key;
+ (void)removeKey:(NSString *)key;
@end
