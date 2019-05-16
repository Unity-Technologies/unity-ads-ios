#import "USRVPreferences.h"

@implementation USRVPreferences

+ (BOOL)hasKey:(NSString *)key {
    return [[NSUserDefaults standardUserDefaults] objectForKey:key] != nil;
}

+ (NSString *)getString:(NSString *)key {
    return [[NSUserDefaults standardUserDefaults] stringForKey:key];
}

+ (NSNumber *)getInteger:(NSString *)key {
    return [NSNumber numberWithLong:[[NSUserDefaults standardUserDefaults] integerForKey:key]];
}

+ (NSNumber *)getLong:(NSString *)key {
    return [NSNumber numberWithLong:[[[NSUserDefaults standardUserDefaults] objectForKey:key] longValue]];
}

+ (NSNumber *)getBoolean:(NSString*)key {
    return [NSNumber numberWithBool:[[NSUserDefaults standardUserDefaults] boolForKey:key]];
}

+ (NSNumber *)getFloat:(NSString*)key {
    return [NSNumber numberWithFloat:[[[NSUserDefaults standardUserDefaults] objectForKey:key] floatValue]];
}

+ (void)setString:(NSString*)value forKey:(NSString*)key {
    [[NSUserDefaults standardUserDefaults] setValue:value forKey:key];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

+ (void)setInteger:(int)value forKey:(NSString*)key {
    [[NSUserDefaults standardUserDefaults] setInteger:[[NSNumber numberWithInt:value] integerValue] forKey:key];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

+ (void)setFloat:(float)value forKey:(NSString*)key {
    [[NSUserDefaults standardUserDefaults] setFloat:[[NSNumber numberWithFloat:value] floatValue] forKey:key];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

+ (void)setBoolean:(BOOL)value forKey:(NSString*)key {
    [[NSUserDefaults standardUserDefaults] setInteger:[[NSNumber numberWithBool:value] boolValue] forKey:key];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

+ (void)setLong:(long)value forKey:(NSString*)key {
    [[NSUserDefaults standardUserDefaults] setObject:[NSNumber numberWithLong:value] forKey:key];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

+ (void)removeKey:(NSString *)key {
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:key];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

@end
