#import "UADSMetric.h"
#import "NSDictionary+JSONString.h"

@interface UADSMetric ()
@property (nonatomic, strong) NSString *name;
@property (nonatomic, strong, nullable) NSNumber *value;
@property (nonatomic, strong, nullable) NSDictionary<NSString *, NSString *> *tags;
@end

@implementation UADSMetric
+ (instancetype)newWithName: (NSString *)name value: (NSNumber *)value tags: (NSDictionary<NSString *, NSString *> *)tags {
    UADSMetric *metric = [self new];

    metric.name = name;
    metric.value = value;
    metric.tags = tags;
    return metric;
}

- (NSDictionary *)dictionary {
    NSMutableDictionary *dict = [NSMutableDictionary dictionaryWithObject: self.name
                                                                   forKey: @"n"];

    if (self.value != nil) {
        dict[@"v"] = self.value;
    }

    if (self.tags != nil) {
        dict[@"t"] = self.tags;
    }

    return dict;
}

- (BOOL)isEqual: (id)object {
    if (object == nil) {
        return NO;
    }

    if (self == object) {
        return YES;
    }

    if (![object isKindOfClass: [UADSMetric class]]) {
        return NO;
    }

    UADSMetric *other = (UADSMetric *)object;

    return [self.name isEqual: other.name] &&
//           ((!self.value && !other.value) || [self.value isEqualToNumber: other.value]) &&
           ((!self.tags && !other.tags) || [self.tags isEqualToDictionary: other.tags]);
}

- (NSString *)description {
    NSMutableString *output = [NSMutableString stringWithFormat: @"Event: %@\r", self.name];

    [output appendFormat: @"Value: %@\r", self.value];

    __block NSString *tagsDescription = @"{\r";

    [self.tags enumerateKeysAndObjectsUsingBlock:^(NSString *_Nonnull key, NSString *_Nonnull obj, BOOL *_Nonnull stop) {
        tagsDescription = [tagsDescription stringByAppendingFormat: @"\t%@ : %@\r", key, obj];
    }];

    tagsDescription = [tagsDescription stringByAppendingString: @"}\r"];

    [output appendFormat: @"Tags: %@", tagsDescription];
    return output;
}

- (instancetype)updatedWithValue: (NSNumber *)value {
    return [[self class] newWithName: _name
                               value: value
                                tags: _tags];
}

@end
