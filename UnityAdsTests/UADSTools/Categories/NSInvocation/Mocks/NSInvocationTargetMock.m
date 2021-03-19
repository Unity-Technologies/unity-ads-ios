#import "NSInvocationTargetMock.h"

@implementation NSInvocationTargetMock
@synthesize doubleValue;
@synthesize getNumberArgument;
@synthesize mockFunctionArgument;
@synthesize enumArgument;
static NSNumber * getNumberArgument;
static NSNumber * mockFunctionArgument;

+(NSNumber *)getNumberWithArg: (NSNumber *)number {
    getNumberArgument = number;
    return NSINVOCATION_MOCK_RETURNED_VALUE;
}
+(NSNumber *)getNumberArgument {
    return getNumberArgument;
}

+(NSNumber *)mockFunctionArgument {
    return mockFunctionArgument;
}

+ (void)reset {
    getNumberArgument = 0;
    mockFunctionArgument = 0;
}

+(void)mockFunctionWithArg: (NSNumber *)number {
    mockFunctionArgument = number;
}

-(void)mockFunctionWithArg: (NSNumber *)number {
    self.mockFunctionArgument = number;
}

-(NSNumber *)getNumberWithArg: (NSNumber *)number {
    self.getNumberArgument = number;
    return NSINVOCATION_MOCK_RETURNED_VALUE;
}


- (void)mockFunctionWithEnumArg:(NSInvocationTarget)type {
    self.enumArgument = type;
}

- (void)callWithDouble:(double)value {
    self.doubleValue = value;
}


@end
