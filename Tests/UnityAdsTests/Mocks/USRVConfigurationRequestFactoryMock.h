
#import <Foundation/Foundation.h>
#import "USRVInitializationRequestFactory.h"
#import "USRVConfiguration.h"
#import "WebRequestMock.h"

NS_ASSUME_NONNULL_BEGIN

@interface USRVConfigurationRequestFactoryMock : NSObject<USRVInitializationRequestFactory>
@property (nonatomic, strong) WebRequestMock *expectedRequest;
@property (nonatomic, strong) NSArray<NSNumber *> *requestedTypes;

+ (instancetype)newFactoryWithExpectedNSDictionaryInRequest: (NSDictionary *)obj invalidResponseCode: (BOOL)responseCode;
@end

@interface USRVConfiguration (LocalHost)

+ (instancetype)getConfigurationWithLocalHost;
@end


NS_ASSUME_NONNULL_END
