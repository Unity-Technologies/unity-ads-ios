#import "UADSWebViewCallback.h"
#import "UADSApiPreferences.h"
#import "UADSPreferencesError.h"
#import "UADSPreferences.h"

@implementation UADSApiPreferences

+ (void)WebViewExposed_hasKey:(NSString *)key callback:(UADSWebViewCallback *)callback {
    [callback invoke:[NSNumber numberWithBool:[UADSPreferences hasKey:key]], nil];
}

+ (void)WebViewExposed_getString:(NSString *)key callback:(UADSWebViewCallback *)callback {
    NSString *preferenceValue = [UADSPreferences getString:key];
    if (preferenceValue != nil) {
        [callback invoke:preferenceValue, nil];
    } else {
        [callback error:NSStringFromPreferencesError(kUnityAdsPreferencesCouldntGetValue) arg1:nil];
    }
}

+ (void)WebViewExposed_getInt:(NSString *)key callback:(UADSWebViewCallback *)callback {
    NSNumber *preferenceValue = [UADSPreferences getInteger:key];
    if (preferenceValue != nil) {
        [callback invoke:preferenceValue, nil];
    } else {
        [callback error:NSStringFromPreferencesError(kUnityAdsPreferencesCouldntGetValue) arg1:nil];
    }
}

+ (void)WebViewExposed_getLong:(NSString *)key callback:(UADSWebViewCallback *)callback {
    NSNumber *preferenceValue = [UADSPreferences getLong:key];
    if (preferenceValue != nil) {
        [callback invoke:preferenceValue, nil];
    } else {
        [callback error:NSStringFromPreferencesError(kUnityAdsPreferencesCouldntGetValue) arg1:nil];
    }
}

+ (void)WebViewExposed_getBoolean:(NSString *)key callback:(UADSWebViewCallback *)callback {
    NSNumber *preferenceValue = [UADSPreferences getBoolean:key];
    if (preferenceValue != nil) {
        [callback invoke:preferenceValue, nil];
    } else {
        [callback error:NSStringFromPreferencesError(kUnityAdsPreferencesCouldntGetValue) arg1:nil];
    }
}

+ (void)WebViewExposed_getFloat:(NSString *)key callback:(UADSWebViewCallback *)callback {
    NSNumber *preferenceValue = [UADSPreferences getFloat:key];
    if (preferenceValue != nil) {
        [callback invoke:preferenceValue, nil];
    } else {
        [callback error:NSStringFromPreferencesError(kUnityAdsPreferencesCouldntGetValue) arg1:nil];
    }
}

+ (void)WebViewExposed_setString:(NSString *)value forKey:(NSString *)key callback:(UADSWebViewCallback *)callback {
    [UADSPreferences setString:value forKey:key];
    [callback invoke:nil];
}

+ (void)WebViewExposed_setInt:(NSNumber *)value forKey:(NSString *)key callback:(UADSWebViewCallback *)callback {
    [UADSPreferences setInteger:[value intValue] forKey:key];
    [callback invoke:nil];
}

+ (void)WebViewExposed_setLong:(NSNumber *)value forKey:(NSString *)key callback:(UADSWebViewCallback *)callback {
    [UADSPreferences setLong:[value longValue] forKey:key];
    [callback invoke:nil];
}

+ (void)WebViewExposed_setBoolean:(NSNumber *)value forKey:(NSString *)key callback:(UADSWebViewCallback *)callback {
    [UADSPreferences setBoolean:[value boolValue] forKey:key];
    [callback invoke:nil];
}

+ (void)WebViewExposed_setFloat:(NSNumber *)value forKey:(NSString *)key callback:(UADSWebViewCallback *)callback {
    [UADSPreferences setFloat:[value floatValue] forKey:key];
    [callback invoke:nil];
}

+ (void)WebViewExposed_removeKey:(NSString *)key callback:(UADSWebViewCallback *)callback {
    [UADSPreferences removeKey:key];
    [callback invoke:nil];
}

@end
