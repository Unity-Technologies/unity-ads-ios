#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface UADSPlist : NSObject

+ (BOOL)writePlistIosEleven:(NSDictionary *)mutableDictionary
                  toFileUrl:(NSURL *)url API_AVAILABLE(ios(11));

+ (BOOL)writePlistIosTen:(NSDictionary *)mutableDictionary toFileUrl:(NSURL *)url;

+ (void)writePlist:(NSDictionary *)mutableDictionary toFileUrl:(NSURL *)url;

+ (NSDictionary *_Nullable)dictionaryWithContentsOfURLIosEleven:(NSURL *)url API_AVAILABLE(ios(11));

+ (NSDictionary *_Nullable)dictionaryWithContentsOfURLIosTen:(NSURL *)url;

+ (NSDictionary *_Nullable)dictionaryWithContentsOfURL:(NSURL *)url;

@end

NS_ASSUME_NONNULL_END
