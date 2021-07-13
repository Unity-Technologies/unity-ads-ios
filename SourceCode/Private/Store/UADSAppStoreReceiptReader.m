
#import "UADSAppStoreReceiptReader.h"

@implementation UADSAppStoreReceiptReaderImp

- (nonnull NSString *)encodedReceipt {
    NSURL *receiptURL = NSBundle.mainBundle.appStoreReceiptURL;
    NSData *receipt = [NSData dataWithContentsOfURL: receiptURL];

    return [receipt base64EncodedStringWithOptions: 0];
}

@end
