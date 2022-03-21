#import <Foundation/Foundation.h>
#import "UADSTokenType.h"

NS_ASSUME_NONNULL_BEGIN

typedef void (^UADSTimeoutBlock)(NSUUID *, UADSTokenType);

@interface UADSClosureWithTimeout<__covariant ReturnType> : NSObject
@property (nonatomic, readonly) NSUUID *id;
@property (nonatomic, readonly) UADSTokenType type;
+ (instancetype)newWithType: (UADSTokenType)type
           timeoutInSeconds: (NSInteger)timeout
          andTimeoutClosure: (UADSTimeoutBlock)timeoutBlock
                   andBlock: (void (^)(ReturnType _Nullable, UADSTokenType))block;

- (void)callClosureWith: (ReturnType _Nullable)object;
@end

NS_ASSUME_NONNULL_END
