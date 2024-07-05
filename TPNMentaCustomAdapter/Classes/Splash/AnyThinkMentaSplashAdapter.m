//
//  AnyThinkMentaSplashAdapter.m
//  AnyThinkMentaSplashAdapter
//
//  Created by jdy on 2024/4/11.
//

#import "AnyThinkMentaSplashAdapter.h"
#import "AnyThinkMentaSplashCustomEvent.h"
#import "AnyThinkMentaBiddingManager.h"
#import "AnyThinkMentaSplashBiddingDelegate.h"
#import <MentaMediationGlobal/MentaMediationGlobal-umbrella.h>

@interface AnyThinkMentaSplashAdapter ()

@property (nonatomic, strong) AnyThinkMentaSplashCustomEvent *customEvent;
@property (nonatomic, strong) MentaMediationSplash *splash;

@end

@implementation AnyThinkMentaSplashAdapter

// 注册三方广告平台的SDK
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
            [AnyThinkMentaSplashAdapter initMentaSDKWith:appID Key:appKey completion:nil];
        }
    }
    return self;
}

// 竞价完成并发送了ATBidInfo给SDK后，来到该方法，或普通广告源加载广告来到该方法
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
    
    if ((!appID || !appKey || !slotID) && completion != nil) {
        NSError *err = [NSError errorWithDomain:@"com.menta.mediation.ios"
                                           code:1
                                       userInfo:@{NSLocalizedDescriptionKey:@"Bid request has failed", NSLocalizedFailureReasonErrorKey:@"Menta config is error"}];
        completion( nil, err);
        return;
    }
    
    NSTimeInterval tolerateTimeout = localInfo[kATSplashExtraTolerateTimeoutKey] ? [localInfo[kATSplashExtraTolerateTimeoutKey] doubleValue] : 5.0;
    if (tolerateTimeout > 0) {
        self.customEvent = [[AnyThinkMentaSplashCustomEvent alloc] initWithInfo:serverInfo localInfo:localInfo];
        self.customEvent.requestCompletionBlock = completion;
        self.customEvent.delegate = self.delegateToBePassed;
        
        AnyThinkMentaBiddingRequest *request = [[AnyThinkMentaBiddingManager sharedInstance] getRequestItemWithUnitID:slotID];
        if (request) { //竞价失败不会进入该方法，所以处理竞价成功的逻辑
            if (request.customObject != nil) { // load secced 且 广告数据可用(原则上是检查广告是否可用的)
                self.splash = request.customObject;
                AnyThinkMentaSplashBiddingDelegate *delegate = (AnyThinkMentaSplashBiddingDelegate *)self.splash.delegate;
                if (delegate.isReady) {
                    // 返回加载完成
                    NSLog(@"------> menta bidding success");
                    delegate.requestCompletionBlock = completion;
                    delegate.delegate = self.delegateToBePassed;
                    delegate.isReady = YES;
                    [delegate trackSplashAdLoaded:self.splash];
                } else {
                    NSError *error = [NSError errorWithDomain:ATADLoadingErrorDomain code:ATADLoadingErrorCodeThirdPartySDKNotImportedProperly userInfo:@{NSLocalizedDescriptionKey:@"menta has failed to load splash.", NSLocalizedFailureReasonErrorKey:@"It took too long to load placement stragety."}];
                    // 返回加载失败
                    [delegate trackSplashAdLoadFailed:error];
                }
            }
            [[AnyThinkMentaBiddingManager sharedInstance] removeRequestItmeWithUnitID:slotID];
        } else {
            // 普通瀑布流的广告配置，进行加载广告
            dispatch_async(dispatch_get_main_queue(), ^{
                self.splash = [AnyThinkMentaSplashAdapter initSplashAdWith:slotID];
                self.splash.delegate = self.customEvent;
                [self.splash loadSplashAd];
                
            });
        }
    } else {
        completion(nil, [NSError errorWithDomain:ATADLoadingErrorDomain code:ATADLoadingErrorCodeThirdPartySDKNotImportedProperly userInfo:@{NSLocalizedDescriptionKey:@"AT has failed to load splash.", NSLocalizedFailureReasonErrorKey:@"It took too long to load placement stragety."}]);
    }
}

// 外部调用了show的API后，来到该方法。请实现三方平台的展示逻辑。
+ (void)showSplash:(ATSplash *)splash localInfo:(NSDictionary*)localInfo delegate:(id<ATSplashDelegate>)delegate {
    MentaMediationSplash *splashAd = splash.customObject;
    if ([splashAd.delegate isKindOfClass:AnyThinkMentaSplashCustomEvent.class]) {
        AnyThinkMentaSplashCustomEvent *event = (AnyThinkMentaSplashCustomEvent *)splashAd.delegate;
        if (event.isReady) {
            [splashAd showAdInWindow:UIApplication.sharedApplication.keyWindow];
        }
    } else if ([splashAd.delegate isKindOfClass:AnyThinkMentaSplashBiddingDelegate.class]) {
        AnyThinkMentaSplashBiddingDelegate *delegate = (AnyThinkMentaSplashBiddingDelegate *)splashAd.delegate;
        if (delegate.isReady) {
            [splashAd showAdInWindow:UIApplication.sharedApplication.keyWindow];
        }
    }
}

// 返回三方广告平台的广告对象是否可使用，例如穿山甲的开屏广告的 adValid 属性
+ (BOOL)adReadyWithCustomObject:(id)customObject info:(NSDictionary*)info{
    MentaMediationSplash *splashAd = (MentaMediationSplash *)customObject;
    if ([splashAd.delegate isKindOfClass:AnyThinkMentaSplashCustomEvent.class]) {
        AnyThinkMentaSplashCustomEvent *event = (AnyThinkMentaSplashCustomEvent *)splashAd.delegate;
        return event.isReady;
    } else if ([splashAd.delegate isKindOfClass:AnyThinkMentaSplashBiddingDelegate.class]) {
        AnyThinkMentaSplashBiddingDelegate *delegate = (AnyThinkMentaSplashBiddingDelegate *)splashAd.delegate;
        return delegate.isReady;
    }
    return NO;
}

#pragma mark - Header bidding
#pragma mark - c2s
// 后台配置了C2S的竞价广告会先来到这个方法，完成相应的竞价请求
+ (void)bidRequestWithPlacementModel:(ATPlacementModel*)placementModel
                      unitGroupModel:(ATUnitGroupModel*)unitGroupModel
                                info:(NSDictionary*)info
                          completion:(void(^)(ATBidInfo *bidInfo, NSError *error))completion {
    NSLog(@"------> menta start bidding");
    NSString *appIDKey = @"appid";
    if([info.allKeys containsObject:@"appId"]) {
        appIDKey = @"appId";
    }
    NSString *appID = info[appIDKey];
    NSString *appKey = info[@"appKey"];
    NSString *slotID = info[@"slotID"];
    
    if ((!appID || !appKey || !slotID) && completion != nil) {
        NSError *err = [NSError errorWithDomain:@"com.menta.mediation.ios"
                                           code:1
                                       userInfo:@{NSLocalizedDescriptionKey:@"Bid request has failed", NSLocalizedFailureReasonErrorKey:@"Menta config is error"}];
        completion( nil, err);
        return;
    }
        
    __weak __typeof(self)weakSelf = self;
    [AnyThinkMentaSplashAdapter initMentaSDKWith:appID Key:appKey completion:^{
        __strong __typeof(weakSelf)strongSelf = weakSelf;
        
        AnyThinkMentaBiddingRequest *request = [[AnyThinkMentaBiddingRequest alloc] init];
        request.unitGroup = unitGroupModel;
        request.placementID = placementModel.placementID;
        request.bidCompletion = completion;
        request.unitID = slotID;
        request.extraInfo = info;
        request.adType = MentaAdFormatSplash;
        
        MentaMediationSplash *splashAd = [strongSelf initSplashAdWith:slotID];
        
        request.customObject = splashAd;
        [[AnyThinkMentaBiddingManager sharedInstance] startWithRequestItem:request];
        [splashAd loadSplashAd];
    }];
}

//// 返回广告位比价胜利时，第二的价格的回调，可在该回调中向三方平台返回竞胜价格  secondPrice：美元(USD)
+ (void) sendWinnerNotifyWithCustomObject:(id)customObject secondPrice:(NSString*)price userInfo:(NSDictionary<NSString *, NSString *> *)userInfo {
    NSLog(@"------> menta splash ad win");
    if ([customObject isKindOfClass:MentaMediationSplash.class]) {
        MentaMediationSplash *splashAd = (MentaMediationSplash *)customObject;
        [splashAd sendWinnerNotification];
    }
}

//// 返回广告位比价输了的回调，可在该回调中向三方平台返回竞败价格 winPrice：美元(USD)
+ (void)sendLossNotifyWithCustomObject:(nonnull id)customObject lossType:(ATBiddingLossType)lossType winPrice:(nonnull NSString *)price userInfo:(NSDictionary *)userInfo {
    NSLog(@"------> menta splash ad loss");
    if ([customObject isKindOfClass:MentaMediationSplash.class]) {
        MentaMediationSplash *splashAd = (MentaMediationSplash *)customObject;
        double ecpm = price.doubleValue * 100;
        [splashAd sendLossNotificationWith:[NSString stringWithFormat:@"%f", ecpm]];
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

+ (MentaMediationSplash *)initSplashAdWith:(NSString *)slotID {
    return [[MentaMediationSplash alloc] initWithPlacementID:slotID];
}

- (void)dealloc
{
    NSLog(@"------> %s", __FUNCTION__);
}

@end
