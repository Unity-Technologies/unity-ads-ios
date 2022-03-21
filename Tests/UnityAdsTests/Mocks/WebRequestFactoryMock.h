#import <Foundation/Foundation.h>
#import "USRVWebRequestFactory.h"
#import "WebRequestMock.h"

NS_ASSUME_NONNULL_BEGIN

@interface WebRequestFactoryMock : NSObject<IUSRVWebRequestFactoryStatic, IUSRVWebRequestFactory>
@property (nonatomic, strong) id<USRVWebRequest> mockRequest;
@property (nonatomic, strong) NSArray<NSData *> *expectedRequestData;
@property (nonatomic, strong) NSArray<WebRequestMock *> *createdRequests;
+ (instancetype)shared;
@end

NS_ASSUME_NONNULL_END
