
#import <Foundation/Foundation.h>

#define NSINVOCATION_MOCK_RETURNED_VALUE @10
typedef NS_ENUM (NSInteger, NSInvocationTarget) {
    NSInvocationTargetArgument1,
    NSInvocationTargetArgument2
};

NS_ASSUME_NONNULL_BEGIN

@interface NSInvocationTargetMock : NSObject


@property (nonatomic) NSNumber *getNumberArgument;
@property (nonatomic) NSNumber *mockFunctionArgument;
@property (nonatomic) NSInvocationTarget enumArgument;
@property (nonatomic) double doubleValue;
@property (class, nonatomic, readonly) NSNumber *getNumberArgument;
@property (class, nonatomic, readonly) NSNumber *mockFunctionArgument;


- (NSNumber *)getNumberWithArg: (NSNumber *)number;
+ (NSNumber *)getNumberWithArg: (NSNumber *)number;

- (void)mockFunctionWithArg: (NSNumber *)number;
+ (void)mockFunctionWithArg: (NSNumber *)number;

- (void)mockFunctionWithEnumArg: (NSInvocationTarget)type;


- (void)callWithDouble: (double)value;

+ (void)      reset;
@end

NS_ASSUME_NONNULL_END
