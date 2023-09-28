#import "NSPrimitivesBox.h"
#import "UADSTools.h"

@interface NSPrimitivesBox ()
@property (nonatomic, strong) NSValue *box;
@end

@implementation NSPrimitivesBox
+ (instancetype)newWithBytes: (nonnull const void *)bytes objCType: (nonnull const char *)type {
    return [[self alloc] initWithBytes: bytes
                              objCType: type];
}

// Suppressing unnecessary warnings. Its expected behaviour when subclassing NSValue, according to the notes from apple docs
// https://developer.apple.com/documentation/foundation/nsvalue?language=objc
#pragma GCC diagnostic push
#pragma GCC diagnostic ignored "-Wobjc-designated-initializers"
- (instancetype)initWithBytes: (const void *)value objCType: (const char *)type {
#pragma GCC diagnostic pop

#pragma GCC diagnostic push
#pragma GCC diagnostic ignored "-Wobjc-designated-initializers"
    SUPER_INIT
#pragma GCC diagnostic push
    self.box = [NSValue valueWithBytes: value
                              objCType: type];
    return self;
}

- (void)getValue: (void *)value {
    return [_box getValue: value];
}

- (const char *)objCType {
    return [_box objCType];
}

- (void)setAsArgumentForInvocation: (NSInvocation *)invocation atIndex:(NSInteger)index {
    void *pointerToPrimitives;
    [self getValue: &pointerToPrimitives];
    
    [invocation setArgument: &pointerToPrimitives
                    atIndex: index];
}

@end
