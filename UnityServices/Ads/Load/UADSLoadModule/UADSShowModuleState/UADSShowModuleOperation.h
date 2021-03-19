#import "UADSAbstractModuleOperationBasicObject.h"
NS_ASSUME_NONNULL_BEGIN

@interface UADSShowModuleOperation: UADSAbstractModuleOperationBasicObject
@property (nonatomic, strong) NSDictionary *orientationState;
@property (nonatomic, assign) BOOL shouldAutorotate;
@end

NS_ASSUME_NONNULL_END
