#import "UADSAbstractModuleDelegateMock.h"
#import "UADSTools.h"


@implementation UADSAbstractModuleDelegateMock

- (instancetype)init {
    SUPER_INIT;
    self.errors = [NSArray new];
    self.placementIDs = [NSArray new];
    self.uuidString = kUADSShowDelegateMockID;
    return self;
}

-(void)fulfill {
    [self.expectation fulfill];
}

- (void)didFailWithError: (UADSInternalError *)error
          forPlacementID: (id)placementID {
    _errors = [_errors arrayByAddingObject: error];
    _placementIDs = [_placementIDs arrayByAddingObject: placementID];
    [self fulfill];
}


@end
