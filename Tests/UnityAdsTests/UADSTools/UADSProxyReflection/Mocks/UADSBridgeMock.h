#import <Foundation/Foundation.h>
#import "UADSProxyReflection.h"

NS_ASSUME_NONNULL_BEGIN

@interface UADSBridgeMock : UADSProxyReflection
@property (nonatomic, readonly) NSString *testValue;
+ (instancetype)createDefault;
- (NSString *)  nonExistingKVO;
+ (void)        setMockSelectors: (NSArray<NSString *> *)names;
+ (void)setMockKeys: (NSArray<NSString *> *)names;
@end

NS_ASSUME_NONNULL_END
