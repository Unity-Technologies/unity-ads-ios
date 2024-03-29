#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@protocol UADSGameSessionIdReader <NSObject>

- (NSNumber *)gameSessionId;

@end

@interface UADSGameSessionIdReaderBase : NSObject <UADSGameSessionIdReader>

@end

NS_ASSUME_NONNULL_END
