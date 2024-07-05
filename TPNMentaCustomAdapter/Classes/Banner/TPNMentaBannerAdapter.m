//
//  TPNMentaBannerAdapter.m
//  TPNMentaCustomAdapter
//
//  Created by jdy on 2024/7/4.
//

#import "TPNMentaBannerAdapter.h"
#import "AnyThinkMentaBiddingManager.h"
#import "TPNMentaBannerCustomEvent.h"
#import <MentaMediationGlobal/MentaMediationGlobal-umbrella.h>

@interface TPNMentaBannerAdapter ()

@end

@implementation TPNMentaBannerAdapter

-(instancetype) initWithNetworkCustomInfo:(NSDictionary*)serverInfo localInfo:(NSDictionary*)localInfo {
    self = [super init];
    if (self != nil) {
        NSString *appIDKey = @"appid";
        if([serverInfo.allKeys containsObject:@"appId"]) {
            appIDKey = @"appId";
        }
        NSString *appID = serverInfo[appIDKey];
        NSString *appKey = serverInfo[@"appKey"];
        if (![MentaAdSDK shared].isInitialized) {
            
        }
    }
    return self;
}


@end
