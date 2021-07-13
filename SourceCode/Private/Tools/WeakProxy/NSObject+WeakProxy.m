//
//  NSObject+WeakProxy.m
//  UnityAds
//
//  Created by Alex Crowe on 2020-10-13.
//

#import "NSObject+WeakProxy.h"
#import "UADSWeakProxy.h"

@implementation NSObject (Category)

- (id)weakSelf {
    return [UADSWeakProxy newWithObject: self];
}

@end
