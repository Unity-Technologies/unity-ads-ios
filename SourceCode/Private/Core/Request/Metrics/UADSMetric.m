#import "UADSMetric.h"
#import "NSDictionary+JSONString.h"

@interface UADSMetric ()
@property (nonatomic, strong) NSString *name;
@property (nonatomic, strong, nullable) NSNumber *value;
@property (nonatomic, strong, nullable) NSDictionary<NSString *, NSString *> *tags;
@end

@implementation UADSMetric
+ (instancetype)newWithName: (NSString *)name value: (NSNumber *)value tags: (NSDictionary<NSString *, NSString *> *)tags {
    UADSMetric *metric = [[UADSMetric alloc] init];

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
           ((!self.value && !other.value) || [self.value isEqual: other.value]) &&
           ((!self.tags && !other.tags) || [self.tags isEqualToDictionary: other.tags]);
}

- (NSString *)description {
    return [NSString stringWithFormat: @"Event %@, value %@, tags %@", self.name, self.value, self.tags.description];
}

@end
