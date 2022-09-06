#import "USRVInitialize.h"
#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface USRVInitializeStateCleanCache : USRVInitializeState

- (instancetype)initWithConfiguration: (USRVConfiguration *)configuration nextState: (USRVInitializeState *)nextState;

@property (nonatomic, strong) USRVInitializeState *nextState;

@end

NS_ASSUME_NONNULL_END
