#import "UIView+Subview.h"

@implementation UIView (Subview)

- (void)addSubview:(UIView *)subview withSize:(CGSize)size {
    subview.translatesAutoresizingMaskIntoConstraints = NO;
    [self addSubview: subview];
    [self addConstraints:@[
        [NSLayoutConstraint constraintWithItem: subview
                                     attribute: NSLayoutAttributeCenterY
                                     relatedBy: NSLayoutRelationEqual
                                        toItem: self
                                     attribute: NSLayoutAttributeCenterY
                                    multiplier: 1
                                      constant: 0],
        [NSLayoutConstraint constraintWithItem: subview
                                     attribute: NSLayoutAttributeCenterX
                                     relatedBy: NSLayoutRelationEqual
                                        toItem: self
                                     attribute: NSLayoutAttributeCenterX
                                    multiplier: 1
                                      constant: 0],
        [NSLayoutConstraint constraintWithItem: subview
                                     attribute: NSLayoutAttributeWidth
                                     relatedBy: NSLayoutRelationEqual
                                        toItem: nil
                                     attribute: NSLayoutAttributeNotAnAttribute
                                    multiplier: 1.0
                                      constant: size.width],
        [NSLayoutConstraint constraintWithItem: subview
                                     attribute: NSLayoutAttributeHeight
                                     relatedBy: NSLayoutRelationEqual
                                        toItem: nil
                                     attribute: NSLayoutAttributeNotAnAttribute
                                    multiplier: 1.0
                                      constant: size.height]
    ]];
}

@end
