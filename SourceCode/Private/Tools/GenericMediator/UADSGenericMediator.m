#import "UADSGenericMediator.h"
#import "UADSGenericClosureWrapper.h"
#import "NSArray+Convenience.h"
#import "NSArray+Map.h"
#import "NSArray+SafeOperations.h"

@interface UADSGenericMediator ()
typedef UADSGenericClosureWrapper<Object> InternalObserver;
@property (nonatomic, strong) NSArray<InternalObserver *> *observers;
@property (nonatomic, strong) dispatch_queue_t synchronizedQueue;
@end


@implementation UADSGenericMediator

- (instancetype)init {
    SUPER_INIT;
    self.observers = [NSArray new];
    self.removeOnTimeout = true;
    _synchronizedQueue = dispatch_queue_create("com.unity3d.UADSGenericMediator", DISPATCH_QUEUE_SERIAL);
    return self;
}

- (void)notifyObserversWithObject: (Object)object {
    dispatch_sync(_synchronizedQueue, ^{
        [self notifyObserversWithObjectInternal: object];
    });
}

- (void)notifyObserversWithObjectInternal: (Object)object {
    for (InternalObserver *wrapper in self.observers) {
        [wrapper callWithObject: object];
    }
}

- (void)removeAllObservers {
    dispatch_sync(_synchronizedQueue, ^{
        [self removeAllObserversInternal];
    });
}

- (void)removeAllObserversInternal {
    self.observers = @[];
}

- (void)notifyObserversWithObjectAndRemove: (Object)object {
    dispatch_sync(_synchronizedQueue, ^{
        [self notifyObserversWithObjectInternal: object];
        [self removeAllObserversInternal];
    });
}

- (void)subscribe: (UADSVObserver)observer {
    dispatch_sync(_synchronizedQueue, ^{
        self.observers = [self.observers arrayByAddingObject: [self createWrapperFor: observer]];
    });
}

- (void)subscribe: (UADSVObserver)observer
       andTimeout: (UADSVoidClosure)timeoutFired {
    [self subscribeWithTimeout: _timeoutInSeconds
                   forObserver: observer
                    andTimeout: timeoutFired];
}

- (void)subscribeWithTimeout: (NSInteger)timeInSeconds
                 forObserver: (UADSVObserver)observer
                  andTimeout: (UADSVoidClosure)timeoutFired {
    dispatch_sync(_synchronizedQueue, ^{
        InternalObserver *internal = [self createWrapperWithTimeout: timeInSeconds
                                                        forObserver: observer
                                                        withTimeout: timeoutFired];
        self.observers = [self.observers arrayByAddingObject: internal];
    });
}

- (InternalObserver *)createWrapperFor:  (UADSVObserver)observer {
    return [self createWrapperWithTimeout: _timeoutInSeconds
                              forObserver: observer
                              withTimeout: nil];
}

- (InternalObserver *)createWrapperWithTimeout: (NSInteger)timeInSeconds
                                   forObserver:  (UADSVObserver)observer
                                   withTimeout: (UADSVoidClosure)timeout {
    if (timeInSeconds <= 0) {
        return [InternalObserver newWithClosure: observer];
    }

    UADSIDBlock timeoutBlock = ^(NSUUID *id) {
        timeout();
    };

    if (_removeOnTimeout) {
        __weak typeof(self) weakSelf = self;
        timeoutBlock = ^(NSUUID *id) {
            [weakSelf removeObserverWithID: id];
            timeout();
        };
    }

    return [InternalObserver newWithTimeoutInSeconds: timeInSeconds
                                   andTimeoutClosure: timeoutBlock
                                            andBlock: observer];
}

- (void)notifyObserversSeparatelyWithObjectsAndRemove: (NSArray<Object> *)objects {
    dispatch_sync(_synchronizedQueue, ^{
        for (int i = 0; i < objects.count; i++) {
            InternalObserver *observer = [self.observers uads_getItemSafelyAtIndex: i];
            [observer callWithObject: objects[i]];
        }

        self.observers = [self.observers uads_removingFirstElements: objects.count];
    });
}

- (void)removeObserverWithID: (NSUUID *)uuid {
    dispatch_sync(_synchronizedQueue, ^{
        self.observers = [self.observers uads_removingFirstWhere:^bool (InternalObserver *_Nonnull obsrv) {
            return [obsrv.uuid isEqual: uuid];
        }];
    });
}

- (NSInteger)count {
    return _observers.count;
}

@end
