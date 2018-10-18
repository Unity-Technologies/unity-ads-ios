#import "UMONJSONUtilities.h"

@implementation UMONJSONUtilities
+(nullable NSData *)objectToData:(id)object {
    NSError *error;
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:object options:NSJSONWritingPrettyPrinted error:&error];
    return jsonData;
}
@end
