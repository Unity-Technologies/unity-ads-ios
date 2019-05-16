#import "UANAWebViewAnalyticsEvent.h"

NSString *NSStringFromUANAWebViewAnalyticsEvent(UANAWebViewAnalyticsEvent event) {
    switch (event) {
        case kWebViewAnalyticsEventPost:
            return @"POSTEVENT";
    }
}
