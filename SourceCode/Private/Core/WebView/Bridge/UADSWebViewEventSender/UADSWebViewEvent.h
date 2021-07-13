#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@protocol UADSWebViewEvent <NSObject>
- (NSString *)          categoryName;
- (NSString *)          eventName;
- (NSArray *_Nullable)  params;
@end

@protocol UADSWebViewEventConvertible <NSObject>
- (id<UADSWebViewEvent>)convertToEvent;
@end

@interface UADSWebViewEventBase : NSObject<UADSWebViewEvent>

+ (instancetype)   newWithCategory: (NSString *)category
                         withEvent: (NSString *)event
                        withParams: (NSArray *_Nullable)params;

@end

NS_ASSUME_NONNULL_END
