//
//  AnyThinkMentaSplashAdapter.m
//  AnyThinkMentaSplashAdapter
//
//  Created by jdy on 2024/4/11.
//

#import "AnyThinkMentaSplashAdapterInland.h"
#import <MentaUnifiedSDK/MentaUnifiedSDK.h>
#import "AnyThinkMentaSplashCustomEventInland.h"
#import "AnyThinkMentaBiddingManagerInland.h"
#import "AnyThinkMentaSplashBiddingDelegateInland.h"

@interface AnyThinkMentaSplashAdapterInland ()

@property (nonatomic, strong) AnyThinkMentaSplashCustomEventInland *customEvent;
@property (nonatomic, strong) MentaUnifiedSplashAd *splashView;

@end

@implementation AnyThinkMentaSplashAdapterInland

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
        
        if (![MUAPI isInitialized]) {
            [AnyThinkMentaSplashAdapterInland initMentaSDKWith:appID Key:appKey completion:nil];
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
        self.customEvent = [[AnyThinkMentaSplashCustomEventInland alloc] initWithInfo:serverInfo localInfo:localInfo];
        self.customEvent.requestCompletionBlock = completion;
        
        AnyThinkMentaBiddingRequestInland *request = [[AnyThinkMentaBiddingManagerInland sharedInstance] getRequestItemWithUnitID:slotID];
        if (request) { //竞价失败不会进入该方法，所以处理竞价成功的逻辑
            if (request.customObject != nil) { // load secced 且 广告数据可用(原则上是检查广告是否可用的)
                self.splashView = request.customObject;
                AnyThinkMentaSplashBiddingDelegateInland *delegate = (AnyThinkMentaSplashBiddingDelegateInland *)self.splashView.delegate;
                if (delegate.isReady) {
                    // 返回加载完成
                    NSLog(@"------> menta bidding success");
                    delegate.requestCompletionBlock = completion;
                    delegate.isReady = YES;
                    [delegate trackSplashAdLoaded:self.splashView];
                } else {
                    NSError *error = [NSError errorWithDomain:ATADLoadingErrorDomain code:1001 userInfo:@{NSLocalizedDescriptionKey:@"menta has failed to load splash.", NSLocalizedFailureReasonErrorKey:@"It took too long to load placement stragety."}];
                    // 返回加载失败
                    [delegate trackSplashAdLoadFailed:error];
                }
            }
            [[AnyThinkMentaBiddingManagerInland sharedInstance] removeRequestItmeWithUnitID:slotID];
        } else {
            // 普通瀑布流的广告配置，进行加载广告
            dispatch_async(dispatch_get_main_queue(), ^{
                self.splashView = [AnyThinkMentaSplashAdapterInland initSplashAdWith:slotID];
                self.splashView.delegate = self.customEvent;
                [self.splashView loadAd];
                
            });
        }
    } else {
        completion(nil, [NSError errorWithDomain:ATADLoadingErrorDomain code:1001 userInfo:@{NSLocalizedDescriptionKey:@"AT has failed to load splash.", NSLocalizedFailureReasonErrorKey:@"It took too long to load placement stragety."}]);
    }
}

// 外部调用了show的API后，来到该方法。请实现三方平台的展示逻辑。
+ (void)showSplash:(ATSplash *)splash localInfo:(NSDictionary*)localInfo delegate:(id<ATSplashDelegate>)delegate {
    MentaUnifiedSplashAd *splashAd = splash.customObject;
    UIWindow *window = (UIWindow *)localInfo[@"window"];
    if (!window) {
        window = UIApplication.sharedApplication.keyWindow;
        return;
    }
    if ([splashAd.delegate isKindOfClass:AnyThinkMentaSplashCustomEventInland.class]) {
        AnyThinkMentaSplashCustomEventInland *event = (AnyThinkMentaSplashCustomEventInland *)splashAd.delegate;
        if (event.isReady) {
            [splashAd showInWindow:window];
        }
    } else if ([splashAd.delegate isKindOfClass:AnyThinkMentaSplashBiddingDelegateInland.class]) {
        AnyThinkMentaSplashBiddingDelegateInland *delegate = (AnyThinkMentaSplashBiddingDelegateInland *)splashAd.delegate;
        if (delegate.isReady) {
            [splashAd showInWindow:window];
        }
    }
}

// 返回三方广告平台的广告对象是否可使用，例如穿山甲的开屏广告的 adValid 属性
+ (BOOL)adReadyWithCustomObject:(id)customObject info:(NSDictionary*)info{
    MentaUnifiedSplashAd *splashAd = (MentaUnifiedSplashAd *)customObject;
    if ([splashAd.delegate isKindOfClass:AnyThinkMentaSplashCustomEventInland.class]) {
        AnyThinkMentaSplashCustomEventInland *event = (AnyThinkMentaSplashCustomEventInland *)splashAd.delegate;
        return event.isReady;
    } else if ([splashAd.delegate isKindOfClass:AnyThinkMentaSplashBiddingDelegateInland.class]) {
        AnyThinkMentaSplashBiddingDelegateInland *delegate = (AnyThinkMentaSplashBiddingDelegateInland *)splashAd.delegate;
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
    [AnyThinkMentaSplashAdapterInland initMentaSDKWith:appID Key:appKey completion:^{
        __strong __typeof(weakSelf)strongSelf = weakSelf;
        
        AnyThinkMentaBiddingRequestInland *request = [[AnyThinkMentaBiddingRequestInland alloc] init];
        request.unitGroup = unitGroupModel;
        request.placementID = placementModel.placementID;
        request.bidCompletion = completion;
        request.unitID = slotID;
        request.extraInfo = info;
        request.adType = MentaAdFormatSplash;
        
        MentaUnifiedSplashAd *splashAd = [strongSelf initSplashAdWith:slotID];
        
        request.customObject = splashAd;
        [[AnyThinkMentaBiddingManagerInland sharedInstance] startWithRequestItem:request];
        [splashAd loadAd];
    }];
}

//// 返回广告位比价胜利时，第二的价格的回调，可在该回调中向三方平台返回竞胜价格  secondPrice：美元(USD)
+ (void) sendWinnerNotifyWithCustomObject:(id)customObject secondPrice:(NSString*)price userInfo:(NSDictionary<NSString *, NSString *> *)userInfo {
    NSLog(@"------> menta splash ad win");
    if ([customObject isKindOfClass:MentaUnifiedSplashAd.class]) {
        MentaUnifiedSplashAd *splashAd = (MentaUnifiedSplashAd *)customObject;
        [splashAd sendWinNotification];
    }
}

//// 返回广告位比价输了的回调，可在该回调中向三方平台返回竞败价格 winPrice：美元(USD)
+ (void)sendLossNotifyWithCustomObject:(nonnull id)customObject lossType:(ATBiddingLossType)lossType winPrice:(nonnull NSString *)price userInfo:(NSDictionary *)userInfo {
    NSLog(@"------> menta splash ad loss");
    if ([customObject isKindOfClass:MentaUnifiedSplashAd.class]) {
        MentaUnifiedSplashAd *splashAd = (MentaUnifiedSplashAd *)customObject;
        [splashAd sendLossNotificationWithInfo:@{MU_M_L_WIN_PRICE : @([price integerValue] * 100)}];
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

+ (MentaUnifiedSplashAd *)initSplashAdWith:(NSString *)slotID {
    MUSplashConfig *config = [MUSplashConfig new];
    config.slotId = slotID;
    config.adSize = [UIScreen mainScreen].bounds.size;
    config.tolerateTime = 5;
    config.materialFillMode = MentaSplashAdMaterialFillMode_ScaleAspectFill;
    return [[MentaUnifiedSplashAd alloc] initWithConfig:config];
}

- (void)dealloc
{
    NSLog(@"------> %s", __FUNCTION__);
}

@end
