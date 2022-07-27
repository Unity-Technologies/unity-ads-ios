#import <Foundation/Foundation.h>
#import "UADSInitializationResponse.h"
#import "UADSGenericCompletion.h"
#import "USRVInitializationRequestFactory.h"
NS_ASSUME_NONNULL_BEGIN

typedef void (^UADSPrivacyCompletion)(UADSInitializationResponse *);

typedef NS_ENUM (NSInteger, UADSPrivacyLoaderError) {
    kUADSPrivacyLoaderParsingError,
    kUADSPrivacyLoaderIsNotCreated,
    kUADSPrivacyLoaderInvalidResponseCode
};

extern NSString * uads_privacyErrorTypeToString(UADSPrivacyLoaderError type);

extern NSString *const kPrivacyLoaderErrorDomain;

#define uads_privacyJsonParsingLoaderError(info) \
    [[NSError alloc] initWithDomain: kPrivacyLoaderErrorDomain \
                               code: kUADSPrivacyLoaderParsingError \
                           userInfo: info] \


#define uads_privacyRequestIsNotCreatedLoaderError \
    [[NSError alloc] initWithDomain: kPrivacyLoaderErrorDomain \
                               code: kUADSPrivacyLoaderIsNotCreated \
                           userInfo: nil] \

#define uads_privacyInvalidResponseCodeError \
    [[NSError alloc] initWithDomain: kPrivacyLoaderErrorDomain \
                               code: kUADSPrivacyLoaderInvalidResponseCode \
                           userInfo: nil] \

@protocol UADSPrivacyLoader <NSObject>
- (void)loadPrivacyWithSuccess: (UADSPrivacyCompletion)success
            andErrorCompletion: (UADSErrorCompletion)errorCompletion;
@end

@interface UADSPrivacyLoaderBase : NSObject<UADSPrivacyLoader>
+ (instancetype)newWithFactory: (id<USRVInitializationRequestFactory>)requestFactory;
@end

NS_ASSUME_NONNULL_END
