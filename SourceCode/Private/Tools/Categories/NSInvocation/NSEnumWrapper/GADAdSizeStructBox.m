#import "GADAdSizeStructBox.h"
#import "GADAdSizeBridge.h"

@implementation GADAdSizeStructBox

- (void)setAsArgumentForInvocation: (NSInvocation *)invocation atIndex:(NSInteger)index {
    GADAdSizeBridge structValue;
    [self getValue: &structValue];
    [invocation setArgument: &structValue
                    atIndex: index];
}

@end
