#import "USRVWebViewBackgroundView.h"


@interface USRVWebViewBackgroundView ()
@property (nonatomic, assign) BOOL needsPlacement;
@property(nonatomic, copy) NSArray<__kindof UIView *> *subviews;
@end

@implementation USRVWebViewBackgroundView

- (instancetype)initWithFrame:(CGRect)frame {
    self.needsPlacement = false;
    self.subviews = [[NSArray alloc] init];
    self.accessibilityElementsHidden = true;
    return [super initWithFrame:frame];
}

- (void)willMoveToSuperview:(UIView *)newSuperview {
    [super willMoveToSuperview:newSuperview];
    if (!newSuperview) {
        self.needsPlacement = true;
    }
}

- (void)didMoveToSuperview {
    [super didMoveToSuperview];
    if (self.needsPlacement) {
        [self placeViewToBackground];
    }
}

- (void)placeViewToBackground {
    if (![self superview]) {
        [self setHidden:YES];
        [[[[UIApplication sharedApplication] windows] firstObject] addSubview:self];
        
        if ([self superview]) {
            [[self superview] sendSubviewToBack:self];
        }
        
        self.needsPlacement = false;
    }
}

- (void)addSubview:(UIView *)view {
    [super addSubview:view];
    self.subviews = [[NSArray alloc] init];
}

@end
