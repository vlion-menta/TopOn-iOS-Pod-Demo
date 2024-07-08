//
//  AnyThinkMentaBannerAdapter.m
//  AnyThinkMentaCustomAdapter
//
//  Created by jdy on 2024/4/15.
//

#import "AnyThinkMentaBannerAdapter.h"
#import "AnyThinkMentaBiddingManager.h"
#import "AnyThinkMentaBannerCustomEvent.h"
#import <MentaUnifiedSDK/MentaUnifiedSDK.h>

@interface AnyThinkMentaBannerAdapter ()

@property (nonatomic, strong) AnyThinkMentaBannerCustomEvent *customEvent;
@property (nonatomic, strong) MentaUnifiedBannerAd *bannerAd;

@end

@implementation AnyThinkMentaBannerAdapter

-(instancetype) initWithNetworkCustomInfo:(NSDictionary*)serverInfo localInfo:(NSDictionary*)localInfo {
    self = [super init];
    if (self != nil) {
        NSString *appIDKey = @"appid";
        if([serverInfo.allKeys containsObject:@"appId"]) {
            appIDKey = @"appId";
        }
        NSString *appID = serverInfo[appIDKey];
        NSString *appKey = serverInfo[@"appKey"];
        if (![MUAPI isInitialized]) {
            [AnyThinkMentaBannerAdapter initMentaSDKWith:appID Key:appKey completion:nil];
        }
    }
    return self;
}

-(void) loadADWithInfo:(NSDictionary*)serverInfo 
             localInfo:(NSDictionary*)localInfo
            completion:(void (^)(NSArray<NSDictionary *> *, NSError *))completion {
    
    NSString *appIDKey = @"appid";
    if([serverInfo.allKeys containsObject:@"appId"]) {
        appIDKey = @"appId";
    }
    NSString *appID = serverInfo[appIDKey];
    NSString *appKey = serverInfo[@"appKey"];
    NSString *slotID = serverInfo[@"slotID"];
    CGFloat width = [NSString stringWithFormat:@"%@", serverInfo[@"width"]].doubleValue;
    CGFloat height = [NSString stringWithFormat:@"%@", serverInfo[@"height"]].doubleValue;
    NSString *bidId = serverInfo[kATAdapterCustomInfoBuyeruIdKey];
    NSString *requestUUID = serverInfo[@"tracking_info_request_id"];
    
    __weak typeof(self) weakSelf = self;
    void(^load)(void) = ^{
        __strong __typeof(weakSelf)strongSelf = weakSelf;
        
        dispatch_async(dispatch_get_main_queue(), ^{
            AnyThinkMentaBiddingRequest *request = [[AnyThinkMentaBiddingManager sharedInstance] getRequestItemWithUnitID:requestUUID];
            NSLog(@"------> bidding load success %@ - customevent %@", requestUUID, request.customEvent);
            
            if (bidId && request != nil && request.customObject) {
                AnyThinkMentaBannerCustomEvent *customEvent = (AnyThinkMentaBannerCustomEvent *)request.customEvent;
                customEvent.requestCompletionBlock = completion;
                MentaUnifiedBannerAd *bannerAd = (MentaUnifiedBannerAd *)request.customObject;
                if ([bannerAd fetchBannerView]) {
                    [customEvent trackBannerAdLoaded:[bannerAd fetchBannerView] adExtra:nil];
                }
                return;
            }
            
            strongSelf.customEvent = [[AnyThinkMentaBannerCustomEvent alloc] initWithInfo:serverInfo localInfo:localInfo];
            strongSelf.customEvent.networkAdvertisingID = slotID;
            strongSelf.customEvent.requestCompletionBlock = completion;
            strongSelf.customEvent.UUID = requestUUID;
            
            MUBannerConfig *config = [[MUBannerConfig alloc] init];
            config.adSize = CGSizeMake(width, height); // adSize 设置多少 最后的banner显示区域就是多少 同时containerView的size 要与adsize保持一致
            config.slotId = slotID;// 图片

            strongSelf.bannerAd = [[MentaUnifiedBannerAd alloc] initWithConfig:config];
            strongSelf.bannerAd.delegate = strongSelf.customEvent;
            [strongSelf.bannerAd loadAd];
        });
    };
    
    if ([MUAPI isInitialized]) {
        load();
    } else {
        [AnyThinkMentaBannerAdapter initMentaSDKWith:appID Key:appKey completion:^{
            load();
        }];
    }
}

#pragma mark - AlexC2SBiddingRequestProtocol
+ (void)bidRequestWithPlacementModel:(nonnull ATPlacementModel *)placementModel 
                      unitGroupModel:(nonnull ATUnitGroupModel *)unitGroupModel
                                info:(nonnull NSDictionary *)info
                          completion:(nonnull void (^)(ATBidInfo * _Nonnull, NSError * _Nonnull))completion {
    
    NSString *appIDKey = @"appid";
    if([info.allKeys containsObject:@"appId"]) {
        appIDKey = @"appId";
    }
    NSString *appID = info[appIDKey];
    NSString *appKey = info[@"appKey"];
    NSString *slotID = info[@"slotID"];
    CGFloat width = [NSString stringWithFormat:@"%@", info[@"width"]].doubleValue;
    CGFloat height = [NSString stringWithFormat:@"%@", info[@"height"]].doubleValue;
    NSString *requestUUID = info[@"tracking_info_request_id"];
    
    [AnyThinkMentaBannerAdapter initMentaSDKWith:appID Key:appKey completion:^{
        AnyThinkMentaBannerCustomEvent *customEvent = [[AnyThinkMentaBannerCustomEvent alloc] initWithInfo:info localInfo:info];
        customEvent.isC2SBiding = YES;
        customEvent.networkAdvertisingID = slotID;
        customEvent.UUID = requestUUID;
        
        AnyThinkMentaBiddingRequest *request = [[AnyThinkMentaBiddingRequest alloc] init];
        request.unitGroup = unitGroupModel;
        request.placementID = placementModel.placementID;
        request.customEvent = customEvent;
        request.bidCompletion = completion;
        request.unitID = slotID;
        request.extraInfo = info;
        request.adType = MentaAdFormatBanner;
        request.UUID = requestUUID;
        
        MUBannerConfig *config = [[MUBannerConfig alloc] init];
        config.adSize = CGSizeMake(width, height); // adSize 设置多少 最后的banner显示区域就是多少 同时containerView的size 要与adsize保持一致
        config.slotId = slotID;// 图片

        MentaUnifiedBannerAd *bannerAd = [[MentaUnifiedBannerAd alloc] initWithConfig:config];
        bannerAd.delegate = customEvent;
        
        request.customObject = bannerAd;
        [[AnyThinkMentaBiddingManager sharedInstance] startWithRequestItem:request];;
        [bannerAd loadAd];
        NSLog(@"------> menta start bidding %@, customevent %@", requestUUID, customEvent);
    }];
}

//// 返回广告位比价胜利时，第二的价格的回调，可在该回调中向三方平台返回竞胜价格  secondPrice：美元(USD)
+ (void) sendWinnerNotifyWithCustomObject:(id)customObject secondPrice:(NSString*)price userInfo:(NSDictionary<NSString *, NSString *> *)userInfo {
    NSLog(@"------> menta banner ad win");
}

//// 返回广告位比价输了的回调，可在该回调中向三方平台返回竞败价格 winPrice：美元(USD)
+ (void)sendLossNotifyWithCustomObject:(nonnull id)customObject lossType:(ATBiddingLossType)lossType winPrice:(nonnull NSString *)price userInfo:(NSDictionary *)userInfo {
    NSLog(@"------> menta banner ad loss");
    if ([customObject isKindOfClass:MentaUnifiedBannerAd.class]) {
        MentaUnifiedBannerAd *ad = (MentaUnifiedBannerAd *)customObject;
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

- (void)dealloc
{
    NSLog(@"------> %s", __FUNCTION__);
}

@end
