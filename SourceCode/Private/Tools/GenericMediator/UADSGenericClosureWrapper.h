#import <Foundation/Foundation.h>
#import "UADSTools.h"
NS_ASSUME_NONNULL_BEGIN

@interface UADSGenericClosureWrapper<__covariant E> : NSObject
typedef E Object;
typedef void (^UADSGenericClosure)(_Nullable Object);
typedef void (^UADSIDBlock)(NSUUID *);
@property (nonatomic, readonly) NSUUID *uuid;

+ (instancetype)newWithClosure: (UADSGenericClosure)closure;
+ (instancetype)newWithTimeoutInSeconds: (NSInteger)timeout
                      andTimeoutClosure: (UADSIDBlock)timeoutBlock
                               andBlock: (UADSGenericClosure)block;

- (void)callWithObject: (_Nullable Object)obj;
@end

NS_ASSUME_NONNULL_END
