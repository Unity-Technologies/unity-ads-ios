
#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@protocol UADSAppStoreReceiptReader <NSObject>
-(NSString *)encodedReceipt;
@end

@interface UADSAppStoreReceiptReaderImp : NSObject<UADSAppStoreReceiptReader>

@end

NS_ASSUME_NONNULL_END
