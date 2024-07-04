//
//  ATTMBiddingDelegate.h
//  HeadBiddingDemo
//
//  Created by lix on 2022/10/20.
//

#import <Foundation/Foundation.h>
#import <AnyThinkSplash/AnyThinkSplash.h>

NS_ASSUME_NONNULL_BEGIN

@interface ATTMBiddingDelegate : NSObject

@property (nonatomic,strong) NSString *biddingPrice;

/// 广告源ID
@property(nonatomic, strong)  NSString *unitID;



/// 竞价回调
/// - Parameters:
///   - ecpm: 价格 单位元
///   - ad: 广告ad对象
///   - error: 错误信息
- (void)bidResultCall:(NSString *)ecpm splashAd:(id)ad withError:(NSError *)error;


@end

NS_ASSUME_NONNULL_END
