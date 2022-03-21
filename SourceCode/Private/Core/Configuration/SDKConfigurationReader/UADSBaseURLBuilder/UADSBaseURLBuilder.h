
#import <Foundation/Foundation.h>
#import "UADSConfigurationEndpointProvider.h"
NS_ASSUME_NONNULL_BEGIN


extern NSString *const kDefaultPathComponent;


@protocol UADSBaseURLBuilder <NSObject>

- (NSString *)  baseURL;

@end

@interface UADSBaseURLBuilderBase : NSObject<UADSBaseURLBuilder>
@property (nonatomic, copy) NSString *flavour;

+ (instancetype)newWithHostNameProvider: (id<UADSHostnameProvider>)hostNameProvider;
@end

NS_ASSUME_NONNULL_END
