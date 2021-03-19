#import "UADSTools.h"


_Nullable id typecast(id obj, Class class) {
    if ([obj isKindOfClass: class]) {
        return obj;
    } else {
        return nil;
    }
}

