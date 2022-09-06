#import "NSError+RequestDictionary.h"
#import "USRVWebRequestError.h"
#import "NSMutableDictionary+SafeRemoval.h"

@implementation NSError (RequestDictionary)

+ (instancetype)errorWithFailureDictionary: (NSDictionary *)failure {
    NSMutableDictionary *info = [NSMutableDictionary dictionaryWithDictionary: failure];

    return [NSError errorWithDomain: [info uads_removeObjectForKeyAndReturn: @"domain"] ? : @"com.unity3d.ads.UnityAds.Error"
                               code: [[info uads_removeObjectForKeyAndReturn: @"code"] longValue] ? : kUnityServicesWebRequestGenericError
                           userInfo: info];
}

@end
