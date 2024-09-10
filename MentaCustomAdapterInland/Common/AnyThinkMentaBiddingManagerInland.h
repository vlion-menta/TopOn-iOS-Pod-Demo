//
//  AnyThinkMentaBiddingManager.h
//  AnyThinkMentaSplashAdapter
//
//  Created by jdy on 2024/4/11.
//

#import <Foundation/Foundation.h>
#import "AnyThinkMentaBiddingRequestInland.h"

NS_ASSUME_NONNULL_BEGIN

@interface AnyThinkMentaBiddingManagerInland : NSObject

+ (instancetype)sharedInstance;

- (void)startWithRequestItem:(AnyThinkMentaBiddingRequestInland *)request;

- (AnyThinkMentaBiddingRequestInland *)getRequestItemWithUnitID:(NSString *)unitID;

- (void)removeRequestItmeWithUnitID:(NSString *)unitID;

- (void)removeBiddingDelegateWithUnitID:(NSString *)unitID;

@end

NS_ASSUME_NONNULL_END
