//
//  AnyThinkMentaInterstitialAdapter.m
//  AnyThinkMentaCustomAdapter
//
//  Created by jdy on 2024/4/15.
//

#import "AnyThinkMentaInterstitialAdapter.h"
#import "AnyThinkMentaBiddingManager.h"
#import "AnyThinkMentaInterstitialCustomEvent.h"
#import <MentaMediationGlobal/MentaMediationGlobal-umbrella.h>

@interface AnyThinkMentaInterstitialAdapter ()

@property (nonatomic, strong) MentaMediationInterstitial *interstitialAd;
@property (nonatomic, strong) AnyThinkMentaInterstitialCustomEvent *customEvent;

@end

@implementation AnyThinkMentaInterstitialAdapter

+ (BOOL)adReadyWithCustomObject:(id)customObject info:(NSDictionary*)info {
    MentaMediationInterstitial *ad = (MentaMediationInterstitial *)customObject;
    if ([ad.delegate isKindOfClass:AnyThinkMentaInterstitialCustomEvent.class]) {
        AnyThinkMentaInterstitialCustomEvent *event = (AnyThinkMentaInterstitialCustomEvent *)ad.delegate;
        return event.isReady;
    } else {
        return NO;
    }
}

+ (void)showInterstitial:(ATInterstitial*)interstitial
        inViewController:(UIViewController*)viewController
                delegate:(id<ATInterstitialDelegate>)delegate {
    interstitial.customEvent.delegate = delegate;
    [((MentaMediationInterstitial *)interstitial.customObject) showAdFromRootViewController:viewController];
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
        
        if (![[MentaAdSDK shared] isInitialized]) {
            [AnyThinkMentaInterstitialAdapter initMentaSDKWith:appID Key:appKey completion:nil];
        }
    }
    return self;
}

- (void)loadADWithInfo:(NSDictionary*)serverInfo localInfo:(NSDictionary*)localInfo completion:(void (^)(NSArray<NSDictionary *> *, NSError *))completion {
    
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
                    strongSelf.customEvent = (AnyThinkMentaInterstitialCustomEvent *)request.customEvent;
                    strongSelf.customEvent.requestCompletionBlock = completion;
                    
                    strongSelf.interstitialAd = (MentaMediationInterstitial *)request.customObject;
                    [strongSelf.customEvent trackInterstitialAdLoaded:self.interstitialAd adExtra:nil];
                }
                [[AnyThinkMentaBiddingManager sharedInstance] removeRequestItmeWithUnitID:slotID];
            } else {
                strongSelf.customEvent = [[AnyThinkMentaInterstitialCustomEvent alloc] initWithInfo:serverInfo localInfo:localInfo];
                strongSelf.customEvent.networkAdvertisingID = slotID;
                strongSelf.customEvent.requestCompletionBlock = completion;

                strongSelf.interstitialAd = [[MentaMediationInterstitial alloc] initWithPlacementID:slotID];
                strongSelf.interstitialAd.delegate = strongSelf.customEvent;
                [strongSelf.interstitialAd loadAd];
            }
        });
    };
    
    if ([[MentaAdSDK shared] isInitialized]) {
        load();
    } else {
        [AnyThinkMentaInterstitialAdapter initMentaSDKWith:appID Key:appKey completion:^{
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
    
    void(^startBiddingRequest)(void) = ^{
        AnyThinkMentaInterstitialCustomEvent *customEvent = [[AnyThinkMentaInterstitialCustomEvent alloc] initWithInfo:info localInfo:info];
        customEvent.isC2SBiding = YES;
        customEvent.networkAdvertisingID = slotID;
        
        AnyThinkMentaBiddingRequest *request = [[AnyThinkMentaBiddingRequest alloc] init];
        request.unitGroup = unitGroupModel;
        request.placementID = placementModel.placementID;
        request.customEvent = customEvent;
        request.bidCompletion = completion;
        request.unitID = slotID;
        request.extraInfo = info;
        request.adType = MentaAdFormatInterstitial;

        MentaMediationInterstitial *interstitialAd = [[MentaMediationInterstitial alloc] initWithPlacementID:slotID];
        interstitialAd.delegate = customEvent;
        
        request.customObject = interstitialAd;
        
        [[AnyThinkMentaBiddingManager sharedInstance] startWithRequestItem:request];
        [interstitialAd loadAd];
    };
    if ([[MentaAdSDK shared] isInitialized]) {
        startBiddingRequest();
    } else {
        [AnyThinkMentaInterstitialAdapter initMentaSDKWith:appID Key:appKey completion:^{
            startBiddingRequest();
        }];
    }
}

//// 返回广告位比价胜利时，第二的价格的回调，可在该回调中向三方平台返回竞胜价格  secondPrice：美元(USD)
+ (void) sendWinnerNotifyWithCustomObject:(id)customObject secondPrice:(NSString*)price userInfo:(NSDictionary<NSString *, NSString *> *)userInfo {
    NSLog(@"------> menta interstitial ad win");
    if ([customObject isKindOfClass:MentaMediationInterstitial.class]) {
        MentaMediationInterstitial *ad = (MentaMediationInterstitial *)customObject;
        [ad sendWinnerNotificationWith:nil];
    }
}

//// 返回广告位比价输了的回调，可在该回调中向三方平台返回竞败价格 winPrice：美元(USD)
+ (void)sendLossNotifyWithCustomObject:(nonnull id)customObject lossType:(ATBiddingLossType)lossType winPrice:(nonnull NSString *)price userInfo:(NSDictionary *)userInfo {
    NSLog(@"------> menta interstitial loss");
    if ([customObject isKindOfClass:MentaMediationInterstitial.class]) {
        MentaMediationInterstitial *ad = (MentaMediationInterstitial *)customObject;
        double ecpm = price.doubleValue *100;
        [ad sendLossNotificationWithWinnerPrice:[NSString stringWithFormat:@"%f", ecpm] info:@{@"loss_reason": @"101"}];
    }
}

#pragma mark - private method

+ (void)initMentaSDKWith:(NSString*)appID
                     Key:(NSString *)appKey
              completion:(void (^)(void))completion {
    NSLog(@"------> start init menta sdk");
    [[MentaAdSDK shared] startWithAppID:appID appKey:appKey finishBlock:^(BOOL success, NSError * _Nullable error) {
        if (success && completion != nil) {
            completion();
        }
    }];
}

- (void)dealloc
{
    NSLog(@"------> %s", __FUNCTION__);
}


@end
