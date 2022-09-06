#import "USRVInitialize.h"
#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

#define InitializeStateCreateStateName @"create webapp"
@interface USRVInitializeStateCreate : USRVInitializeState

@property (atomic, strong) NSString *webViewData;

- (instancetype)initWithConfiguration: (USRVConfiguration *)configuration webViewData: (NSString *)webViewData;

@end

NS_ASSUME_NONNULL_END
