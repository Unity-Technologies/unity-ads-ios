#import "USRVInitialize.h"
#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface USRVInitializeStateLoadCacheConfigAndWebView : USRVInitializeState

- (instancetype)initWithConfiguration: (USRVConfiguration *)configuration localConfig: (USRVConfiguration *)localConfig;

@property (nonatomic, strong) USRVConfiguration *localConfig;

@end

NS_ASSUME_NONNULL_END
