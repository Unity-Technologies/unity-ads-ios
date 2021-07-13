#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface UADSWebPlayerSettingsManager : NSObject

+ (instancetype)sharedInstance;
- (void)addWebPlayerSettings: (NSString *)viewId
                    settings: (NSDictionary *)settings;
- (void)removeWebPlayerSettings: (NSString *)viewId;
- (NSDictionary *_Nonnull)getWebPlayerSettings: (NSString *)viewId;
- (void)addWebPlayerEventSettings: (NSString *)viewId
                         settings: (NSDictionary *)settings;
- (void)removeWebPlayerEventSettings: (NSString *)viewId;
- (NSDictionary *_Nonnull)getWebPlayerEventSettings: (NSString *)viewId;

@end

NS_ASSUME_NONNULL_END
