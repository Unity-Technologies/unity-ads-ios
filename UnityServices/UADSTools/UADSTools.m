#import "UADSTools.h"


_Nullable id typecast(id obj, Class class) {
    if ([obj isKindOfClass: class]) {
        return obj;
    } else {
        return nil;
    }
}

void dispatch_on_main(dispatch_block_t block) {
    dispatch_async(dispatch_get_main_queue(), block);
}
