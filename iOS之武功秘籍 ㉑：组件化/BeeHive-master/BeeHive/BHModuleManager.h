/**
 * Created by BeeHive.
 * Copyright (c) 2016, Alibaba, Inc. All rights reserved.
 *
 * This source code is licensed under the GNU GENERAL PUBLIC LICENSE.
 * For the full copyright and license information,please view the LICENSE file in the root directory of this source tree.
 */

#import <Foundation/Foundation.h>

typedef NS_ENUM(NSUInteger, BHModuleLevel)
{
    BHModuleBasic  = 0,
    BHModuleNormal = 1
};

typedef NS_ENUM(NSInteger, BHModuleEventType)
{
    //设置Module模块
    BHMSetupEvent = 0,
    //用于初始化Module模块，例如环境判断，根据不同环境进行不同初始化
    BHMInitEvent,
    //用于拆除Module模块
    BHMTearDownEvent,
    BHMSplashEvent,
    BHMQuickActionEvent,
    BHMWillResignActiveEvent,
    BHMDidEnterBackgroundEvent,
    BHMWillEnterForegroundEvent,
    BHMDidBecomeActiveEvent,
    BHMWillTerminateEvent,
    BHMUnmountEvent,
    BHMOpenURLEvent,
    BHMDidReceiveMemoryWarningEvent,
    BHMDidFailToRegisterForRemoteNotificationsEvent,
    BHMDidRegisterForRemoteNotificationsEvent,
    BHMDidReceiveRemoteNotificationEvent,
    BHMDidReceiveLocalNotificationEvent,
    BHMWillPresentNotificationEvent,
    BHMDidReceiveNotificationResponseEvent,
    BHMWillContinueUserActivityEvent,
    BHMContinueUserActivityEvent,
    BHMDidFailToContinueUserActivityEvent,
    BHMDidUpdateUserActivityEvent,
    BHMHandleWatchKitExtensionRequestEvent,
    BHMDidCustomEvent = 1000
    
};


@class BHModule;

@interface BHModuleManager : NSObject

+ (instancetype)sharedManager;

// If you do not comply with set Level protocol, the default Normal
- (void)registerDynamicModule:(Class)moduleClass;

- (void)registerDynamicModule:(Class)moduleClass
       shouldTriggerInitEvent:(BOOL)shouldTriggerInitEvent;

- (void)unRegisterDynamicModule:(Class)moduleClass;

- (void)loadLocalModules;

- (void)registedAllModules;

- (void)registerCustomEvent:(NSInteger)eventType
         withModuleInstance:(id)moduleInstance
             andSelectorStr:(NSString *)selectorStr;

- (void)triggerEvent:(NSInteger)eventType;

- (void)triggerEvent:(NSInteger)eventType
     withCustomParam:(NSDictionary *)customParam;



@end

