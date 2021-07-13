#import "UADSBaseOptions.h"

NSString *const kUnityAdsOptionsObjectId = @"objectId";

@implementation UADSBaseOptions

@synthesize dictionary;

- (instancetype)init {
    self = [super init];

    if (self) {
        dictionary = [NSMutableDictionary new];
    }

    return self;
}

- (NSString *)objectId {
    return [self.dictionary valueForKey: kUnityAdsOptionsObjectId];
}

- (void)setObjectId: (NSString *)objectId {
    [self.dictionary setValue: objectId
                       forKey: kUnityAdsOptionsObjectId];
}

@end
