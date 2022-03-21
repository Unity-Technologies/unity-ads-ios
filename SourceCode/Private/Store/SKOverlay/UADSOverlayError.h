#import <Foundation/Foundation.h>

typedef NS_ENUM (NSInteger, UADSOverlayError) {
    kOverlayNotAvailable,
    kOverlaySceneNotFound,
    kOverlayInvalidParamaters,
    kOverlayNoLoad,
    kOverlayAlreadyShown
};

NSString * UADSStringFromOverlayError(UADSOverlayError);
