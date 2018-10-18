#import "USRVWebViewCallback.h"
#import "USRVApiPreferences.h"
#import "USRVPreferencesError.h"
#import "USRVPreferences.h"

@implementation USRVApiPreferences

+ (void)WebViewExposed_hasKey:(NSString *)key callback:(USRVWebViewCallback *)callback {
    [callback invoke:[NSNumber numberWithBool:[USRVPreferences hasKey:key]], nil];
}

+ (void)WebViewExposed_getString:(NSString *)key callback:(USRVWebViewCallback *)callback {
    NSString *preferenceValue = [USRVPreferences getString:key];
    if (preferenceValue != nil) {
        [callback invoke:preferenceValue, nil];
    } else {
        [callback error:NSStringFromPreferencesError(kUnityServicesPreferencesCouldntGetValue) arg1:nil];
    }
}

+ (void)WebViewExposed_getInt:(NSString *)key callback:(USRVWebViewCallback *)callback {
    NSNumber *preferenceValue = [USRVPreferences getInteger:key];
    if (preferenceValue != nil) {
        [callback invoke:preferenceValue, nil];
    } else {
        [callback error:NSStringFromPreferencesError(kUnityServicesPreferencesCouldntGetValue) arg1:nil];
    }
}

+ (void)WebViewExposed_getLong:(NSString *)key callback:(USRVWebViewCallback *)callback {
    NSNumber *preferenceValue = [USRVPreferences getLong:key];
    if (preferenceValue != nil) {
        [callback invoke:preferenceValue, nil];
    } else {
        [callback error:NSStringFromPreferencesError(kUnityServicesPreferencesCouldntGetValue) arg1:nil];
    }
}

+ (void)WebViewExposed_getBoolean:(NSString *)key callback:(USRVWebViewCallback *)callback {
    NSNumber *preferenceValue = [USRVPreferences getBoolean:key];
    if (preferenceValue != nil) {
        [callback invoke:preferenceValue, nil];
    } else {
        [callback error:NSStringFromPreferencesError(kUnityServicesPreferencesCouldntGetValue) arg1:nil];
    }
}

+ (void)WebViewExposed_getFloat:(NSString *)key callback:(USRVWebViewCallback *)callback {
    NSNumber *preferenceValue = [USRVPreferences getFloat:key];
    if (preferenceValue != nil) {
        [callback invoke:preferenceValue, nil];
    } else {
        [callback error:NSStringFromPreferencesError(kUnityServicesPreferencesCouldntGetValue) arg1:nil];
    }
}

+ (void)WebViewExposed_setString:(NSString *)value forKey:(NSString *)key callback:(USRVWebViewCallback *)callback {
    [USRVPreferences setString:value forKey:key];
    [callback invoke:nil];
}

+ (void)WebViewExposed_setInt:(NSNumber *)value forKey:(NSString *)key callback:(USRVWebViewCallback *)callback {
    [USRVPreferences setInteger:[value intValue] forKey:key];
    [callback invoke:nil];
}

+ (void)WebViewExposed_setLong:(NSNumber *)value forKey:(NSString *)key callback:(USRVWebViewCallback *)callback {
    [USRVPreferences setLong:[value longValue] forKey:key];
    [callback invoke:nil];
}

+ (void)WebViewExposed_setBoolean:(NSNumber *)value forKey:(NSString *)key callback:(USRVWebViewCallback *)callback {
    [USRVPreferences setBoolean:[value boolValue] forKey:key];
    [callback invoke:nil];
}

+ (void)WebViewExposed_setFloat:(NSNumber *)value forKey:(NSString *)key callback:(USRVWebViewCallback *)callback {
    [USRVPreferences setFloat:[value floatValue] forKey:key];
    [callback invoke:nil];
}

+ (void)WebViewExposed_removeKey:(NSString *)key callback:(USRVWebViewCallback *)callback {
    [USRVPreferences removeKey:key];
    [callback invoke:nil];
}

@end
