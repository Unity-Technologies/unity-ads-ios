#import <UIKit/UIKit.h>
#import "UADSBaseURLBuilder.h"
#import "USRVConfiguration.h"

NS_ASSUME_NONNULL_BEGIN

@interface UADSWebViewURLBuilder : NSObject<UADSBaseURLBuilder>
+ (instancetype)newWithBaseURL: (NSString *)base
            andQueryAttributes: (NSDictionary *)attributes;

//convenience init.
+ (instancetype)newWithBaseURL: (NSString *)base andConfiguration: (USRVConfiguration *)config;
@end

NS_ASSUME_NONNULL_END
