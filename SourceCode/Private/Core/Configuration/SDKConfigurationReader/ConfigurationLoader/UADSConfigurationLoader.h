#import <Foundation/Foundation.h>
#import "UADSGenericCompletion.h"
#import "USRVConfigurationRequestFactory.h"
#import "USRVConfiguration.h"
NS_ASSUME_NONNULL_BEGIN
@class USRVConfiguration;

typedef NS_ENUM (NSInteger, UADSConfigurationLoaderError) {
    kUADSConfigurationLoaderParsingError,
    kUADSConfigurationLoaderInvalidWebViewURL,
    kUADSConfigurationLoaderRequestIsNotCreated,
    kUADSConfigurationLoaderInvalidResponseCode
};

extern NSString *const kConfigurationLoaderErrorDomain;

#define uads_invalidWebViewURLLoaderError \
    [[NSError alloc] initWithDomain:  kConfigurationLoaderErrorDomain \
                               code: kUADSConfigurationLoaderInvalidWebViewURL \
                           userInfo: nil]

#define uads_jsonParsingLoaderError(info) \
    [[NSError alloc] initWithDomain: kConfigurationLoaderErrorDomain \
                               code: kUADSConfigurationLoaderParsingError \
                           userInfo: info] \


#define uads_requestIsNotCreatedLoaderError \
    [[NSError alloc] initWithDomain: kConfigurationLoaderErrorDomain \
                               code: kUADSConfigurationLoaderRequestIsNotCreated \
                           userInfo: nil] \

#define uads_invalidResponseCodeError \
    [[NSError alloc] initWithDomain: kConfigurationLoaderErrorDomain \
                               code: kUADSConfigurationLoaderInvalidResponseCode \
                           userInfo: nil] \

typedef void (^UADSConfigurationCompletion)(USRVConfiguration *);

@protocol UADSConfigurationLoader <NSObject>
- (void)loadConfigurationWithSuccess: (NS_NOESCAPE UADSConfigurationCompletion)success
                  andErrorCompletion: (NS_NOESCAPE UADSErrorCompletion)error;
@end

@interface UADSConfigurationLoaderBase : NSObject<UADSConfigurationLoader>
+ (id<UADSConfigurationLoader>)newWithFactory: (id<USRVConfigurationRequestFactory>)requestFactory;
@end

NS_ASSUME_NONNULL_END
