#import "UADSOverlayError.h"

static NSString *notAvailable = @"NOT_AVAILABLE";
static NSString *sceneNotFound = @"SCENE_NOT_FOUND";
static NSString *invalidParamaters = @"INVALID_PARAMETERS";
static NSString *noLoad = @"NO_LOAD";
static NSString *alreadyShown = @"ALREADY_SHOWN";


NSString * UADSStringFromOverlayError(UADSOverlayError error) {
    switch (error) {
        case kOverlayNotAvailable:
            return notAvailable;

        case kOverlaySceneNotFound:
            return sceneNotFound;

        case kOverlayInvalidParamaters:
            return invalidParamaters;

        case kOverlayNoLoad:
            return noLoad;

        case kOverlayAlreadyShown:
            return alreadyShown;
    }
}
