#import "UADSAbstractModule.h"

NS_ASSUME_NONNULL_BEGIN

@interface UADSAbstractTestModuleState : NSObject<UADSAbstractModuleOperationObject>
@property (nonatomic, strong) id<UADSAbstractModuleDelegate> delegate;
@property (nonatomic, strong) NSString *id;
@property (nonatomic, strong) NSString *placementID;
- (void)     emulateExpired;
@end


@interface UADSAbstractTestModule : UADSAbstractModule
@property (nonatomic, strong) UADSAbstractTestModuleState *returnedState;
@property (nonatomic, strong) UADSInternalError *returnedExecutionError;
+ (NSInteger)numberOfCreateCalls;
@end



@interface UADSAbstractTestModule2 : UADSAbstractModule
+ (NSInteger)numberOfCreateCalls;
@end

NS_ASSUME_NONNULL_END
