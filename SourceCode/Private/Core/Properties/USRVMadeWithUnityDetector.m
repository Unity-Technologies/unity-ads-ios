#import "USRVMadeWithUnityDetector.h"

// This class should be present in an application made with Unity
NSString *const kUnityEngineClassName = @"UnityAppController";

@implementation USRVMadeWithUnityDetector

+ (BOOL)isMadeWithUnity {
    return NSClassFromString(kUnityEngineClassName) != nil;
}

@end
