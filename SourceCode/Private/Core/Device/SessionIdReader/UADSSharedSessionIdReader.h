#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@protocol UADSSharedSessionIdReader <NSObject>

- (NSString *)sessionId;

@end

@interface UADSSharedSessionIdReaderBase : NSObject <UADSSharedSessionIdReader>

@end

NS_ASSUME_NONNULL_END
