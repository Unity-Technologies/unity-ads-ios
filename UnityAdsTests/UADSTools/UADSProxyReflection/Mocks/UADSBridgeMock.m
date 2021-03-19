#import "UADSBridgeMock.h"

NSArray<NSString *> *mockedSelectors;
NSArray<NSString *> *mockKeysForKVO;

@interface ClosedClassMock: NSObject
@end

@implementation ClosedClassMock
@end

@interface UADSBridgeMock()
@end


@implementation UADSBridgeMock

- (NSString *)testValue {
    return @"TEST_VALUE";
}

+(NSString *)className {
    return @"UADSBridgeMock";
}

+ (instancetype)createDefault {
    return [UADSBridgeMock getProxyWithObject: [ClosedClassMock new]];
}

- (NSString *)nonExistingKVO {
    return [self valueForKey: @"NonExisted"];
}

+ (NSArray<NSString *> *)requiredSelectors {
    return mockedSelectors;
}

+ (NSArray<NSString *> *)requiredKeysForKVO {
    return mockKeysForKVO;
}

+ (void)setMockKeys:(NSArray<NSString *> *)names {
    mockKeysForKVO = names;
}

+ (void)setMockSelectors:(NSArray<NSString *> *)names {
    mockedSelectors = names;
}

- (void)fakeSelectorToTest {
    // do nothing, just allow test to see this selector
}



@end








