#import "UADSJSONCompressorMock.h"
#import "NSDictionary+JSONString.h"
@implementation UADSJSONCompressorMock

- (nonnull NSString *)compressedIntoString: (nonnull NSDictionary *)dictionary {
    
    NSError *error;
    NSData* jsonData = [NSJSONSerialization dataWithJSONObject:dictionary
      options:NSJSONWritingPrettyPrinted error:&error];
    NSString *jsonString = [[NSString alloc] initWithData:jsonData
                                                encoding:NSUTF8StringEncoding];
    return jsonString;
}

- (NSData *)compressedIntoData: (NSDictionary *)dictionary {
    return dictionary.uads_jsonData;
}


- (NSDictionary*)uncompress:(NSString*)compressedString {
    NSData* data = [compressedString dataUsingEncoding:NSUTF8StringEncoding];
    NSError *error;
    NSDictionary *configDictionary = [NSJSONSerialization JSONObjectWithData: data
                                                                     options: kNilOptions
                                                                       error: &error];
    return configDictionary;
}

@end
