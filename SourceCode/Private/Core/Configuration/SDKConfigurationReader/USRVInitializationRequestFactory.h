#import <Foundation/Foundation.h>
#import "USRVWebRequest.h"
#import "UADSDeviceInfoReader.h"
#import "USRVBodyBase64GzipCompressor.h"
#import "UADSBaseURLBuilder.h"
#import "UADSConfigurationRequestFactoryConfig.h"
#import "UADSPIIDataSelector.h"
#import "USRVWebRequestFactory.h"
#import "UADSCurrentTimestamp.h"

NS_ASSUME_NONNULL_BEGIN

typedef NS_ENUM (NSInteger, USRVInitializationRequestType) {
    USRVInitializationRequestTypeToken,
    USRVInitializationRequestTypePrivacy,
};

extern NSString * uads_requestTypeString(USRVInitializationRequestType mode);

@protocol USRVInitializationRequestFactory <NSObject>
- (__nullable id<USRVWebRequest>)requestOfType: (USRVInitializationRequestType)type;
- (NSString *)                   baseURL;
@end

@interface USRVInitializationRequestFactoryBase : NSObject<USRVInitializationRequestFactory>

+ (instancetype)newWithDeviceInfoReader: (id<UADSDeviceInfoReader>)deviceInfoReader
                      andDataCompressor: (id<USRVDataCompressor>)dataCompressor
                         andBaseBuilder: (id<UADSBaseURLBuilder>)urlBaseBuilder
                   andWebRequestFactory: (id<IUSRVWebRequestFactory>)webRequestFactory
                       andFactoryConfig: (id<UADSConfigurationRequestFactoryConfig>)config
                     andTimeStampReader: (id<UADSCurrentTimestamp>)timeStampReader;


@end

NS_ASSUME_NONNULL_END
