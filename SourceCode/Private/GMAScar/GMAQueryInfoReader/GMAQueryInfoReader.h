#import "GADRequestBridge.h"
#import "GADQueryInfoBridge.h"
NS_ASSUME_NONNULL_BEGIN

/// An object that conforms to the protocol should provide implementation for returning `GADQueryInfo` for an AdType
@protocol GMAQueryInfoReader <NSObject>

/// Creates GADQueryInfo reflectively. Returned as GADQueryInfoBridge
/// An id<UADSError> is returned when a query could  not be created
/// @param type AdType
/// @param completion GADQueryInfoBridgeCompletion.
- (void)getQueryInfoOfFormat: (GADQueryInfoAdType)type
                  completion: (GADQueryInfoBridgeCompletion *)completion;
@end

/// Class-proxy for creating `GADQueryInfo`  reflectively. Hiden behind protocol for testability and scalability.
@interface GMABaseQueryInfoReader : NSObject<GMAQueryInfoReader>
@end

NS_ASSUME_NONNULL_END
