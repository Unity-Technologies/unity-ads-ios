#import "USRVInitialize.h"
#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface USRVInitializeStateCheckForUpdatedWebView : USRVInitializeState

- (instancetype)initWithConfiguration: (USRVConfiguration *)configuration localConfiguration: (USRVConfiguration *)localConfiguration;

@property (nonatomic, strong) USRVConfiguration *localWebViewConfiguration;
@property (nonatomic, strong) NSString *localWebViewData;

@end
NS_ASSUME_NONNULL_END
