#import "USRVConfiguration.h"
#import "UADSErrorState.h"

@interface USRVModuleConfiguration : NSObject

- (NSArray<NSString *> *)getWebAppApiClassList;
- (BOOL)                 resetState: (USRVConfiguration *)configuration;
- (BOOL)initModuleState: (USRVConfiguration *)configuration;
- (BOOL)initErrorState: (USRVConfiguration *)configuration code: (UADSErrorState)stateCode message: (NSString *)message;
- (BOOL)initCompleteState: (USRVConfiguration *)configuration;

@end
