//
//  AnyThinkMentaBiddingManager.m
//  AnyThinkMentaSplashAdapter
//
//  Created by jdy on 2024/4/11.
//

#import "AnyThinkMentaBiddingManagerInland.h"
#import "AnyThinkMentaSplashBiddingDelegateInland.h"

@interface AnyThinkMentaBiddingManagerInland ()

@property (nonatomic, strong) NSMutableDictionary *bidingAdStorageAccessor;
@property (nonatomic, strong) NSMutableDictionary *bidingAdDelegate;

@end

@implementation AnyThinkMentaBiddingManagerInland

+ (instancetype)sharedInstance {
    static AnyThinkMentaBiddingManagerInland *sharedInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedInstance = [[AnyThinkMentaBiddingManagerInland alloc] init];
        sharedInstance.bidingAdStorageAccessor = [NSMutableDictionary dictionary];
        sharedInstance.bidingAdDelegate = [NSMutableDictionary dictionary];
    });
    return sharedInstance;
}

- (AnyThinkMentaBiddingRequestInland *)getRequestItemWithUnitID:(NSString *)unitID {
    @synchronized (self) {
        return [self.bidingAdStorageAccessor objectForKey:unitID];
    }
    
}

- (void)removeRequestItmeWithUnitID:(NSString *)unitID {
    @synchronized (self) {
        [self.bidingAdStorageAccessor removeObjectForKey:unitID];
    }
}

- (void)savaBiddingDelegate:(AnyThinkMentaSplashBiddingDelegateInland *)delegate withUnitID:(NSString *)unitID {
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
- (void)startWithRequestItem:(AnyThinkMentaBiddingRequestInland *)request {
    
    if (request.UUID) {
        [self.bidingAdStorageAccessor setObject:request forKey:request.UUID];
    } else {
        [self.bidingAdStorageAccessor setObject:request forKey:request.unitID];
    }
    switch (request.adType) {
        case MentaAdFormatSplash: {
            // 获取代理
            AnyThinkMentaSplashBiddingDelegateInland *delegate = [[AnyThinkMentaSplashBiddingDelegateInland alloc] initWithInfo:request.extraInfo localInfo:request.extraInfo];
            delegate.placementID = request.unitID;
            [request.customObject setValue:delegate forKey:@"delegate"];
            [self savaBiddingDelegate:delegate withUnitID:request.unitID];
            break;
        }
        case MentaAdFormatNative: {
            break;
        }
        default:
            break;
    }
}

@end
