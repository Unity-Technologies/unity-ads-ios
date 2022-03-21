#import <UIKit/UIKit.h>
#import "UADSBaseURLBuilder.h"
NS_ASSUME_NONNULL_BEGIN

@interface UADSBaseURLBuilderMock : NSObject<UADSBaseURLBuilder>
@property (nonatomic, copy) NSString *baseURL;
@end

NS_ASSUME_NONNULL_END
