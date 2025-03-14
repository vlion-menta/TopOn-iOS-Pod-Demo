//
//  AnyThinkMentaRewardedVideoAdapter.m
//  AnyThinkMentaCustomAdapter
//
//  Created by jdy on 2024/4/15.
//

#import "AnyThinkMentaRewardedVideoAdapterInland.h"
#import <MentaUnifiedSDK/MentaUnifiedSDK-umbrella.h>
#import "AnyThinkMentaRewardedVideoCustomEventInland.h"
#import "AnyThinkMentaBiddingManagerInland.h"

@interface AnyThinkMentaRewardedVideoAdapterInland ()

@property (nonatomic, strong) AnyThinkMentaRewardedVideoCustomEventInland *customEvent;
@property (nonatomic, strong) MentaUnifiedRewardVideoAd *rewardedVideo;

@end

@implementation AnyThinkMentaRewardedVideoAdapterInland

+ (BOOL)adReadyWithCustomObject:(id)customObject info:(NSDictionary*)info {
    MentaUnifiedRewardVideoAd *rewardedVideo = (MentaUnifiedRewardVideoAd *)customObject;
    if ([rewardedVideo.delegate isKindOfClass:AnyThinkMentaRewardedVideoCustomEventInland.class]) {
        AnyThinkMentaRewardedVideoCustomEventInland *event = (AnyThinkMentaRewardedVideoCustomEventInland *)rewardedVideo.delegate;
        return event.isReady;
    } else {
        return NO;
    }
}

+ (void)showRewardedVideo:(ATRewardedVideo*)rewardedVideo 
         inViewController:(UIViewController*)viewController
                 delegate:(id<ATRewardedVideoDelegate>)delegate {
    rewardedVideo.customEvent.delegate = delegate;
    [((MentaUnifiedRewardVideoAd *)rewardedVideo.customObject) showAdFromRootViewController:viewController];
}

- (instancetype)initWithNetworkCustomInfo:(NSDictionary*)serverInfo localInfo:(NSDictionary*)localInfo {
    self = [super init];
    if (self != nil) {
        NSString *appIDKey = @"appid";
        if([serverInfo.allKeys containsObject:@"appId"]) {
            appIDKey = @"appId";
        }
        NSString *appID = serverInfo[appIDKey];
        NSString *appKey = serverInfo[@"appKey"];
        
        if (![MUAPI isInitialized]) {
            [AnyThinkMentaRewardedVideoAdapterInland initMentaSDKWith:appID Key:appKey completion:nil];
        }
    }
    return self;
}

- (void)loadADWithInfo:(NSDictionary*)serverInfo 
             localInfo:(NSDictionary*)localInfo
            completion:(void (^)(NSArray<NSDictionary *> *, NSError *))completion {
    
    NSString *appIDKey = @"appid";
    if([serverInfo.allKeys containsObject:@"appId"]) {
        appIDKey = @"appId";
    }
    NSString *appID = serverInfo[appIDKey];
    NSString *appKey = serverInfo[@"appKey"];
    NSString *slotID = serverInfo[@"slotID"];
    NSString *bidId = serverInfo[kATAdapterCustomInfoBuyeruIdKey];
    
    __weak __typeof(self)weakSelf = self;
    void(^load)(void) = ^{
        __strong __typeof(weakSelf)strongSelf = weakSelf;
        dispatch_async(dispatch_get_main_queue(), ^{
            if (bidId) {
                AnyThinkMentaBiddingRequestInland *request = [[AnyThinkMentaBiddingManagerInland sharedInstance] getRequestItemWithUnitID:slotID];
                if (request != nil && request.customObject) {
                    strongSelf.customEvent = (AnyThinkMentaRewardedVideoCustomEventInland *)request.customEvent;
                    strongSelf.customEvent.requestCompletionBlock = completion;
                    strongSelf.customEvent.customEventMetaDataDidLoadedBlock = strongSelf.metaDataDidLoadedBlock;
                    strongSelf.rewardedVideo = request.customObject;
                    if (strongSelf.customEvent.isReady) {
                        [strongSelf.customEvent trackRewardedVideoAdLoaded:strongSelf.rewardedVideo adExtra:nil];
                    }
                    [[AnyThinkMentaBiddingManagerInland sharedInstance] removeRequestItmeWithUnitID:slotID];
                    return;
                }
            } else {
                strongSelf.customEvent = [[AnyThinkMentaRewardedVideoCustomEventInland alloc] initWithInfo:serverInfo localInfo:localInfo];
                strongSelf.customEvent.networkAdvertisingID = slotID;
                strongSelf.customEvent.requestCompletionBlock = completion;
                strongSelf.customEvent.customEventMetaDataDidLoadedBlock = strongSelf.metaDataDidLoadedBlock;
                
                MURewardVideoConfig *config = [[MURewardVideoConfig alloc] init];
                config.adSize = UIScreen.mainScreen.bounds.size;
                config.slotId = slotID;
                config.videoGravity = MentaRewardVideoAdViewGravity_ResizeAspect;
                strongSelf.rewardedVideo = [[MentaUnifiedRewardVideoAd alloc] initWithConfig:config];
                strongSelf.rewardedVideo.delegate = strongSelf.customEvent;
                
                [strongSelf.rewardedVideo loadAd];
            }
        });
    };
    
    if ([MUAPI isInitialized]) {
        load();
    } else {
        [AnyThinkMentaRewardedVideoAdapterInland initMentaSDKWith:appID Key:appKey completion:^{
            load();
        }];
    }
}

#pragma mark - AlexC2SBiddingRequestProtocol
+ (void)bidRequestWithPlacementModel:(nonnull ATPlacementModel *)placementModel 
                      unitGroupModel:(nonnull ATUnitGroupModel *)unitGroupModel
                                info:(nonnull NSDictionary *)info
                          completion:(nonnull void (^)(ATBidInfo * _Nonnull, NSError * _Nonnull))completion {
    MentaLog(@"------> menta start bidding");
    NSString *appIDKey = @"appid";
    if([info.allKeys containsObject:@"appId"]) {
        appIDKey = @"appId";
    }
    NSString *appID = info[appIDKey];
    NSString *appKey = info[@"appKey"];
    NSString *slotID = info[@"slotID"];
    
    void(^startRequest)(void) = ^{
        AnyThinkMentaRewardedVideoCustomEventInland *customEvent = [[AnyThinkMentaRewardedVideoCustomEventInland alloc] initWithInfo:info localInfo:info];
        customEvent.isC2SBiding = YES;
        customEvent.networkAdvertisingID = slotID;
        
        AnyThinkMentaBiddingRequestInland *request = [[AnyThinkMentaBiddingRequestInland alloc] init];
        request.unitGroup = unitGroupModel;
        request.placementID = placementModel.placementID;
        request.customEvent = customEvent;
        request.bidCompletion = completion;
        request.unitID = slotID;
        request.extraInfo = info;
        request.adType = MentaAdFormatRewardedVideo;
        
        MURewardVideoConfig *config = [[MURewardVideoConfig alloc] init];
        config.adSize = UIScreen.mainScreen.bounds.size;
        config.slotId = slotID;
        config.videoGravity = MentaRewardVideoAdViewGravity_ResizeAspect;
        MentaUnifiedRewardVideoAd *rewardVideoAd = [[MentaUnifiedRewardVideoAd alloc] initWithConfig:config];
        rewardVideoAd.delegate = customEvent;
        
        request.customObject = rewardVideoAd;
        [[AnyThinkMentaBiddingManagerInland sharedInstance] startWithRequestItem:request];
        
        [rewardVideoAd loadAd];
    };
    if ([MUAPI isInitialized]) {
        startRequest();
    } else {
        [AnyThinkMentaRewardedVideoAdapterInland initMentaSDKWith:appID Key:appKey completion:^{
            startRequest();
        }];
    }
}

//// 返回广告位比价胜利时，第二的价格的回调，可在该回调中向三方平台返回竞胜价格  secondPrice：美元(USD)
+ (void) sendWinnerNotifyWithCustomObject:(id)customObject secondPrice:(NSString*)price userInfo:(NSDictionary<NSString *, NSString *> *)userInfo {
    MentaLog(@"------> menta reward video ad win");
    if ([customObject isKindOfClass:MentaUnifiedRewardVideoAd.class]) {
        MentaUnifiedRewardVideoAd *ad = (MentaUnifiedRewardVideoAd *)customObject;
        [ad sendWinNotification];
    }
}

//// 返回广告位比价输了的回调，可在该回调中向三方平台返回竞败价格 winPrice：美元(USD)
+ (void)sendLossNotifyWithCustomObject:(nonnull id)customObject lossType:(ATBiddingLossType)lossType winPrice:(nonnull NSString *)price userInfo:(NSDictionary *)userInfo {
    MentaLog(@"------> menta reward video ad loss");
    if ([customObject isKindOfClass:MentaUnifiedRewardVideoAd.class]) {
        MentaUnifiedRewardVideoAd *ad = (MentaUnifiedRewardVideoAd *)customObject;
        [ad sendLossNotificationWithInfo:@{MU_M_L_WIN_PRICE : @([price integerValue] * 100)}];
    }
}

#pragma mark - private method

+ (void)initMentaSDKWith:(NSString*)appID
                     Key:(NSString *)appKey
              completion:(void (^)(void))completion {
    MentaLog(@"------> start init menta sdk");
    [MUAPI enableLog:YES];
    [MUAPI startWithAppID:appID
                   appKey:appKey
              finishBlock:^(BOOL success, NSError * _Nullable error) {
        if (success && completion != nil) {
            completion();
        }
    }];
}

+ (MentaUnifiedRewardVideoAd *)initRewardedAdWith:(NSString *)slotID {
    MURewardVideoConfig *config = [[MURewardVideoConfig alloc] init];
    config.adSize = UIScreen.mainScreen.bounds.size;
    config.slotId = slotID;
    config.videoGravity = MentaRewardVideoAdViewGravity_ResizeAspect;
    
    return [[MentaUnifiedRewardVideoAd alloc] initWithConfig:config];
}

- (void)dealloc
{
    MentaLog(@"------> %s", __FUNCTION__);
}

@end
