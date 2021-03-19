#import <Foundation/Foundation.h>
NS_ASSUME_NONNULL_BEGIN

typedef NS_ENUM(NSInteger,UADSInternalErrorType) {
    kUADSInternalErrorShowModule,
    kUADSInternalErrorLoadModule,
    kUADSInternalErrorAbstractModule,
    kUADSInternalErrorWebView,
};

typedef NS_ENUM(NSInteger,UADSInternalErrorAbstractModuleType) {
    kUADSInternalErrorAbstractModuleTimeout,
    kUADSInternalErrorAbstractModuleEmptyPlacementID,
};

typedef NS_ENUM(NSInteger,UADSInternalErrorWebViewType) {
    kUADSInternalErrorWebViewInternal,
    kUADSInternalErrorWebViewTimeout,
    kUADSInternalErrorWebViewSDKNotInitialized
};


@interface UADSInternalError: NSObject
@property(nonatomic, strong) NSDictionary *errorInfo;
+(instancetype)newWithErrorCode: (NSInteger)errorCode
                      andReason: (NSInteger)reasonCode
                     andMessage: (NSString*) errorMessage;
-(NSString *)errorMessage;
-(NSInteger)errorCode;
-(NSInteger)reasonCode;
@end

NS_ASSUME_NONNULL_END
