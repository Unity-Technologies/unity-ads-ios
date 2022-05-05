#import <Foundation/Foundation.h>
#import "UADSTools.h"

NS_ASSUME_NONNULL_BEGIN

@protocol UADSAppLifeCycleNotificationCenter <NSObject>

- (NSString *)addEventsListenerWithDidBecomeActive: (UADSVoidClosure)didBecomeActive didEnterBackground: (UADSVoidClosure)didEnterBackground;
- (void)removeListener: (NSString *)identifier;

@end

@interface UADSAppLifeCycleMediator : NSObject <UADSAppLifeCycleNotificationCenter>

@end

NS_ASSUME_NONNULL_END
