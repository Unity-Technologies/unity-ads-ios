#import "UADSBaseURLBuilder.h"
#import "NSBundle+TypecastGet.h"
#import "USRVDevice.h"

#import "USRVSdkProperties.h"

NSString *const kDefaultPathComponent = @"webview";

@interface UADSBaseURLBuilderBase ()
@property (nonatomic, strong) id<UADSHostnameProvider> hostNameProvider;
@end

@implementation UADSBaseURLBuilderBase


+ (instancetype)newWithHostNameProvider: (id<UADSHostnameProvider>)hostNameProvider {
    UADSBaseURLBuilderBase *builder = [self new];

    builder.hostNameProvider = hostNameProvider;
    return builder;
}

- (nonnull NSString *)baseURL {
    return [self retrieveConfigInfoFromPlist] ? :
           [self constructedURLString];
}

- (NSString *)constructedURLString {
    NSString *flavorName = self.flavour ? : kUnityServicesFlavorRelease;
    NSString *versionString = [self retrieveBranchNameFromPlist] ? : [USRVSdkProperties getVersionName];

    return [@"https://" stringByAppendingFormat: @"%@/%@/%@/%@/config.json", _hostNameProvider.hostname, kDefaultPathComponent, versionString, flavorName];
}

- (NSString *)retrieveConfigInfoFromPlist {
    return [self.bundle uads_getStringValueForKey: kUnityServicesWebviewConfigInfoDictionaryKey];
}

- (NSString *)retrieveBranchNameFromPlist {
    return [self.bundle uads_getStringValueForKey: kUnityServicesWebviewBranchInfoDictionaryKey];
}

- (NSBundle *)bundle {
    return [NSBundle mainBundle];
}

@end
