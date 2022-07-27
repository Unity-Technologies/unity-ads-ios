#import <Foundation/Foundation.h>
#import "UADSGenericClosureWrapper.h"

NS_ASSUME_NONNULL_BEGIN

@interface UADSGenericMediator<__covariant E> : NSObject
@property (nonatomic, assign) BOOL removeOnTimeout;
@property (nonatomic, assign) NSInteger timeoutInSeconds;
typedef E Object;
typedef void (^UADSVObserver)(Object);

- (NSInteger)count;
- (void)     subscribe: (UADSVObserver)observer;
- (void)subscribe: (UADSVObserver)observer
       andTimeout: (UADSVoidClosure)timeoutFired;
- (void)subscribeWithTimeout: (NSInteger)timeInSeconds
                 forObserver: (UADSVObserver)observer
                  andTimeout: (UADSVoidClosure)timeoutFired;
- (void)notifyObserversWithObject: (Object)object;
- (void)notifyObserversWithObjectAndRemove: (Object)object;
- (void)notifyObserversSeparatelyWithObjectsAndRemove: (NSArray<Object> *)objects;
- (void)     removeAllObservers;
@end

NS_ASSUME_NONNULL_END
