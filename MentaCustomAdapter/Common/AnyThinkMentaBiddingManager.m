//
//  AnyThinkMentaBiddingManager.m
//  AnyThinkMentaSplashAdapter
//
//  Created by jdy on 2024/4/11.
//

#import "AnyThinkMentaBiddingManager.h"
#import "AnyThinkMentaSplashBiddingDelegate.h"

@interface AnyThinkMentaBiddingManager ()

@property (nonatomic, strong) NSMutableDictionary *bidingAdStorageAccessor;
@property (nonatomic, strong) NSMutableDictionary *bidingAdDelegate;

@end

@implementation AnyThinkMentaBiddingManager

+ (instancetype)sharedInstance {
    static AnyThinkMentaBiddingManager *sharedInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedInstance = [[AnyThinkMentaBiddingManager alloc] init];
        sharedInstance.bidingAdStorageAccessor = [NSMutableDictionary dictionary];
        sharedInstance.bidingAdDelegate = [NSMutableDictionary dictionary];
    });
    return sharedInstance;
}

- (AnyThinkMentaBiddingRequest *)getRequestItemWithUnitID:(NSString *)unitID {
    @synchronized (self) {
        return [self.bidingAdStorageAccessor objectForKey:unitID];
    }
    
}

- (void)removeRequestItmeWithUnitID:(NSString *)unitID {
    @synchronized (self) {
        [self.bidingAdStorageAccessor removeObjectForKey:unitID];
    }
}

- (void)savaBiddingDelegate:(AnyThinkMentaSplashBiddingDelegate *)delegate withUnitID:(NSString *)unitID {
    @synchronized (self) {
        [self.bidingAdDelegate setObject:delegate forKey:unitID];
    }
}

- (void)removeBiddingDelegateWithUnitID:(NSString *)unitID {
    @synchronized (self) {
        if (unitID.length) {
            [self.bidingAdDelegate removeObjectForKey:unitID];
        }
    }
}

// 保存相应的竞价request，并向不同广告类型完成绑定
- (void)startWithRequestItem:(AnyThinkMentaBiddingRequest *)request {
    
    [self.bidingAdStorageAccessor setObject:request forKey:request.unitID];
    
    switch (request.adType) {
        case MentaAdFormatSplash: {
            // 获取代理
            AnyThinkMentaSplashBiddingDelegate *delegate = [[AnyThinkMentaSplashBiddingDelegate alloc] initWithInfo:request.extraInfo localInfo:request.extraInfo];
            delegate.placementID = request.unitID;
            [request.customObject setValue:delegate forKey:@"delegate"];
            [self savaBiddingDelegate:delegate withUnitID:request.unitID];
            break;
        }
        case MentaAdFormatNativeExpress: {
            break;
        }
        default:
            break;
    }
}

@end
