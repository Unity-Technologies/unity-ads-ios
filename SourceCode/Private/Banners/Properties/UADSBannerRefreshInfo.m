#import "UADSBannerRefreshInfo.h"

@interface UADSBannerRefreshInfo ()

@property (nonatomic, strong) NSMutableDictionary<NSString *, NSNumber *> *refreshRateMap;

@end

@implementation UADSBannerRefreshInfo

// MARK : Public

+ (instancetype)sharedInstance {
    static UADSBannerRefreshInfo *sharedInstance = nil;
    static dispatch_once_t onceToken;

    dispatch_once(&onceToken, ^{
        sharedInstance = [[UADSBannerRefreshInfo alloc] init];
    });
    return sharedInstance;
}

- (void)setRefreshRateForPlacementId: (NSString *)placementId refreshRate: (NSNumber *)refreshRate {
    [self.refreshRateMap setValue: refreshRate
                           forKey: placementId];
}

- (NSNumber *__nullable)getRefreshRateForPlacementId: (NSString *)placementId {
    return [self.refreshRateMap valueForKey: placementId];
}

// MARK : Private

- (instancetype)init {
    self = [super init];

    if (self) {
        _refreshRateMap = [[NSMutableDictionary alloc] init];
    }

    return self;
}

@end
