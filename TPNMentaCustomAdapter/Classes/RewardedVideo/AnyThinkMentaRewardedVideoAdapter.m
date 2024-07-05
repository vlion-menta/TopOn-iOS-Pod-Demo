//
//  AnyThinkMentaRewardedVideoAdapter.m
//  AnyThinkMentaCustomAdapter
//
//  Created by jdy on 2024/4/15.
//

#import "AnyThinkMentaRewardedVideoAdapter.h"
#import <MentaUnifiedSDK/MentaUnifiedSDK.h>
#import "AnyThinkMentaRewardedVideoCustomEvent.h"
#import "AnyThinkMentaBiddingManager.h"

@interface AnyThinkMentaRewardedVideoAdapter ()

@property (nonatomic, strong) AnyThinkMentaRewardedVideoCustomEvent *customEvent;
@property (nonatomic, strong) MentaUnifiedRewardVideoAd *rewardedVideo;

@end

@implementation AnyThinkMentaRewardedVideoAdapter

+ (BOOL)adReadyWithCustomObject:(id)customObject info:(NSDictionary*)info {
    MentaUnifiedRewardVideoAd *rewardedVideo = (MentaUnifiedRewardVideoAd *)customObject;
    if ([rewardedVideo.delegate isKindOfClass:AnyThinkMentaRewardedVideoCustomEvent.class]) {
        AnyThinkMentaRewardedVideoCustomEvent *event = (AnyThinkMentaRewardedVideoCustomEvent *)rewardedVideo.delegate;
        return event.isReady;
    } else {
        return NO;
    }
}

+ (void)showRewardedVideo:(ATRewardedVideo*)rewardedVideo 
         inViewController:(UIViewController*)viewController
                 delegate:(id<ATRewardedVideoDelegate>)delegate {
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
            [AnyThinkMentaRewardedVideoAdapter initMentaSDKWith:appID Key:appKey completion:nil];
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
                AnyThinkMentaBiddingRequest *request = [[AnyThinkMentaBiddingManager sharedInstance] getRequestItemWithUnitID:slotID];
                if (request != nil && request.customObject) {
                    strongSelf.customEvent = (AnyThinkMentaRewardedVideoCustomEvent *)request.customEvent;
                    strongSelf.customEvent.requestCompletionBlock = completion;
                    strongSelf.customEvent.customEventMetaDataDidLoadedBlock = strongSelf.metaDataDidLoadedBlock;
                    strongSelf.rewardedVideo = request.customObject;
                    if (strongSelf.customEvent.isReady) {
                        [strongSelf.customEvent trackRewardedVideoAdLoaded:strongSelf.rewardedVideo adExtra:nil];
                    }
                    [[AnyThinkMentaBiddingManager sharedInstance] removeRequestItmeWithUnitID:slotID];
                    return;
                }
            } else {
                strongSelf.customEvent = [[AnyThinkMentaRewardedVideoCustomEvent alloc] initWithInfo:serverInfo localInfo:localInfo];
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
        [AnyThinkMentaRewardedVideoAdapter initMentaSDKWith:appID Key:appKey completion:^{
            load();
        }];
    }
}

#pragma mark - AlexC2SBiddingRequestProtocol
+ (void)bidRequestWithPlacementModel:(nonnull ATPlacementModel *)placementModel 
                      unitGroupModel:(nonnull ATUnitGroupModel *)unitGroupModel
                                info:(nonnull NSDictionary *)info
                          completion:(nonnull void (^)(ATBidInfo * _Nonnull, NSError * _Nonnull))completion {
    NSLog(@"------> menta start bidding");
    NSString *appIDKey = @"appid";
    if([info.allKeys containsObject:@"appId"]) {
        appIDKey = @"appId";
    }
    NSString *appID = info[appIDKey];
    NSString *appKey = info[@"appKey"];
    NSString *slotID = info[@"slotID"];
    
    void(^startRequest)(void) = ^{
        AnyThinkMentaRewardedVideoCustomEvent *customEvent = [[AnyThinkMentaRewardedVideoCustomEvent alloc] initWithInfo:info localInfo:info];
        customEvent.isC2SBiding = YES;
        customEvent.networkAdvertisingID = slotID;
        
        AnyThinkMentaBiddingRequest *request = [[AnyThinkMentaBiddingRequest alloc] init];
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
        [[AnyThinkMentaBiddingManager sharedInstance] startWithRequestItem:request];
        
        [rewardVideoAd loadAd];
    };
    if ([MUAPI isInitialized]) {
        startRequest();
    } else {
        [AnyThinkMentaRewardedVideoAdapter initMentaSDKWith:appID Key:appKey completion:^{
            startRequest();
        }];
    }
}

//// 返回广告位比价胜利时，第二的价格的回调，可在该回调中向三方平台返回竞胜价格  secondPrice：美元(USD)
+ (void) sendWinnerNotifyWithCustomObject:(id)customObject secondPrice:(NSString*)price userInfo:(NSDictionary<NSString *, NSString *> *)userInfo {
    NSLog(@"------> menta reward video ad win");
}

//// 返回广告位比价输了的回调，可在该回调中向三方平台返回竞败价格 winPrice：美元(USD)
+ (void)sendLossNotifyWithCustomObject:(nonnull id)customObject lossType:(ATBiddingLossType)lossType winPrice:(nonnull NSString *)price userInfo:(NSDictionary *)userInfo {
    NSLog(@"------> menta reward video ad loss");
    if ([customObject isKindOfClass:MentaUnifiedRewardVideoAd.class]) {
        MentaUnifiedRewardVideoAd *ad = (MentaUnifiedRewardVideoAd *)customObject;
        [ad sendLossNotificationWithInfo:@{MU_M_L_WIN_PRICE : @([price integerValue] * 100)}];
    }
}

#pragma mark - private method

+ (void)initMentaSDKWith:(NSString*)appID
                     Key:(NSString *)appKey
              completion:(void (^)(void))completion {
    NSLog(@"------> start init menta sdk");
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
    NSLog(@"------> %s", __FUNCTION__);
}

@end
