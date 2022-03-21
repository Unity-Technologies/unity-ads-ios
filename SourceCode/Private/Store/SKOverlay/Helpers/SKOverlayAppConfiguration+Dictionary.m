#import "SKOverlayAppConfiguration+Dictionary.h"

@implementation SKOverlayAppConfiguration (Dictionary)

+ (SKOverlayAppConfiguration *)overlayAppConfigurationFrom: (NSDictionary *)parameters API_AVAILABLE(ios(14.0)) {
    NSString *appIdentifier = [parameters valueForKey: @"appIdentifier"];
    int position = [[parameters valueForKey: @"position"] intValue] ? : SKOverlayPositionBottom;

    if (appIdentifier != nil) {
        SKOverlayAppConfiguration *config = [[SKOverlayAppConfiguration alloc] initWithAppIdentifier: appIdentifier
                                                                                            position: position];
        config.userDismissible = [[parameters valueForKey: @"userDismissible"] boolValue] ? : false;
        config.campaignToken = [parameters valueForKey: @"campaignToken"];
        config.providerToken = [parameters valueForKey: @"providerToken"];

        NSDictionary *additional = [parameters valueForKey: @"additional"];

        if ([additional isKindOfClass: [NSDictionary class]]) {
            [additional enumerateKeysAndObjectsUsingBlock:^(id key, id object, BOOL *stop) {
                [config setAdditionalValue: object
                                    forKey: key];
            }];
        }

        return config;
    }

    return nil;
}

@end
