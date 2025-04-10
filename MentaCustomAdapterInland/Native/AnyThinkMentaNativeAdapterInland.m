//
//  AnyThinkMentaNativeAdapter.m
//  AnyThinkMentaCustomAdapter
//
//  Created by jdy on 2024/4/12.
//

#import "AnyThinkMentaNativeAdapterInland.h"
#import "AnyThinkMentaNativeCustomEventInland.h"
#import "AnyThinkMentaNativeRenderInland.h"
#import "AnyThinkMentaBiddingManagerInland.h"
#import "AnyThinkMentaBiddingRequestInland.h"
#import <MentaUnifiedSDK/MentaUnifiedSDK-umbrella.h>

@interface AnyThinkMentaNativeAdapterInland ()

@property (nonatomic, strong) AnyThinkMentaNativeCustomEventInland *customEvent;
@property (nonatomic, strong) MentaUnifiedNativeExpressAd *nativeExpressAd;
@property (nonatomic, strong) MentaUnifiedNativeAd *nativeAd;

@end

@implementation AnyThinkMentaNativeAdapterInland

+ (Class)rendererClass {
    return [AnyThinkMentaNativeRenderInland class];
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
        
        if (![MUAPI isInitialized]) {
            [AnyThinkMentaNativeAdapterInland initMentaSDKWith:appID Key:appKey completion:nil];
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
                AnyThinkMentaBiddingRequestInland *request = [[AnyThinkMentaBiddingManagerInland sharedInstance] getRequestItemWithUnitID:slotID];
                if (request != nil && request.customObject) {
                    strongSelf.customEvent = (AnyThinkMentaNativeCustomEventInland *)request.customEvent;
                    strongSelf.customEvent.requestCompletionBlock = completion;
                    if (isExpress) {
                        strongSelf.nativeExpressAd = (MentaUnifiedNativeExpressAd *)request.customObject;
                        [strongSelf.customEvent nativeExpressAdLoadedWith:strongSelf.nativeExpressAd nativeExpressAdObj:request.nativeAds.firstObject];
                    } else {
                        // 自渲染
                        strongSelf.nativeAd = (MentaUnifiedNativeAd *)request.customObject;
                        [strongSelf.customEvent nativeAdLoadedWith:strongSelf.nativeAd nativeAdObj:request.nativeAds.firstObject];
                    }
                    [[AnyThinkMentaBiddingManagerInland sharedInstance] removeRequestItmeWithUnitID:slotID];
                    return;
                }
            } else {
                strongSelf.customEvent = [[AnyThinkMentaNativeCustomEventInland alloc] initWithInfo:serverInfo localInfo:localInfo];
                strongSelf.customEvent.networkAdvertisingID = slotID;
                strongSelf.customEvent.requestCompletionBlock = completion;
                if (isExpress) {
                    CGSize adSize = CGSizeMake(CGRectGetWidth([UIScreen mainScreen].bounds) - 20.0, 300.0f);
                    if ([serverInfo[kATExtraInfoNativeAdSizeKey] respondsToSelector:@selector(CGSizeValue)]) {
                        adSize = [serverInfo[kATExtraInfoNativeAdSizeKey] CGSizeValue];
                    }
                    MUNativeExpressConfig *config = [[MUNativeExpressConfig alloc] init];
                    config.adSize = adSize;
                    config.slotId = slotID;
                    config.materialFillMode = MentaNativeExpressAdMaterialFillMode_ScaleAspectFill;

                    strongSelf.nativeExpressAd = [[MentaUnifiedNativeExpressAd alloc] initWithConfig:config];
                    strongSelf.nativeExpressAd.delegate = strongSelf.customEvent;
                    
                    [strongSelf.nativeExpressAd loadAd];
                } else {
                    // 自渲染
                    MUNativeConfig *config = [[MUNativeConfig alloc] init];
                    config.slotId = slotID;
                    
                    strongSelf.nativeAd = [[MentaUnifiedNativeAd alloc] initWithConfig:config];
                    strongSelf.nativeAd.delegate = strongSelf.customEvent;
                    
                    [strongSelf.nativeAd loadAd];
                }
            }
        });
    };
    
    if ([MUAPI isInitialized]) {
        load();
    } else {
        [AnyThinkMentaNativeAdapterInland initMentaSDKWith:appID Key:appKey completion:^{
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
    MentaLog(@"------> menta start bidding");
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
    
    [AnyThinkMentaNativeAdapterInland initMentaSDKWith:appID Key:appKey completion:^{
        AnyThinkMentaNativeCustomEventInland *customEvent = [[AnyThinkMentaNativeCustomEventInland alloc] initWithInfo:info localInfo:info];
        customEvent.isC2SBiding = YES;
        customEvent.networkAdvertisingID = slotID;
        
        AnyThinkMentaBiddingRequestInland *request = [[AnyThinkMentaBiddingRequestInland alloc] init];
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
            MUNativeExpressConfig *config = [[MUNativeExpressConfig alloc] init];
            config.adSize = adSize;
            config.slotId = slotID;
            config.materialFillMode = MentaNativeExpressAdMaterialFillMode_ScaleAspectFill;

            MentaUnifiedNativeExpressAd *nativeExpressAd = [[MentaUnifiedNativeExpressAd alloc] initWithConfig:config];
            nativeExpressAd.delegate = customEvent;
            
            request.customObject = nativeExpressAd;
            [nativeExpressAd loadAd];
        } else {
            // 自渲染
            MUNativeConfig *config = [[MUNativeConfig alloc] init];
            config.slotId = slotID;
            
            MentaUnifiedNativeAd *nativeAd = [[MentaUnifiedNativeAd alloc] initWithConfig:config];
            nativeAd.delegate = customEvent;
            
            request.customObject = nativeAd;
            [nativeAd loadAd];
        }
        
        [[AnyThinkMentaBiddingManagerInland sharedInstance] startWithRequestItem:request];
    }];
}

//// 返回广告位比价胜利时，第二的价格的回调，可在该回调中向三方平台返回竞胜价格  secondPrice：美元(USD)
+ (void) sendWinnerNotifyWithCustomObject:(id)customObject secondPrice:(NSString*)price userInfo:(NSDictionary<NSString *, NSString *> *)userInfo {
    MentaLog(@"------> menta native ad win");
    if ([customObject isKindOfClass:MentaUnifiedNativeExpressAd.class]) {
        MentaUnifiedNativeExpressAd *ad = (MentaUnifiedNativeExpressAd *)customObject;
        [ad sendWinNotification];
    } else {
        MentaUnifiedNativeAd *nativeAd = (MentaUnifiedNativeAd *)customObject;
        [nativeAd sendWinNotification];
    }
}

//// 返回广告位比价输了的回调，可在该回调中向三方平台返回竞败价格 winPrice：美元(USD)
+ (void)sendLossNotifyWithCustomObject:(nonnull id)customObject lossType:(ATBiddingLossType)lossType winPrice:(nonnull NSString *)price userInfo:(NSDictionary *)userInfo {
    MentaLog(@"------> menta native ad loss");
    if ([customObject isKindOfClass:MentaUnifiedNativeExpressAd.class]) {
        MentaUnifiedNativeExpressAd *nativeExpressAd = (MentaUnifiedNativeExpressAd *)customObject;
        [nativeExpressAd sendLossNotificationWithInfo:@{MU_M_L_WIN_PRICE : @([price integerValue] * 100)}];
    } else {
        MentaUnifiedNativeAd *nativeAd = (MentaUnifiedNativeAd *)customObject;
        [nativeAd sendLossNotificationWithInfo:@{MU_M_L_WIN_PRICE : @([price integerValue] * 100)}];
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

- (void)dealloc
{
    MentaLog(@"------> %s", __FUNCTION__);
}

@end
