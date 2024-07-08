//
//  AnyThinkMentaNativeAdapter.m
//  AnyThinkMentaCustomAdapter
//
//  Created by jdy on 2024/4/12.
//

#import "AnyThinkMentaNativeAdapter.h"
#import "AnyThinkMentaNativeCustomEvent.h"
#import "AnyThinkMentaNativeRender.h"
#import "AnyThinkMentaBiddingManager.h"
#import "AnyThinkMentaBiddingRequest.h"
#import <MentaMediationGlobal/MentaMediationGlobal-umbrella.h>

@interface AnyThinkMentaNativeAdapter ()

@property (nonatomic, strong) AnyThinkMentaNativeCustomEvent *customEvent;
@property (nonatomic, strong) MentaMediationNativeExpress *nativeExpressAd;
@property (nonatomic, strong) MentaMediationNativeSelfRender *nativeAd;

@end

@implementation AnyThinkMentaNativeAdapter

+ (Class)rendererClass {
    return [AnyThinkMentaNativeRender class];
}

- (instancetype)initWithNetworkCustomInfo:(NSDictionary*)serverInfo
                                localInfo:(NSDictionary*)localInfo {
    self = [super init];
    if (self != nil) {
        NSString *appIDKey = @"appid";
        if([serverInfo.allKeys containsObject:@"appId"]) {
            appIDKey = @"appId";
        }
        NSString *appID = serverInfo[appIDKey];
        NSString *appKey = serverInfo[@"appKey"];
        
        if (![[MentaAdSDK shared] isInitialized]) {
            [AnyThinkMentaNativeAdapter initMentaSDKWith:appID Key:appKey completion:nil];
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
    BOOL isExpress = [serverInfo[@"isExpressAd"] boolValue];
    NSString *bidId = serverInfo[kATAdapterCustomInfoBuyeruIdKey];
    
    __weak __typeof(self)weakSelf = self;
    void(^load)(void) = ^{
        __strong __typeof(weakSelf)strongSelf = weakSelf;
        dispatch_async(dispatch_get_main_queue(), ^{
            // C2S
            if (bidId) {
                AnyThinkMentaBiddingRequest *request = [[AnyThinkMentaBiddingManager sharedInstance] getRequestItemWithUnitID:slotID];
                if (request != nil && request.customObject) {
                    strongSelf.customEvent = (AnyThinkMentaNativeCustomEvent *)request.customEvent;
                    strongSelf.customEvent.requestCompletionBlock = completion;
                    if (isExpress) {
                        strongSelf.nativeExpressAd = (MentaMediationNativeExpress *)request.customObject;
                        [strongSelf.customEvent nativeExpressAdLoadedWith:strongSelf.nativeExpressAd nativeExpressAdView:request.nativeAds.firstObject];
                    } else {
                        // 自渲染
                        strongSelf.nativeAd = (MentaMediationNativeSelfRender *)request.customObject;
                        [strongSelf.customEvent nativeSelfRenderAdLoadedWith:strongSelf.nativeAd nativeSelfRenderAdModel:request.nativeAds.firstObject];
                    }
                    [[AnyThinkMentaBiddingManager sharedInstance] removeRequestItmeWithUnitID:slotID];
                    return;
                }
            } else {
                strongSelf.customEvent = [[AnyThinkMentaNativeCustomEvent alloc] initWithInfo:serverInfo localInfo:localInfo];
                strongSelf.customEvent.networkAdvertisingID = slotID;
                strongSelf.customEvent.requestCompletionBlock = completion;
                if (isExpress) {
                    CGSize adSize = CGSizeMake(CGRectGetWidth([UIScreen mainScreen].bounds) - 20.0, 300.0f);
                    if ([serverInfo[kATExtraInfoNativeAdSizeKey] respondsToSelector:@selector(CGSizeValue)]) {
                        adSize = [serverInfo[kATExtraInfoNativeAdSizeKey] CGSizeValue];
                    }

                    strongSelf.nativeExpressAd = [[MentaMediationNativeExpress alloc] initWithPlacementID:slotID];
                    strongSelf.nativeExpressAd.delegate = strongSelf.customEvent;
                    
                    [strongSelf.nativeExpressAd loadAd];
                } else {
                    // 自渲染
                    strongSelf.nativeAd = [[MentaMediationNativeSelfRender alloc] initWithPlacementID:slotID];
                    strongSelf.nativeAd.delegate = strongSelf.customEvent;
                    
                    [strongSelf.nativeAd loadAd];
                }
            }
        });
    };
    
    if ([[MentaAdSDK shared] isInitialized]) {
        load();
    } else {
        [AnyThinkMentaNativeAdapter initMentaSDKWith:appID Key:appKey completion:^{
            load();
        }];
    }
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
    BOOL isExpress = [info[@"isExpressAd"] boolValue];
    
    if ((!appID || !appKey || !slotID) && completion != nil) {
        NSError *err = [NSError errorWithDomain:@"com.menta.mediation.ios"
                                           code:1
                                       userInfo:@{NSLocalizedDescriptionKey:@"Bid request has failed", NSLocalizedFailureReasonErrorKey:@"Menta config is error"}];
        completion( nil, err);
        return;
    }
    
    [AnyThinkMentaNativeAdapter initMentaSDKWith:appID Key:appKey completion:^{
        AnyThinkMentaNativeCustomEvent *customEvent = [[AnyThinkMentaNativeCustomEvent alloc] initWithInfo:info localInfo:info];
        customEvent.isC2SBiding = YES;
        customEvent.networkAdvertisingID = slotID;
        
        AnyThinkMentaBiddingRequest *request = [[AnyThinkMentaBiddingRequest alloc] init];
        request.unitGroup = unitGroupModel;
        request.placementID = placementModel.placementID;
        request.customEvent = customEvent;
        request.bidCompletion = completion;
        request.unitID = slotID;
        request.extraInfo = info;
        request.adType = MentaAdFormatNative;
        
        if (isExpress) {
            CGSize adSize = CGSizeMake(CGRectGetWidth([UIScreen mainScreen].bounds) - 20.0, 300.0f);
            if ([info[kATExtraInfoNativeAdSizeKey] respondsToSelector:@selector(CGSizeValue)]) {
                adSize = [info[kATExtraInfoNativeAdSizeKey] CGSizeValue];
            }

            MentaMediationNativeExpress *nativeExpressAd = [[MentaMediationNativeExpress alloc] initWithPlacementID:slotID];
            nativeExpressAd.delegate = customEvent;
            
            request.customObject = nativeExpressAd;
            [nativeExpressAd loadAd];
        } else {
            // 自渲染
            MentaMediationNativeSelfRender *nativeAd = [[MentaMediationNativeSelfRender alloc] initWithPlacementID:slotID];
            nativeAd.delegate = customEvent;
            
            request.customObject = nativeAd;
            [nativeAd loadAd];
        }
        
        [[AnyThinkMentaBiddingManager sharedInstance] startWithRequestItem:request];
    }];
}

//// 返回广告位比价胜利时，第二的价格的回调，可在该回调中向三方平台返回竞胜价格  secondPrice：美元(USD)
+ (void) sendWinnerNotifyWithCustomObject:(id)customObject secondPrice:(NSString*)price userInfo:(NSDictionary<NSString *, NSString *> *)userInfo {
    NSLog(@"------> menta native ad win");
    if ([customObject isKindOfClass:MentaMediationNativeExpress.class]) {
        MentaMediationNativeExpress *nativeExpressAd = (MentaMediationNativeExpress *)customObject;
        [nativeExpressAd sendWinnerNotification];
    } else {
        MentaMediationNativeSelfRender *nativeAd = (MentaMediationNativeSelfRender *)customObject;
        [nativeAd sendWinnerNotification];
    }
}

//// 返回广告位比价输了的回调，可在该回调中向三方平台返回竞败价格 winPrice：美元(USD)
+ (void)sendLossNotifyWithCustomObject:(nonnull id)customObject lossType:(ATBiddingLossType)lossType winPrice:(nonnull NSString *)price userInfo:(NSDictionary *)userInfo {
    NSLog(@"------> menta native ad loss");
    if ([customObject isKindOfClass:MentaMediationNativeExpress.class]) {
        MentaMediationNativeExpress *nativeExpressAd = (MentaMediationNativeExpress *)customObject;
        double ecpm = price.doubleValue * 100;
        [nativeExpressAd sendLossNotificationWith:[NSString stringWithFormat:@"%f", ecpm]];
    } else {
        MentaMediationNativeSelfRender *nativeAd = (MentaMediationNativeSelfRender *)customObject;
        double ecpm = price.doubleValue * 100;
        [nativeAd sendLossNotificationWith:[NSString stringWithFormat:@"%f", ecpm]];
    }
}

#pragma mark - private method

+ (void)initMentaSDKWith:(NSString*)appID
                     Key:(NSString *)appKey
              completion:(void (^)(void))completion {
    NSLog(@"------> start init menta sdk");
    [[MentaAdSDK shared] setLogLevel:kMentaLogLevelDebug];
    [[MentaAdSDK shared] startWithAppID:appID
                                 appKey:appKey
                            finishBlock:^(BOOL success, NSError * _Nullable error) {
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
