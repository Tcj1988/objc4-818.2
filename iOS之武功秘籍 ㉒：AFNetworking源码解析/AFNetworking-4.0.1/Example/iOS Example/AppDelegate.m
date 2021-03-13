// AppDelegate.m
//
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

#import "AppDelegate.h"
@import AFNetworking;

#import "GlobalTimelineViewController.h"
#import <CoreTelephony/CTCellularData.h>

@implementation AppDelegate

- (BOOL)application:(__unused UIApplication *)application didFinishLaunchingWithOptions:(__unused NSDictionary *)launchOptions
{
    NSURLCache *URLCache = [[NSURLCache alloc] initWithMemoryCapacity:4 * 1024 * 1024 diskCapacity:20 * 1024 * 1024 diskPath:nil];
    [NSURLCache setSharedURLCache:URLCache];
    
    [[AFNetworkActivityIndicatorManager sharedManager] setEnabled:YES];
    
    UITableViewController *viewController = [[GlobalTimelineViewController alloc] initWithStyle:UITableViewStylePlain];
    self.navigationController = [[UINavigationController alloc] initWithRootViewController:viewController];
    self.navigationController.navigationBar.tintColor = [UIColor darkGrayColor];
    
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    self.window.backgroundColor = [UIColor whiteColor];
    self.window.rootViewController = self.navigationController;
    [self.window makeKeyAndVisible];
    
    if (__IPHONE_10_0) {
        [self cellularData];
    }else{
        [self startMonitoringNetwork];
    }
    
    // 请求token
//    [self testBD];
    return YES;
}

#pragma mark - 网络权限监控
- (void)cellularData{
    
    CTCellularData *cellularData = [[CTCellularData alloc] init];
    
    cellularData.cellularDataRestrictionDidUpdateNotifier = ^(CTCellularDataRestrictedState state) {
        
        switch (state) {
            case kCTCellularDataRestrictedStateUnknown:
                NSLog(@"不明错误.....");
                break;
            case kCTCellularDataRestricted:
                NSLog(@"没有授权....");
                [self testBD]; // 默认没有授权 ... 发起短小网络 弹框
                break;
            case kCTCellularDataNotRestricted:
                NSLog(@"授权了////");
                [self startMonitoringNetwork];
                break;
            default:
                break;
        }
    };
}

#pragma mark - startMonitoringNetwork

- (void)startMonitoringNetwork{
    AFNetworkReachabilityManager *manager = [AFNetworkReachabilityManager sharedManager];
    
    [manager setReachabilityStatusChangeBlock:^(AFNetworkReachabilityStatus status) {
        switch (status) {
            case AFNetworkReachabilityStatusUnknown:
                NSLog(@"未知网络,请检查互联网");
                break;
            case AFNetworkReachabilityStatusNotReachable:
                NSLog(@"无网络,请检查互联网");
                break;
            case AFNetworkReachabilityStatusReachableViaWWAN:
                NSLog(@"连接蜂窝网络");
                [self testBD];
                break;
            case AFNetworkReachabilityStatusReachableViaWiFi:
                NSLog(@"WiFi网络");
                [self testBD];
                break;
            default:
                break;
        }
    }];
    [manager startMonitoring];

}

#pragma mark - 网络测试接口
- (void)testBD{
    NSString *urlString = @"http://api.douban.com/v2/movie/top250";
    NSDictionary *dic = @{@"start":@(1),
                          @"count":@(5)
                          };
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    [manager GET:urlString parameters:dic headers:nil progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        NSLog(@"请求成功:%@---%@",task,responseObject);
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        NSLog(@"错误提示:%@---%@",task,error);
    }];
}

@end
