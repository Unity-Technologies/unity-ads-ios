#import "UADSInternalError.h"
#ifndef UADSAbstractModuleDelegate_h
#define UADSAbstractModuleDelegate_h

@protocol UADSAbstractModuleDelegate
@property (nonatomic, readonly) NSString* _Nonnull uuidString;
-(void)didFailWithError: (UADSInternalError *_Nonnull)error
         forPlacementID: (NSString * __nonnull)placementID;
@end
#endif /* UADSShowInternalDelegate_h */
