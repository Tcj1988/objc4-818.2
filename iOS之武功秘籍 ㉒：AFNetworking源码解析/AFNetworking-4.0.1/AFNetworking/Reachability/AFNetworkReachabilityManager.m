// AFNetworkReachabilityManager.m
// Copyright (c) 2011–2016 Alamofire Software Foundation ( http://alamofire.org/ )
//
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in
// all copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
// THE SOFTWARE.

#import "AFNetworkReachabilityManager.h"
#if !TARGET_OS_WATCH

#import <netinet/in.h>
#import <netinet6/in6.h>
#import <arpa/inet.h>
#import <ifaddrs.h>
#import <netdb.h>

NSString * const AFNetworkingReachabilityDidChangeNotification = @"com.alamofire.networking.reachability.change";
NSString * const AFNetworkingReachabilityNotificationStatusItem = @"AFNetworkingReachabilityNotificationStatusItem";

typedef void (^AFNetworkReachabilityStatusBlock)(AFNetworkReachabilityStatus status);
typedef AFNetworkReachabilityManager * (^AFNetworkReachabilityStatusCallback)(AFNetworkReachabilityStatus status);

//把网络状态根据本地话语言转换为对应的字符串
NSString * AFStringFromNetworkReachabilityStatus(AFNetworkReachabilityStatus status) {
    switch (status) {
        case AFNetworkReachabilityStatusNotReachable:
            return NSLocalizedStringFromTable(@"Not Reachable", @"AFNetworking", nil);
        case AFNetworkReachabilityStatusReachableViaWWAN:
            return NSLocalizedStringFromTable(@"Reachable via WWAN", @"AFNetworking", nil);
        case AFNetworkReachabilityStatusReachableViaWiFi:
            return NSLocalizedStringFromTable(@"Reachable via WiFi", @"AFNetworking", nil);
        case AFNetworkReachabilityStatusUnknown:
        default:
            return NSLocalizedStringFromTable(@"Unknown", @"AFNetworking", nil);
    }
}
//根据网络flag转成我们开发中常用的网络状态
static AFNetworkReachabilityStatus AFNetworkReachabilityStatusForFlags(SCNetworkReachabilityFlags flags) {
    // 该网络地址可达
    BOOL isReachable = ((flags & kSCNetworkReachabilityFlagsReachable) != 0);
    // 该网络地址虽然可达，但是需要先建立一个connection
    BOOL needsConnection = ((flags & kSCNetworkReachabilityFlagsConnectionRequired) != 0);
    // 该网络虽然也需要先建立一个connection，但是它是可以自动去connect的
    BOOL canConnectionAutomatically = (((flags & kSCNetworkReachabilityFlagsConnectionOnDemand ) != 0) || ((flags & kSCNetworkReachabilityFlagsConnectionOnTraffic) != 0));
    // 不需要用户交互，就可以connect上（用户交互一般指的是提供网络的账户和密码）
    BOOL canConnectWithoutUserInteraction = (canConnectionAutomatically && (flags & kSCNetworkReachabilityFlagsInterventionRequired) == 0);
    // 如果isReachable==YES，那么就需要判断是不是得先建立一个connection，如果需要，那就认为不可达，或者虽然需要先建立一个connection，但是不需要用户交互，那么认为也是可达的
    BOOL isNetworkReachable = (isReachable && (!needsConnection || canConnectWithoutUserInteraction));
    //  AFNetworkReachabilityStatus就四种状态Unknown、NotReachable、ReachableViaWWAN、ReachableViaWiFi，这四种状态字面意思很好理解，这里就不赘述了
    AFNetworkReachabilityStatus status = AFNetworkReachabilityStatusUnknown;
    if (isNetworkReachable == NO) {
        status = AFNetworkReachabilityStatusNotReachable;
    }
#if	TARGET_OS_IPHONE
    else if ((flags & kSCNetworkReachabilityFlagsIsWWAN) != 0) {
        status = AFNetworkReachabilityStatusReachableViaWWAN;
    }
#endif
    else {
        status = AFNetworkReachabilityStatusReachableViaWiFi;
    }

    return status;
}

/**
 * Queue a status change notification for the main thread.
 *
 * This is done to ensure that the notifications are received in the same order
 * as they are sent. If notifications are sent directly, it is possible that
 * a queued notification (for an earlier status condition) is processed after
 * the later update, resulting in the listener being left in the wrong state.
 */
//在主线程中进行网络状态的变化通知和block调用
static void AFPostReachabilityStatusChange(SCNetworkReachabilityFlags flags, AFNetworkReachabilityStatusCallback block) {
    //将flags转化为status
    AFNetworkReachabilityStatus status = AFNetworkReachabilityStatusForFlags(flags);
    dispatch_async(dispatch_get_main_queue(), ^{
        AFNetworkReachabilityManager *manager = nil;
        if (block) {
            manager = block(status);
        }
        
        // 这个通知是给谁用的,---UI
        NSNotificationCenter *notificationCenter = [NSNotificationCenter defaultCenter];
        NSDictionary *userInfo = @{ AFNetworkingReachabilityNotificationStatusItem: @(status) };
        [notificationCenter postNotificationName:AFNetworkingReachabilityDidChangeNotification object:manager userInfo:userInfo];
    });
}
//状态变化的回调函数，最终调用到上方的函数
static void AFNetworkReachabilityCallback(SCNetworkReachabilityRef __unused target, SCNetworkReachabilityFlags flags, void *info) {
    AFPostReachabilityStatusChange(flags, (__bridge AFNetworkReachabilityStatusCallback)info);
}


static const void * AFNetworkReachabilityRetainCallback(const void *info) {
    return Block_copy(info);
}

static void AFNetworkReachabilityReleaseCallback(const void *info) {
    if (info) {
        Block_release(info);
    }
}

@interface AFNetworkReachabilityManager ()
@property (readonly, nonatomic, assign) SCNetworkReachabilityRef networkReachability;
@property (readwrite, nonatomic, assign) AFNetworkReachabilityStatus networkReachabilityStatus;
@property (readwrite, nonatomic, copy) AFNetworkReachabilityStatusBlock networkReachabilityStatusBlock;
@end

@implementation AFNetworkReachabilityManager

+ (instancetype)sharedManager {
    static AFNetworkReachabilityManager *_sharedManager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _sharedManager = [self manager];
    });

    return _sharedManager;
}
//根据域名来获取一个manager的实例
+ (instancetype)managerForDomain:(NSString *)domain {
    SCNetworkReachabilityRef reachability = SCNetworkReachabilityCreateWithName(kCFAllocatorDefault, [domain UTF8String]);

    AFNetworkReachabilityManager *manager = [[self alloc] initWithReachability:reachability];
    
    CFRelease(reachability);

    return manager;
}
//根据 socket 地址（sockaddr_in6，ipv6） 来获取一个 ReachabilityManager 的实例
+ (instancetype)managerForAddress:(const void *)address {
    SCNetworkReachabilityRef reachability = SCNetworkReachabilityCreateWithAddress(kCFAllocatorDefault, (const struct sockaddr *)address);
    AFNetworkReachabilityManager *manager = [[self alloc] initWithReachability:reachability];

    CFRelease(reachability);
    
    return manager;
}
/*
 当前app支持的最低版本，如果是7.1版本，那么对应的宏常量就是70100
 bzero会将内存的前多少个字节清零，意思就是给address分配内存
 address是结构体（包括大小，协议族，ip，端口等信息）
 为什么要传，因为
 
 */
+ (instancetype)manager
{
#if (defined(__IPHONE_OS_VERSION_MIN_REQUIRED) && __IPHONE_OS_VERSION_MIN_REQUIRED >= 90000) || (defined(__MAC_OS_X_VERSION_MIN_REQUIRED) && __MAC_OS_X_VERSION_MIN_REQUIRED >= 101100)
    //基于ipv6
    struct sockaddr_in6 address;
    bzero(&address, sizeof(address));
    address.sin6_len = sizeof(address);
    address.sin6_family = AF_INET6;
#else
    //基于ipv4
    struct sockaddr_in address;
    bzero(&address, sizeof(address));
    address.sin_len = sizeof(address);
    address.sin_family = AF_INET;
#endif
    return [self managerForAddress:&address];
}

- (instancetype)initWithReachability:(SCNetworkReachabilityRef)reachability {
    self = [super init];
    if (!self) {
        return nil;
    }
    //去引用这个对象，不会有所有权，如果为了避免这个对象被释放，可以通过（CFRetain）去添加引用计数
    _networkReachability = CFRetain(reachability);
    //设置默认状态
    self.networkReachabilityStatus = AFNetworkReachabilityStatusUnknown;

    return self;
}

- (instancetype)init
{
    @throw [NSException exceptionWithName:NSGenericException
                                   reason:@"`-init` unavailable. Use `-initWithReachability:` instead"
                                 userInfo:nil];
    return nil;
}

- (void)dealloc {
    [self stopMonitoring];
    
    if (_networkReachability != NULL) {
        CFRelease(_networkReachability);
    }
}

#pragma mark -

- (BOOL)isReachable {
    return [self isReachableViaWWAN] || [self isReachableViaWiFi];
}

- (BOOL)isReachableViaWWAN {
    return self.networkReachabilityStatus == AFNetworkReachabilityStatusReachableViaWWAN;
}

- (BOOL)isReachableViaWiFi {
    return self.networkReachabilityStatus == AFNetworkReachabilityStatusReachableViaWiFi;
}

#pragma mark -

- (void)startMonitoring {
    // 如果之前设置过对网络状态的监听，使用 SCNetworkReachabilityUnscheduleFromRunLoop 方法取消之前在 Main Runloop 中的监听
    [self stopMonitoring];

    if (!self.networkReachability) {
        return;
    }
    //为防止callback内部对self强引用，weak一下
    __weak __typeof(self)weakSelf = self;
    // 创建一个在每次网络状态改变时的回调
    AFNetworkReachabilityStatusCallback callback = ^(AFNetworkReachabilityStatus status) {
        //__strong什么鬼？self转回strong了，这里__typeof()里面写的是weakSelf，里面写self也没有问题，因为typeof是编译时确定变量类型，所以这里写self 不会被循环引用.第四、五、六行，如果不转成strongSelf而使用weakSelf，后面几句话中，有可能在第四句执行之后self的对象可能被析构掉，然后后面的StausBlock没有执行，导致逻辑错误
        __strong __typeof(weakSelf)strongSelf = weakSelf;
        /*
         每次回调被调用时
         重新设置 networkReachabilityStatus 属性
         调用 networkReachabilityStatusBlock
         */
        strongSelf.networkReachabilityStatus = status;
        if (strongSelf.networkReachabilityStatusBlock) {
            strongSelf.networkReachabilityStatusBlock(status);
        }
        
        return strongSelf;
    };
    /*
     保存的是回调函数以及相关的一些数据操作
     1. 第一个参数 版本号，是传递给 SCDynamicStore （系统配置动态存储库）来创建函数用的。这个结构体的版本号是 0
     2. 第二个参数  info 一个 C 指针，指向一个用户指定的数据块。（也就是前一步中创建的那个block）
     3. 第三个参数 是一个函数 目的是对info做retain操作，
     4. 第四个参数 是一个函数，目的是对info做release操作
     5. 第五个参数是 一个函数，根据info获取Description字符串
     */
    // 上下文写法
    SCNetworkReachabilityContext context = {0, (__bridge void *)callback, AFNetworkReachabilityRetainCallback, AFNetworkReachabilityReleaseCallback, NULL};
    
    // 为 SCNetworkReachability添加回调函数 在状态变化的时候会调用这个回调
    // 这个方法中还要一个回调函数，和一个 SCNetworkReachabilityContext 。回调函数用来当网络状态发生变化时，让系统进行回调。最后一个 context 是和 回调函数相关联的 SCNetworkReachabilityContext （网络可连接上下文）
    // networkReachability --> context ---> callback
    // 状态 : 全局的一直持有 不会释放销毁 : RunLoop
    // 整个进程: apple 网络状态一直持有
    SCNetworkReachabilitySetCallback(self.networkReachability, AFNetworkReachabilityCallback, &context);
    
    // 在设置完了回调函数后，将 networkReachability 加入到 runloop中，达到实时监听的目的
    // SCNetworkReachabilityScheduleWithRunLoop(self.networkReachability, CFRunLoopGetMain(), kCFRunLoopCommonModes);
    // 将 networkReachability 添加到 某个运行循环上（这里是主循环），然后设定一个模式，在这个模式下都会触发监听。
    // 这里选的是 kCFRunLoopCommonModes 这样当用户操作UI的时候，也会继续监听。这个和NSTimer的使用类似，将定时器添加到这个模式的runloop中时 一些滑动事件就不会中断定时器的计时。
    SCNetworkReachabilityScheduleWithRunLoop(self.networkReachability, CFRunLoopGetMain(), kCFRunLoopCommonModes);
    
    // 在异步线程 发送一次当前的网络状态。
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0),^{
        SCNetworkReachabilityFlags flags;
        if (SCNetworkReachabilityGetFlags(self.networkReachability, &flags)) {
            //更新网络状态 --- 通知
            // flag 修饰 status
            AFPostReachabilityStatusChange(flags, callback);
        }
    });
}

- (void)stopMonitoring {
    if (!self.networkReachability) {
        return;
    }

    SCNetworkReachabilityUnscheduleFromRunLoop(self.networkReachability, CFRunLoopGetMain(), kCFRunLoopCommonModes);
}

#pragma mark -
// 暴露的获取字符串接口 内部调用AFStringFromNetworkReachabilityStatus 获取本地化语言字符串
- (NSString *)localizedNetworkReachabilityStatusString {
    return AFStringFromNetworkReachabilityStatus(self.networkReachabilityStatus);
}

#pragma mark -

- (void)setReachabilityStatusChangeBlock:(void (^)(AFNetworkReachabilityStatus status))block {
    self.networkReachabilityStatusBlock = block;
}

#pragma mark - NSKeyValueObserving
// 键值绑定 当reachable reachableViaWWAN reachableViaWiFi改变时   networkReachabilityStatus要被通知
+ (NSSet *)keyPathsForValuesAffectingValueForKey:(NSString *)key {
    if ([key isEqualToString:@"reachable"] || [key isEqualToString:@"reachableViaWWAN"] || [key isEqualToString:@"reachableViaWiFi"]) {
        return [NSSet setWithObject:@"networkReachabilityStatus"];
    }

    return [super keyPathsForValuesAffectingValueForKey:key];
}

@end
#endif
