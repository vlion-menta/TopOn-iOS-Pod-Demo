//
//  ATTMBiddingManager.h
//  HeadBiddingDemo
//
//  Created by lix on 2022/10/20.
//

#import <Foundation/Foundation.h>
#import "ATTMBiddingDelegate.h"
#import "ATTMBiddingRequest.h"
#import "MentaATSplashCustomEvent.h"

NS_ASSUME_NONNULL_BEGIN

@interface ATTMBiddingManager : NSObject

@property (nonatomic, strong) NSMutableDictionary *bidingAdStorageAccessor;
@property (nonatomic, strong) NSMutableDictionary *bidingAdDelegate;

+ (instancetype)sharedInstance;

- (void)startWithRequestItem:(ATTMBiddingRequest *)request;

- (ATTMBiddingRequest *)getRequestItemWithUnitID:(NSString *)unitID;

- (ATTMBiddingDelegate *)getDelegateItemWithUnitID:(NSString *)unitID;

- (void)removeRequestItmeWithUnitID:(NSString *)unitID;

- (void)removeBiddingDelegateWithUnitID:(NSString *)unitID;

@end

NS_ASSUME_NONNULL_END
