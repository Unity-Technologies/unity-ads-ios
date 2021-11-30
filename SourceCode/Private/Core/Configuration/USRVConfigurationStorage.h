#import <Foundation/Foundation.h>

@class USRVModuleConfiguration;

NS_ASSUME_NONNULL_BEGIN

@interface USRVConfigurationStorage : NSObject

+ (instancetype)             sharedInstance;
- (USRVModuleConfiguration *)getModuleConfiguration: (NSString *)moduleName;
- (NSArray<NSString *> *)    getWebAppApiClassList;
- (NSArray<NSString *> *)    getModuleConfigurationList;

@end


NS_ASSUME_NONNULL_END
