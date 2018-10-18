#import "USRVConfiguration.h"

@interface USRVModuleConfiguration : NSObject

- (NSArray<NSString*>*)getWebAppApiClassList;
- (BOOL)resetState:(USRVConfiguration *)configuration;
- (BOOL)initModuleState:(USRVConfiguration *)configuration;
- (BOOL)initErrorState:(USRVConfiguration *)configuration state:(NSString *)state message:(NSString *)message;
- (BOOL)initCompleteState:(USRVConfiguration *)configuration;

@end
