#import "USRVConfigurationStorage.h"
#import "USRVModuleConfiguration.h"

@interface USRVConfigurationStorage ()
@property (nonatomic, strong) dispatch_queue_t syncQueue;
@property (nonatomic, strong) NSArray<NSString *> *moduleConfigurationList;
@property (nonatomic, strong) NSMutableDictionary<NSString *, USRVModuleConfiguration *> *moduleConfigurations;
@property (nonatomic, strong) NSArray<NSString *> *webAppApiClassList;
@end

@implementation USRVConfigurationStorage

_uads_custom_singleton_imp(USRVConfigurationStorage, ^{
    return [self new];
})

- (instancetype)init {
    SUPER_INIT

        _syncQueue = dispatch_queue_create("com.unity.configuration.storage", DISPATCH_QUEUE_SERIAL);

    [self createModuleConfigurationList];
    [self createModuleConfigurations];
    [self createWebAppApiClassList];
    return self;
}

- (void)createModuleConfigurationList {
    _moduleConfigurationList = @[
        @"USRVCoreModuleConfiguration",
        @"UADSAdsModuleConfiguration",
        @"UANAAnalyticsModuleConfiguration",
        @"UADSBannerModuleConfiguration",
        @"UADSARModuleConfiguration",
        @"USTRStoreModuleConfiguration"
    ];
}

- (void)createModuleConfigurations {
    _moduleConfigurations = [[NSMutableDictionary alloc] init];

    for (NSString *moduleName in self.moduleConfigurationList) {
        id clz = NSClassFromString(moduleName);

        if (clz) {
            id obj = [[NSClassFromString(moduleName) alloc] init];

            if (obj) {
                if ([obj respondsToSelector: @selector(getWebAppApiClassList)]) {
                    USRVLogDebug(@"Responds to selector");
                    [_moduleConfigurations setObject: obj
                                              forKey: moduleName];
                }
            }
        }
    }
}

- (void)createWebAppApiClassList {
    NSMutableArray *tmpArray = [[NSMutableArray alloc] init];

    for (NSString *moduleName in self.moduleConfigurationList) {
        id moduleConfiguration = [self.moduleConfigurations objectForKey: moduleName];

        if (moduleConfiguration) {
            if ([moduleConfiguration getWebAppApiClassList]) {
                [tmpArray addObjectsFromArray: [moduleConfiguration getWebAppApiClassList]];
            }
        }
    }

    _webAppApiClassList = [[NSArray alloc] initWithArray: tmpArray];
}

- (USRVModuleConfiguration *)getModuleConfiguration: (NSString *)moduleName {
    __block USRVModuleConfiguration *config;

    dispatch_sync(_syncQueue, ^{
        config = [self.moduleConfigurations objectForKey: moduleName];
    });

    return config;
}

- (NSArray<NSString *> *)getWebAppApiClassList {
    __block NSArray<NSString *> *list;

    dispatch_sync(_syncQueue, ^{
        list = self.webAppApiClassList;
    });
    return list;
}

- (NSArray<NSString *> *)getModuleConfigurationList {
    __block NSArray<NSString *> *list;

    dispatch_sync(_syncQueue, ^{
        list = self.moduleConfigurationList;
    });
    return list;
}

@end
