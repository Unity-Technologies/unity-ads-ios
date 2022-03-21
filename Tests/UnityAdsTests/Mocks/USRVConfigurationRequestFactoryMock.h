
#import <Foundation/Foundation.h>
#import "USRVConfigurationRequestFactory.h"
#import "USRVConfiguration.h"
#import "WebRequestMock.h"

NS_ASSUME_NONNULL_BEGIN

@interface USRVConfigurationRequestFactoryMock : NSObject<USRVConfigurationRequestFactory>
@property (nonatomic, strong) WebRequestMock *expectedRequest;

+ (instancetype)newFactoryWithExpectedNSDictionaryInRequest: (NSDictionary *)obj invalidResponseCode: (BOOL)responseCode;
@end

@interface USRVConfiguration (LocalHost)

+ (instancetype)getConfigurationWithLocalHost;
@end


NS_ASSUME_NONNULL_END
