#import "USRVApiMainBundle.h"
#import "USRVWebViewCallback.h"

@implementation USRVApiMainBundle

+ (void)WebViewExposed_getDataForKeysContaining:(NSString *)containsString callback:(USRVWebViewCallback *)callback {
    NSDictionary *infoDict = [NSBundle mainBundle].infoDictionary;
    NSMutableDictionary *retDictionary = [[NSMutableDictionary alloc] init];

    if (infoDict) {
        for (NSString *key in infoDict) {
            if ([key containsString:containsString]) {
                [retDictionary setObject:[infoDict objectForKey:key] forKey:key];
            }
        }
    }
    
    [callback invoke:retDictionary, nil];
}

+ (void)WebViewExposed_getDataForKey:(NSString *)key callback:(USRVWebViewCallback *)callback {
    NSDictionary *infoDict = [NSBundle mainBundle].infoDictionary;
    
    if (infoDict) {
        if ([infoDict objectForKey:key]) {
            [callback invoke:key, [infoDict objectForKey:key], nil];
        }
        else {
            [callback error:@"NO_SUCH_KEY" arg1:key, nil];
        }
    }
    else {
        [callback error:@"INFODICTIONARY_NULL" arg1:nil];
    }
}

@end
