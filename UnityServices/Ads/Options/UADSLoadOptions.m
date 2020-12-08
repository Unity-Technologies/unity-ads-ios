#import "UADSLoadOptions.h"

NSString *const kUnityAdsOptionsAdMarkup = @"adMarkup";

@implementation UADSLoadOptions

- (NSString*) adMarkup {
    return [self.dictionary valueForKey:kUnityAdsOptionsAdMarkup];
}

- (void) setAdMarkup:(NSString *)adMarkup {
    [self.dictionary setValue:adMarkup forKey:kUnityAdsOptionsAdMarkup];
}

@end
