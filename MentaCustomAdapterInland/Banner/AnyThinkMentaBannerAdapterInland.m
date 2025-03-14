//
//  AnyThinkMentaBannerAdapter.m
//  AnyThinkMentaCustomAdapter
//
//  Created by jdy on 2024/4/15.
//

#import "AnyThinkMentaBannerAdapterInland.h"
#import "AnyThinkMentaBiddingManagerInland.h"
#import "AnyThinkMentaBannerCustomEventInland.h"
#import <MentaUnifiedSDK/MentaUnifiedSDK-umbrella.h>

@interface AnyThinkMentaBannerAdapterInland ()

@property (nonatomic, strong) AnyThinkMentaBannerCustomEventInland *customEvent;
@property (nonatomic, strong) MentaUnifiedBannerAd *bannerAd;

@end

@implementation AnyThinkMentaBannerAdapterInland

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
            [AnyThinkMentaBannerAdapterInland initMentaSDKWith:appID Key:appKey completion:nil];
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
    
    CGFloat width = 320;
    CGFloat height = 50;
    id size = localInfo[kATAdLoadingExtraBannerAdSizeKey];
    if (size && [size isKindOfClass:NSValue.class]) {
        CGSize bannerSize = [(NSValue *)size CGSizeValue];
        width = bannerSize.width;
        height = bannerSize.height;
    }
    
    NSString *bidId = serverInfo[kATAdapterCustomInfoBuyeruIdKey];
    NSString *requestUUID = serverInfo[@"tracking_info_request_id"];
    
    __weak typeof(self) weakSelf = self;
    void(^load)(void) = ^{
        __strong __typeof(weakSelf)strongSelf = weakSelf;
        
        dispatch_async(dispatch_get_main_queue(), ^{
            AnyThinkMentaBiddingRequestInland *request = [[AnyThinkMentaBiddingManagerInland sharedInstance] getRequestItemWithUnitID:requestUUID];
            
            if (bidId && request != nil && request.customObject) {
                MentaLog(@"------> bidding load success %@ - customevent %@", requestUUID, request.customEvent);
                AnyThinkMentaBannerCustomEventInland *customEvent = (AnyThinkMentaBannerCustomEventInland *)request.customEvent;
                customEvent.requestCompletionBlock = completion;
                MentaUnifiedBannerAd *bannerAd = (MentaUnifiedBannerAd *)request.customObject;
                if ([bannerAd fetchBannerView]) {
                    [customEvent trackBannerAdLoaded:bannerAd adExtra:nil];
                }
                return;
            }
            
            strongSelf.customEvent = [[AnyThinkMentaBannerCustomEventInland alloc] initWithInfo:serverInfo localInfo:localInfo];
            strongSelf.customEvent.networkAdvertisingID = slotID;
            strongSelf.customEvent.requestCompletionBlock = completion;
            strongSelf.customEvent.UUID = requestUUID;
            
            MUBannerConfig *config = [[MUBannerConfig alloc] init];
            config.adSize = CGSizeMake(width, height); // adSize 设置多少 最后的banner显示区域就是多少 同时containerView的size 要与adsize保持一致
            config.slotId = slotID;

            strongSelf.bannerAd = [[MentaUnifiedBannerAd alloc] initWithConfig:config];
            strongSelf.bannerAd.delegate = strongSelf.customEvent;
            [strongSelf.bannerAd loadAd];
        });
    };
    
    if ([MUAPI isInitialized]) {
        load();
    } else {
        [AnyThinkMentaBannerAdapterInland initMentaSDKWith:appID Key:appKey completion:^{
            load();
        }];
    }
}

+(void)showBanner:(ATBanner*)banner inView:(UIView*)view presentingViewController:(UIViewController*)viewController {
    MentaLog(@"------> show banner view");
    MentaUnifiedBannerAd *bannerAd = (MentaUnifiedBannerAd *)banner.bannerView;
    [bannerAd showInContainer:view];
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
    
    CGFloat width = 320;
    CGFloat height = 50;
    id size = info[kATAdLoadingExtraBannerAdSizeKey];
    if (size && [size isKindOfClass:NSValue.class]) {
        CGSize bannerSize = [(NSValue *)size CGSizeValue];
        width = bannerSize.width;
        height = bannerSize.height;
    }
    
    NSString *requestUUID = info[@"tracking_info_request_id"];
    
    [AnyThinkMentaBannerAdapterInland initMentaSDKWith:appID Key:appKey completion:^{
        AnyThinkMentaBannerCustomEventInland *customEvent = [[AnyThinkMentaBannerCustomEventInland alloc] initWithInfo:info localInfo:info];
        customEvent.isC2SBiding = YES;
        customEvent.networkAdvertisingID = slotID;
        customEvent.UUID = requestUUID;
        
        AnyThinkMentaBiddingRequestInland *request = [[AnyThinkMentaBiddingRequestInland alloc] init];
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
        config.slotId = slotID;

        MentaUnifiedBannerAd *bannerAd = [[MentaUnifiedBannerAd alloc] initWithConfig:config];
        bannerAd.delegate = customEvent;
        
        request.customObject = bannerAd;
        [[AnyThinkMentaBiddingManagerInland sharedInstance] startWithRequestItem:request];;
        [bannerAd loadAd];
        MentaLog(@"------> menta start bidding %@, customevent %@", requestUUID, customEvent);
    }];
}

//// 返回广告位比价胜利时，第二的价格的回调，可在该回调中向三方平台返回竞胜价格  secondPrice：美元(USD)
+ (void) sendWinnerNotifyWithCustomObject:(id)customObject secondPrice:(NSString*)price userInfo:(NSDictionary<NSString *, NSString *> *)userInfo {
    MentaLog(@"------> menta banner ad win");
    if ([customObject isKindOfClass:MentaUnifiedBannerAd.class]) {
        MentaUnifiedBannerAd *ad = (MentaUnifiedBannerAd *)customObject;
        [ad sendWinNotification];
    }
}

//// 返回广告位比价输了的回调，可在该回调中向三方平台返回竞败价格 winPrice：美元(USD)
+ (void)sendLossNotifyWithCustomObject:(nonnull id)customObject lossType:(ATBiddingLossType)lossType winPrice:(nonnull NSString *)price userInfo:(NSDictionary *)userInfo {
    MentaLog(@"------> menta banner ad loss");
    if ([customObject isKindOfClass:MentaUnifiedBannerAd.class]) {
        MentaUnifiedBannerAd *ad = (MentaUnifiedBannerAd *)customObject;
        [ad sendLossNotificationWithInfo:@{MU_M_L_WIN_PRICE : @([price integerValue] * 100)}];
    }
}

#pragma mark - private method

+ (void)initMentaSDKWith:(NSString*)appID
                     Key:(NSString *)appKey
              completion:(void (^)(void))completion {
    MentaLog(@"------> start init menta sdk");
    [MUAPI enableLog:YES];
    [MUAPI enableDoubleKs:YES];
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
