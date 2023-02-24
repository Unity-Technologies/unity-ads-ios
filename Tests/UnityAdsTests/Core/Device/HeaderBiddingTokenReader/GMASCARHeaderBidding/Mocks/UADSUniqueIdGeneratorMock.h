#import <Foundation/Foundation.h>
#import "UADSUniqueIdGenerator.h"

NS_ASSUME_NONNULL_BEGIN

@interface UADSUniqueIdGeneratorMock : NSObject <UADSUniqueIdGenerator>

@property (nonatomic) NSString* expectedValue;

@end

NS_ASSUME_NONNULL_END
