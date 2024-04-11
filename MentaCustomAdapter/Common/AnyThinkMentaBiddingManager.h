//
//  AnyThinkMentaBiddingManager.h
//  AnyThinkMentaSplashAdapter
//
//  Created by jdy on 2024/4/11.
//

#import <Foundation/Foundation.h>
#import "AnyThinkMentaBiddingRequest.h"

NS_ASSUME_NONNULL_BEGIN

@interface AnyThinkMentaBiddingManager : NSObject

+ (instancetype)sharedInstance;

- (void)startWithRequestItem:(AnyThinkMentaBiddingRequest *)request;

- (AnyThinkMentaBiddingRequest *)getRequestItemWithUnitID:(NSString *)unitID;

- (void)removeRequestItmeWithUnitID:(NSString *)unitID;

- (void)removeBiddingDelegateWithUnitID:(NSString *)unitID;

@end

NS_ASSUME_NONNULL_END
