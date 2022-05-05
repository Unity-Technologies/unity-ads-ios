#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN



@interface UADSGenericMediator<__covariant E> : NSObject

typedef E Object;
typedef void (^UADSVObserver)(Object);

- (void)subscribe: (UADSVObserver)observer;
- (void)notifyObserversWithObject: (Object)object;
- (void)notifyObserversWithObjectAndRemove: (Object)object;
- (void)removeAllObservers;
@end

NS_ASSUME_NONNULL_END
