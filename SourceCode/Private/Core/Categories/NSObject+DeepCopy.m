@implementation NSObject (DeepCopy)

- (instancetype)deepCopy {
    return [NSKeyedUnarchiver unarchiveObjectWithData: [NSKeyedArchiver archivedDataWithRootObject: self]];
}

@end
