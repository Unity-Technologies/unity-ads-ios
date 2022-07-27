@implementation NSObject (DeepCopy)

- (instancetype)uads_deepCopy {
    return [NSKeyedUnarchiver unarchiveObjectWithData: [NSKeyedArchiver archivedDataWithRootObject: self]];
}

@end
