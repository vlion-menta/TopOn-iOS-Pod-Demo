//
//  ATTMBiddingManager.m
//  HeadBiddingDemo
//
//  Created by lix on 2022/10/20.
//

#import "ATTMBiddingManager.h"

#import "ATTMBiddingDelegate.h"

@interface ATTMBiddingManager ()



@end

@implementation ATTMBiddingManager

+ (instancetype)sharedInstance {
    static ATTMBiddingManager *sharedInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedInstance = [[ATTMBiddingManager alloc] init];
        sharedInstance.bidingAdStorageAccessor = [NSMutableDictionary dictionary];
        sharedInstance.bidingAdDelegate = [NSMutableDictionary dictionary];
    });
    return sharedInstance;
}

- (ATTMBiddingRequest *)getRequestItemWithUnitID:(NSString *)unitID {
    
    return [self.bidingAdStorageAccessor objectForKey:unitID];
    
}

- (ATTMBiddingDelegate *)getDelegateItemWithUnitID:(NSString *)unitID {
    
    return [self.bidingAdDelegate objectForKey:unitID];
    
}


- (void)removeRequestItmeWithUnitID:(NSString *)unitID {
    [self.bidingAdStorageAccessor removeObjectForKey:unitID];
}

- (void)savaBiddingDelegate:(ATTMBiddingDelegate *)delegate withUnitID:(NSString *)unitID {
    [self.bidingAdDelegate setObject:delegate forKey:unitID];
}

- (void)removeBiddingDelegateWithUnitID:(NSString *)unitID {
    
    if (unitID.length) {
        [self.bidingAdDelegate removeObjectForKey:unitID];
    }
    
}

- (void)startWithRequestItem:(ATTMBiddingRequest *)request {
    
    [self.bidingAdStorageAccessor setObject:request forKey:request.unitID];
    switch (request.adType) {
        case MSAdFormatSplash: {
            // 获取代理
            ATTMBiddingDelegate *delegate = [[ATTMBiddingDelegate alloc] init];
            delegate.unitID = request.unitID;
            [request.customObject setValue:delegate forKey:@"delegate"];
            [request.customObject setValue:delegate forKey:@"extDelegate"];
            [self savaBiddingDelegate:delegate withUnitID:request.unitID];
            break;
        }
        case OCTAdFormatSplash: {
            // 获取代理
            ATTMBiddingDelegate *delegate = [[ATTMBiddingDelegate alloc] init];
            delegate.unitID = request.unitID;
            [request.customObject setValue:delegate forKey:@"delegate"];
            [self savaBiddingDelegate:delegate withUnitID:request.unitID];
            break;
        }
        case MentaAdFormatSplash: {
//            ATTMBiddingDelegate *delegate = [[ATTMBiddingDelegate alloc] init];
//            delegate.unitID = request.unitID;
//            [self savaBiddingDelegate:delegate withUnitID:request.unitID];
            break;
        }
            
        case WangMaiAdFormatSplash: {
            ATTMBiddingDelegate *delegate = [[ATTMBiddingDelegate alloc] init];
            delegate.unitID = request.unitID;
            [request.customObject setValue:delegate forKey:@"delegate"];
            [self savaBiddingDelegate:delegate withUnitID:request.unitID];
            break;
        }
        case AdscopeAdFormatSplash: {
//            ATTMBiddingDelegate *delegate = [[ATTMBiddingDelegate alloc] init];
//            delegate.unitID = request.unitID;
//            [request.customObject setValue:delegate forKey:@"delegate"];
//            [self savaBiddingDelegate:delegate withUnitID:request.unitID];
            break;
        }
            
        default:
            break;
    }
}



@end
