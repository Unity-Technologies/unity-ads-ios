#import "ConfigurationMetricTagsReaderMock.h"

@implementation ConfigurationMetricTagsReaderMock

- (instancetype)init {
    self = [super init];
    _expectedTags = @{};
    return self;
}

+ (instancetype)newWithExpectedTags: (NSDictionary *)expectedTags {
    ConfigurationMetricTagsReaderMock *mock = [ConfigurationMetricTagsReaderMock new];

    mock.expectedTags = expectedTags;
    return mock;
}

- (NSDictionary *)metricTags {
    return self.expectedTags;
}

@end
