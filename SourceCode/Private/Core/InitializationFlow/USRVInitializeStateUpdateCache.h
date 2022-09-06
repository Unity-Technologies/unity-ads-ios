#import "USRVInitialize.h"
#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface USRVInitializeStateUpdateCache : USRVInitializeState

@property (nonatomic, strong) NSString *localWebViewData;

- (instancetype)initWithConfiguration: (USRVConfiguration *)configuration webViewData: (NSString *)webViewData;

@end
NS_ASSUME_NONNULL_END
