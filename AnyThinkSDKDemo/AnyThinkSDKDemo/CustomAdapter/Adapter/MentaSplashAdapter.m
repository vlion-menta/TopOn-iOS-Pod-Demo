//
//  MentaSplashAdapter.m
//  yxy_app
//
//  Created by 云马Mac on 2024/2/2.
//  Copyright © 2024 王云祥. All rights reserved.
//

#import "MentaSplashAdapter.h"
#import "ATTMBiddingManager.h"
//#import "AdvSdkManager.h"

@implementation MentaSplashAdapter

-(instancetype) initWithNetworkCustomInfo:(NSDictionary*)serverInfo localInfo:(NSDictionary*)localInfo {
    self = [super init];
    if (self != nil) {
        
        NSString *appidKey = @"appid";
        if([serverInfo.allKeys containsObject:@"appId"]) {
            appidKey = @"appId";
        }
        NSString *appId = serverInfo[appidKey];
        NSString *appKey = serverInfo[@"appKey"];
//        if ([AdvSdkManager canInitSdk:@"menta" currentVersion:[MUAPI sdkVersion]]) {
            [MentaSplashAdapter initMSSDK:appId withKey:appKey completion:nil];
//        }
    }
    return self;
}

+ (void)initMSSDK:(NSString*)appid withKey:(NSString *)key completion:(void (^)(void))completion {

    [MUAPI enableLog:NO];
    NSLog(@"Menta当前版本:%@",[MUAPI sdkVersion]);
    [MUAPI startWithAppID:appid appKey:key finishBlock:^(BOOL success, NSError * _Nullable error) {
        if (success && completion != nil) {
            completion();
        }
    }];
}

+ (MentaUnifiedSplashAd *)initSplashAdvWithSlotId:(NSString *)slotId {
    MUSplashConfig *config = [MUSplashConfig new];
    config.slotId = slotId;
    config.adSize = [UIScreen mainScreen].bounds.size;
    config.tolerateTime = 5;
    config.materialFillMode = MentaSplashAdMaterialFillMode_ScaleAspectFill;
    return  [[MentaUnifiedSplashAd alloc] initWithConfig:config];
    
    
}


-(void)loadADWithInfo:(NSDictionary*)serverInfo localInfo:(NSDictionary*)localInfo completion:(void (^)(NSArray<NSDictionary *> *, NSError *))completion {
    NSTimeInterval tolerateTimeout = localInfo[kATSplashExtraTolerateTimeoutKey] ? [localInfo[kATSplashExtraTolerateTimeoutKey] doubleValue] : 5.0;
    
//    if (![AdvSdkManager canInitSdk:@"menta" currentVersion:[MUAPI sdkVersion]]) {
//        completion(nil, [NSError errorWithDomain:@"sdk版本过低,禁止初始化" code:-222222 userInfo:@{NSLocalizedDescriptionKey:@"sdk版本过低,禁止初始化", NSLocalizedFailureReasonErrorKey:@"sdk版本过低,禁止初始化"}]);
//        return;
//    }
    
    if (tolerateTimeout > 0) {
        NSString *bidId = serverInfo[kATAdapterCustomInfoBuyeruIdKey];
    
        if (bidId.length) {
            
            ATTMBiddingRequest *request = [[ATTMBiddingManager sharedInstance] getRequestItemWithUnitID:serverInfo[@"unitid"]];
          
            if (request.customObject != nil) { // load secced
                
                self.splash = request.customObject;
                _customEvent = self.splash.delegate;
                _customEvent.localInfo = localInfo;
                _customEvent.serverInfo = serverInfo;
                _customEvent.requestCompletionBlock = completion;
                _customEvent.delegate = self.delegateToBePassed;
                _customEvent.isReady = true;
                [_customEvent trackSplashAdLoaded:self.splash];
            } else { // fail
                
                NSError *error = [NSError errorWithDomain:ATADLoadingErrorDomain code:ATADLoadingErrorCodeThirdPartySDKNotImportedProperly userInfo:@{NSLocalizedDescriptionKey:@"AT has failed to load splash.", NSLocalizedFailureReasonErrorKey:@"It took too long to load placement stragety."}];
                _customEvent = [[MentaATSplashCustomEvent alloc] initWithInfo:serverInfo localInfo:localInfo];
                _customEvent.requestCompletionBlock = completion;
                _customEvent.delegate = self.delegateToBePassed;
                
                [_customEvent trackSplashAdLoadFailed:error];
            }
            [[ATTMBiddingManager sharedInstance] removeRequestItmeWithUnitID:serverInfo[@"unitid"]];
        }else {
            _customEvent = [[MentaATSplashCustomEvent alloc] initWithInfo:serverInfo localInfo:localInfo];
            _customEvent.requestCompletionBlock = completion;
            _customEvent.delegate = self.delegateToBePassed;
            dispatch_async(dispatch_get_main_queue(), ^{
            
                NSString *unitId = @"unitid";
                if ([serverInfo.allKeys containsObject:@"unitid"]) {
                    unitId = @"unitid";
                }else if  ([serverInfo.allKeys containsObject:@"unitId"]) {
                    unitId = @"unitId";
                }
                NSString *soltId = serverInfo[unitId];
                
                self->_splash = [MentaSplashAdapter initSplashAdvWithSlotId:soltId];
                self->_splash.delegate = self.customEvent;
                [self->_splash loadAd];
            });
        }
        
    } else {
        completion(nil, [NSError errorWithDomain:ATADLoadingErrorDomain code:ATADLoadingErrorCodeThirdPartySDKNotImportedProperly userInfo:@{NSLocalizedDescriptionKey:@"AT has failed to load splash.", NSLocalizedFailureReasonErrorKey:@"It took too long to load placement stragety."}]);
    }
}


/// 实现检查自定义广告平台的开屏广告是否已经是准备完成的方法
+(BOOL) adReadyWithCustomObject:(id)customObject info:(NSDictionary*)info {
    MentaUnifiedSplashAd *splashAd = (MentaUnifiedSplashAd *)customObject;
    MentaATSplashCustomEvent *event = (MentaATSplashCustomEvent *)splashAd.delegate;
    return event.isReady;
}

/// 展示 Splas
+ (void)showSplash:(ATSplash *)splash localInfo:(NSDictionary *)localInfo delegate:(id<ATSplashDelegate>)delegate {
    MentaUnifiedSplashAd *splashAd = splash.customObject;
    MentaATSplashCustomEvent *event = (MentaATSplashCustomEvent *)splash.customEvent;
    if (event.isReady) {
        [splashAd showInWindow:UIApplication.sharedApplication.keyWindow];
    }else {
        NSLog(@"没有准备好");
    }
}



+ (void)bidRequestWithPlacementModel:(ATPlacementModel *)placementModel unitGroupModel:(ATUnitGroupModel *)unitGroupModel info:(NSDictionary *)info completion:(void(^)(ATBidInfo *bidInfo, NSError *error))completion {
    
//    if (![AdvSdkManager canInitSdk:@"menta" currentVersion:[MUAPI sdkVersion]]) {
//        NSError *error = [NSError errorWithDomain:@"sdk版本过低,禁止初始化" code:-222222 userInfo:@{NSLocalizedDescriptionKey:@"sdk版本过低,禁止初始化", NSLocalizedFailureReasonErrorKey:@"sdk版本过低,禁止初始化"}];
//        completion(nil,error);
//        return;
//    }
    
    NSString *appidKey = @"appid";
    if([ unitGroupModel.content.allKeys containsObject:@"appId"]) {
        appidKey = @"appId";
    }
    NSString *appId = unitGroupModel.content[appidKey];
    
    NSString *unitIdKey = @"unitid";
    if  ([unitGroupModel.content.allKeys containsObject:@"unitId"]) {
        unitIdKey = @"unitId";
    }
    NSString *unitId = unitGroupModel.content[unitIdKey];
    NSString *appKey = unitGroupModel.content[@"appKey"];
    
    NSLog(@"竞价前：appKey:%@ unitId:%@",appKey,unitId);
    dispatch_async(dispatch_get_main_queue(), ^{
        [MentaSplashAdapter initMSSDK:appId withKey:appKey completion:^{
            ATTMBiddingManager *biddingManage = [ATTMBiddingManager sharedInstance];
            ATTMBiddingRequest *request = [ATTMBiddingRequest new];
            request.unitGroup = unitGroupModel;
            request.placementID = placementModel.placementID;
            request.bidCompletion = completion;
            request.unitID = unitId;
            request.extraInfo = info;
            request.adType = MentaAdFormatSplash;
            
            MentaUnifiedSplashAd *splash = [MentaSplashAdapter initSplashAdvWithSlotId:unitId];
            request.customObject = splash;
            
            MentaATSplashCustomEvent * mentaCustomEvent = [[MentaATSplashCustomEvent alloc] initWithInfo:unitGroupModel.content localInfo:info];
            mentaCustomEvent.soltID = unitId;
            request.mentaCustomEvent = mentaCustomEvent;
       
            splash.delegate = mentaCustomEvent;
            [biddingManage startWithRequestItem:request ];
            [splash loadAd];
        }];
        
    });
    
    
}

+ (void) sendWinnerNotifyWithCustomObject:(id)customObject secondPrice:(NSString*)price userInfo:(NSDictionary<NSString *, NSString *> *)userInfo {
    
}

+ (void)sendLossNotifyWithCustomObject:(nonnull id)customObject lossType:(ATBiddingLossType)lossType winPrice:(nonnull NSString *)price userInfo:(NSDictionary *)userInfo {
    NSLog(@"------> menta splash ad loss");
    if ([customObject isKindOfClass:MentaUnifiedSplashAd.class]) {
        MentaUnifiedSplashAd *splashAd = (MentaUnifiedSplashAd *)customObject;
        [splashAd sendLossNotificationWithInfo:@{MU_M_L_WIN_PRICE : @([price integerValue] * 100)}];
    }
}





- (void)dealloc {
    NSLog(@" MentaUnifiedSplashAdapter dealloc");
}




@end
