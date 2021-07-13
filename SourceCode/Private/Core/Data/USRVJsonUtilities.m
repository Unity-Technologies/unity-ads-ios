#import "USRVJsonUtilities.h"
#import "USRVNativeErrorReporter.h"

NSString *const USRVJsonUtilitiesErrorDomain = @"USRVJsonUtilitiesError";

@implementation USRVJsonUtilities

+ (NSData *)dataWithJSONObject: (id)obj options: (NSJSONWritingOptions)opt error: (NSError *_Nullable *)error {
    NSError *internalError = nil;
    NSData *data = nil;

    if ([NSJSONSerialization isValidJSONObject: obj]) {
        @try {
            NSError *err;
            data = [USRVJsonUtilities _dataWithJSONObject: obj
                                                  options: opt
                                                    error: &err];

            if (err) {
                internalError = [[NSError alloc] initWithDomain: USRVJsonUtilitiesErrorDomain
                                                           code: USRVJsonUtilitiesErrorCodeErrorCaught
                                                       userInfo: @{
                                     NSLocalizedDescriptionKey: [NSString stringWithFormat: @"USRVJsonUtilities.dataWithJsonObject an error occurred during dataWithJSONObject : %@", [err localizedDescription], nil]
                }];
            }
        } @catch (NSException *exception) {
            internalError = [[NSError alloc] initWithDomain: USRVJsonUtilitiesErrorDomain
                                                       code: USRVJsonUtilitiesErrorCodeExceptionCaught
                                                   userInfo: @{
                                 NSLocalizedDescriptionKey: [NSString stringWithFormat: @"USRVJsonUtilities.dataWithJSONObject an exception occurred during dataWithJSONObject : %@ : %@", [exception name], [exception reason]]
            }];
        }
    } else {
        internalError = [[NSError alloc] initWithDomain: USRVJsonUtilitiesErrorDomain
                                                   code: USRVJsonUtilitiesErrorCodeInvalidJson
                                               userInfo: @{
                             NSLocalizedDescriptionKey: [NSString stringWithFormat: @"USRVJsonUtilities.dataWithJSONObject was not able to convert invalid json object to json : %@", [obj description]]
        }];
    }

    if (internalError) {
        [USRVNativeErrorReporter reportError: [internalError localizedDescription]];
        USRVLogError(@"%@", [internalError localizedDescription]);

        if (error) {
            *error = internalError;
        }

        data = nil;
    }

    return data;
} /* dataWithJSONObject */

+ (NSData *)_dataWithJSONObject: (id)obj options: (NSJSONWritingOptions)opt error: (NSError *_Nullable *)error {
    return [NSJSONSerialization dataWithJSONObject: obj
                                           options: opt
                                             error: error];
}

@end
