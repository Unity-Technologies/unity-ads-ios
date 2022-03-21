#import "NSArray+Sort.h"
#import "NSArray+Convenience.h"

@implementation NSArray (Sort)


- (NSArray *)defaultSorted {
    return [self sortedArrayWithOptions: 0
                        usingComparator:^NSComparisonResult (id obj1, id obj2) {
                            return [obj1 compare: obj2
                                         options: NSCaseInsensitiveSearch];
                        }];
}

@end
