//
//  MentaATSplashCustomEvent.h
//  yxy_app
//
//  Created by 云马Mac on 2024/2/2.
//  Copyright © 2024 王云祥. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AnyThinkSplash/AnyThinkSplash.h>
#import <MentaUnifiedSDK/MentaUnifiedSDK.h>
NS_ASSUME_NONNULL_BEGIN

typedef void(^BidCompletionBlock)(ATBidInfo *bidInfo, NSError *error);

@interface MentaATSplashCustomEvent : ATSplashCustomEvent<MentaUnifiedSplashAdDelegate>

@property (nonatomic,assign) BOOL isReady;
/// 广告源ID
@property(nonatomic, strong)  NSString *soltID;

@property(nonatomic, copy) NSString *price;
@property(nonatomic, copy) NSString *bidID;
@property(nonatomic, weak) ATPlacementModel *placementModel;
@property(nonatomic, weak) ATUnitGroupModel *unitGroupModel;
@property(nonatomic, copy) void(^BidCompletionBlock)(ATBidInfo *bidInfo, NSError *error);

/// 竞价价格 临时缓存使用
@property (nonatomic,copy) NSString *biddingPrice;

@end

NS_ASSUME_NONNULL_END
