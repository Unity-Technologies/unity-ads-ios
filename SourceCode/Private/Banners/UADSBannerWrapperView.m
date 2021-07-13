#import "UADSBannerWrapperView.h"

@interface UADSBannerWrapperView ()

@property (nonatomic, strong) NSArray *constraints;
@property (nonatomic, assign) UnityAdsBannerPosition bannerPosition;

@end

@implementation UADSBannerWrapperView

- (instancetype)initWithBannerAdRefreshView: (UADSBannerAdRefreshView *)bannerAdRefreshView bannerPosition: (UnityAdsBannerPosition)bannerPosition {
    self = [super init];

    if (self) {
        _bannerAdRefreshView = bannerAdRefreshView;
        _bannerPosition = bannerPosition;
        __weak UADSBannerWrapperView *weakSelf = self;
        _bannerAdRefreshView.translatesAutoresizingMaskIntoConstraints = NO;
        self.translatesAutoresizingMaskIntoConstraints = NO;
        dispatch_async(dispatch_get_main_queue(), ^{
            if (weakSelf) {
                [weakSelf setupView];
                [weakSelf setupConstraints];
            }
        });
    }

    return self;
}

- (void)setupView {
    [self addSubview: _bannerAdRefreshView];
}

- (void)setupConstraints {
    NSDictionary *views = @{
        @"banner": _bannerAdRefreshView
    };

    [self addConstraints: [NSLayoutConstraint constraintsWithVisualFormat: @"H:|[banner]|"
                                                                  options: 0
                                                                  metrics: nil
                                                                    views: views]];
    [self addConstraints: [NSLayoutConstraint constraintsWithVisualFormat: @"V:|[banner]|"
                                                                  options: 0
                                                                  metrics: nil
                                                                    views: views]];
}

- (void)willMoveToSuperview: (UIView *)newSuperview {
    if (_constraints && self.superview) {
        [self.superview removeConstraints: _constraints];
        _constraints = nil;
    }
}

- (void)didMoveToSuperview {
    if (_constraints == nil && self.superview) {
        _constraints = [self getBannerConstraints: self.bannerPosition
                                           banner: self.bannerAdRefreshView
                                        superView: self.superview];
        [self.superview addConstraints: _constraints];
    }
}

- (NSArray<NSLayoutConstraint *> *)getBannerConstraints: (UnityAdsBannerPosition)bannerPosition banner: (UIView *)banner superView: (UIView *)superView {
    NSMutableArray *constraints = [[NSMutableArray alloc] init];

    // position horizontally
    switch (bannerPosition) {
        case kUnityAdsBannerPositionCenter:
        case kUnityAdsBannerPositionBottomCenter:
        case kUnityAdsBannerPositionTopCenter:
            [constraints addObject: [NSLayoutConstraint constraintWithItem: banner
                                                                 attribute: NSLayoutAttributeCenterX
                                                                 relatedBy: NSLayoutRelationEqual
                                                                    toItem: superView
                                                                 attribute: NSLayoutAttributeCenterX
                                                                multiplier: 1.0
                                                                  constant: 0]];
            break;

        case kUnityAdsBannerPositionBottomLeft:
        case kUnityAdsBannerPositionTopLeft:
            [constraints addObject: [NSLayoutConstraint constraintWithItem: banner
                                                                 attribute: NSLayoutAttributeLeft
                                                                 relatedBy: NSLayoutRelationEqual
                                                                    toItem: superView
                                                                 attribute: NSLayoutAttributeLeft
                                                                multiplier: 1.0
                                                                  constant: 0]];
            break;

        case kUnityAdsBannerPositionBottomRight:
        case kUnityAdsBannerPositionTopRight:
            [constraints addObject: [NSLayoutConstraint constraintWithItem: banner
                                                                 attribute: NSLayoutAttributeRight
                                                                 relatedBy: NSLayoutRelationEqual
                                                                    toItem: superView
                                                                 attribute: NSLayoutAttributeRight
                                                                multiplier: 1.0
                                                                  constant: 0]];
            break;

        case kUnityAdsBannerPositionNone:
            break;
    } /* switch */
    // position vertically
    switch (bannerPosition) {
        case kUnityAdsBannerPositionCenter:
            [constraints addObject: [NSLayoutConstraint constraintWithItem: banner
                                                                 attribute: NSLayoutAttributeCenterY
                                                                 relatedBy: NSLayoutRelationEqual
                                                                    toItem: superView
                                                                 attribute: NSLayoutAttributeCenterY
                                                                multiplier: 1.0
                                                                  constant: 0]];
            break;

        case kUnityAdsBannerPositionBottomCenter:
        case kUnityAdsBannerPositionBottomLeft:
        case kUnityAdsBannerPositionBottomRight:

            if (@available(iOS 11.0, *)) {
                // we can use the safeAreaLayoutGuide
                [constraints addObject: [banner.bottomAnchor constraintEqualToAnchor: superView.safeAreaLayoutGuide.bottomAnchor]];
            } else {
                // fall back to anchors
                [constraints addObject: [banner.bottomAnchor constraintEqualToAnchor: superView.bottomAnchor]];
            }

            break;

        case kUnityAdsBannerPositionTopCenter:
        case kUnityAdsBannerPositionTopLeft:
        case kUnityAdsBannerPositionTopRight:

            if (@available(iOS 11.0, *)) {
                // we can use the safeAreaLayoutGuide
                [constraints addObject: [banner.topAnchor constraintEqualToAnchor: superView.safeAreaLayoutGuide.topAnchor]];
            } else {
                // fall back to anchors
                [constraints addObject: [banner.topAnchor constraintEqualToAnchor: superView.topAnchor]];
            }

            break;

        case kUnityAdsBannerPositionNone:
            break;
    } /* switch */
    return constraints;
} /* getBannerConstraints */

@end
