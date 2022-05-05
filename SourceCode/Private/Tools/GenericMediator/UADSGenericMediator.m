#import "UADSGenericMediator.h"

@interface UADSGenericMediator ()
@property (nonatomic, strong) NSArray<UADSVObserver> *observers;
@end


@implementation UADSGenericMediator

- (instancetype)init {
    SUPER_INIT;
    self.observers = [NSArray new];
    return self;
}

- (void)notifyObserversWithObject: (Object)object {
    for (UADSVObserver observer in _observers) {
        observer(object);
    }
}

- (void)removeAllObservers {
    _observers = @[];
}

- (void)notifyObserversWithObjectAndRemove: (Object)object {
    [self notifyObserversWithObject: object];
    [self removeAllObservers];
}

- (void)subscribe: (UADSVObserver)observer {
    _observers = [_observers arrayByAddingObject: observer];
}

@end
