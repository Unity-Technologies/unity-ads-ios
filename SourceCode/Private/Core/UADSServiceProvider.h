#import <Foundation/Foundation.h>
#import "UADSConfigurationCRUDBase.h"
#import "UADSHeaderBiddingTokenReaderBuilder.h"
#import "USRVSDKMetrics.h"

NS_ASSUME_NONNULL_BEGIN

@interface UADSServiceProvider : NSObject
@property (nonatomic, strong) id<UADSConfigurationCRUD> configurationStorage;
@property (nonatomic, strong) id<ISDKMetrics>metricSender;
@property (nonatomic, strong) id<IUSRVWebRequestFactoryStatic, IUSRVWebRequestFactory>requestFactory;
+ (instancetype)                                                     sharedInstance;
- (id<UADSHeaderBiddingAsyncTokenReader, UADSHeaderBiddingTokenCRUD>)hbTokenReader;
- (id<UADSConfigurationSaver>)                                       configurationSaver;

@end

NS_ASSUME_NONNULL_END
