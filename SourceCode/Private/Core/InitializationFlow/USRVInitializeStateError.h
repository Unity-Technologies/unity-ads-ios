#import "USRVInitialize.h"
#import <Foundation/Foundation.h>
#import "UADSErrorState.h"
NS_ASSUME_NONNULL_BEGIN

@interface USRVInitializeStateError : USRVInitializeState

@property (nonatomic, strong) id erroredState;
@property (nonatomic, assign) UADSErrorState stateCode;
@property (nonatomic, strong) NSString *message;

- (instancetype)initWithConfiguration: (USRVConfiguration *)configuration
                         erroredState: (id)erroredState
                                 code: (UADSErrorState)stateCode
                              message: (NSString *)message;

@end

NS_ASSUME_NONNULL_END
