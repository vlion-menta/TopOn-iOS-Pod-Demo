//
//  ATTMBiddingDelegate.m
//  HeadBiddingDemo
//
//  Created by lix on 2022/10/20.
//

#import "ATTMBiddingDelegate.h"
#import "ATTMBiddingManager.h"
#import "ATTMBiddingRequest.h"

@interface ATTMBiddingDelegate () 

@end

@implementation ATTMBiddingDelegate



- (void)bidResultCall:(NSString *)ecpm splashAd:(id)ad withError:(NSError *)error{
    ATTMBiddingRequest *request = [[ATTMBiddingManager sharedInstance] getRequestItemWithUnitID:self.unitID];
    if (request.bidCompletion) {
        if (error == nil) {
            ATBidInfo *bidInfo =  [ATBidInfo bidInfoC2SWithPlacementID:request.placementID
                                                       unitGroupUnitID:request.unitGroup.unitID
                                                    adapterClassString:request.unitGroup.adapterClassString
                                                                 price:ecpm
                                                          currencyType:ATBiddingCurrencyTypeCNY
                                                    expirationInterval:request.unitGroup.networkTimeout
                                                          customObject:ad];
            request.bidCompletion(bidInfo, nil);
        }else {
            request.bidCompletion(nil, error);
        }
    }
    [[ATTMBiddingManager sharedInstance] removeBiddingDelegateWithUnitID:self.unitID];
}







- (void)dealloc
{
    NSLog(@"ATTMBiddingDelegate 销毁");
}


@end
