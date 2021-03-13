// GlobalTimelineViewController.m
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

#import "GlobalTimelineViewController.h"

#import "Post.h"

#import "PostTableViewCell.h"

@import AFNetworking;

@interface GlobalTimelineViewController ()
@property (readwrite, nonatomic, strong) NSArray *posts;
@end

@implementation GlobalTimelineViewController

- (void)reload:(__unused id)sender {
    self.navigationItem.rightBarButtonItem.enabled = NO;

    NSURLSessionTask *task = [Post globalTimelinePostsWithBlock:^(NSArray *posts, NSError *error) {
        if (!error) {
            self.posts = posts;
            [self.tableView reloadData];
        }
    }];

    [self.refreshControl setRefreshingWithStateOfTask:task];
}

#pragma mark - UIViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.title = NSLocalizedString(@"AFNetworking", nil);

    self.refreshControl = [[UIRefreshControl alloc] initWithFrame:CGRectMake(0.0f, 0.0f, self.tableView.frame.size.width, 100.0f)];
    [self.refreshControl addTarget:self action:@selector(reload:) forControlEvents:UIControlEventValueChanged];
    [self.tableView.tableHeaderView addSubview:self.refreshControl];

    self.tableView.rowHeight = 70.0f;
    
    [self reload:nil];
}

#pragma mark - Tcj-test
//url-request-session-task-resume
/*
 初始化：1.初始化session；2.设置很多默认值
 get:
 1.在生成request的时候处理了监听request的属性变化；
 2.参数转查询字符串；
 3.生成任务安全；
 4.通过AFURLSessionManagerTaskDelegate使得我们的进度可以通过block回调；
 5.通过AFURLSessionManagerTaskDelegate拼接我们的服务器返回数据
 */
- (void)get{
    NSString *urlStr = @"https://api.douban.com/v2/movie/top250";
    NSDictionary *dic = @{@"start":@(1),
                          @"count":@(5)
                        };
    // manager 设计模式?
    // 线程 -- 2.0 AF 常住 --- 3.0开始 NSOperationQueue
    // self.queue --- 必须要的东西 : 封装
    // request : 请求行+请求头+请求体
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    manager.requestSerializer.timeoutInterval = 5;
    manager.securityPolicy = [self securityPolicy];
    [manager GET:urlStr parameters:dic headers:nil progress:^(NSProgress * _Nonnull downloadProgress) {
        
    } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        NSLog(@"success");
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        
    }];
}

/*
 所有的分隔符以及文件内容以及参数都是要变成data拼接在一起，作为整个请求体发送给服务器
 每一行末尾有一个空行
 普通的post和multipart的post区别：
 1.content-type:
 2.httpbody/httpbodystrean
 requestserialization:1.动态监听我们的属性；2.设置请求头；3.生成查询字符串;4.分片上传
 
 总结：
 1.request序列化
    httprequest是根类，multipartformdata是重点
 2.response序列化
 
 */
- (void)multipart{
    // 1. 使用AFHTTPSessionManager的接口
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    NSDictionary *dic = @{@"businessType":@"CC_USER_CENTER",
                          @"fileType":@"image",
                          @"file":@"img.jpeg"
                          };
    //http://127.0.0.1:8080/uploadfile/
    // http://114.215.186.169:9002/api/demo/test/file
    [manager POST:@"http://114.215.186.169:9002/api/demo/test/file" parameters:dic headers:nil constructingBodyWithBlock:^(id<AFMultipartFormData>  _Nonnull formData) {
        // 在这个block中设置需要上传的文件
        NSString *path = [[NSBundle mainBundle] pathForResource:@"1" ofType:@"png"];
        // 将本地图片数据拼接到formData中 指定name
        [formData appendPartWithFileURL:[NSURL fileURLWithPath:path] name:@"file" error:nil];
        
        //或者使用这个接口拼接 指定name和filename
        NSData *picdata  =[NSData dataWithContentsOfFile:path];
        [formData appendPartWithFileData:picdata name:@"image" fileName:@"image.jpg" mimeType:@"image/jpeg"];
    } progress:^(NSProgress * _Nonnull uploadProgress) {
        NSLog(@"progress --- %@",uploadProgress.localizedDescription);
    } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        NSLog(@"responseObject-------%@", responseObject);
        dispatch_async(dispatch_get_main_queue(), ^{
            
        });
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        NSLog(@"Error-------%@", error);
    }];
    
}

- (AFSecurityPolicy *)securityPolicy{
    
    // .crt --->.cer
    NSString *cerPath = [[NSBundle mainBundle] pathForResource:@"https" ofType:@"cer"];
    NSData   *data    = [NSData dataWithContentsOfFile:cerPath];
    NSLog(@"%@",[[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding]);
    NSSet    *cerSet  = [NSSet setWithObject:data];
    
    AFSecurityPolicy *security = [AFSecurityPolicy policyWithPinningMode:AFSSLPinningModeCertificate withPinnedCertificates:cerSet];
    [AFSecurityPolicy defaultPolicy];
    
    security.allowInvalidCertificates = YES;
    security.validatesDomainName      = NO;
    return security;
}

- (void)testReachability{
    AFNetworkReachabilityManager *manager = [AFNetworkReachabilityManager sharedManager];
    [manager setReachabilityStatusChangeBlock:^(AFNetworkReachabilityStatus status) {
       
        switch (status) {
            case AFNetworkReachabilityStatusUnknown:
                NSLog(@"不明网络");
                break;
            case AFNetworkReachabilityStatusNotReachable:
                NSLog(@"没有网络");
                break;
            case AFNetworkReachabilityStatusReachableViaWWAN:
                NSLog(@"蜂窝网络");
                break;
            case AFNetworkReachabilityStatusReachableViaWiFi:
                NSLog(@"WiFi"); // 光纤
                break;
            default:
                break;
        }
    }];
    
    // 重点 .....
    [manager startMonitoring];
    
    // 第一次安装app 无网络状态 --- 没有给权限
}

#pragma mark - UITableViewDataSource

- (NSInteger)tableView:(__unused UITableView *)tableView
 numberOfRowsInSection:(__unused NSInteger)section
{
    return (NSInteger)[self.posts count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView
         cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    
    PostTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (!cell) {
        cell = [[PostTableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier];
    }
    
    cell.post = self.posts[(NSUInteger)indexPath.row];
    
    return cell;
}

#pragma mark - UITableViewDelegate

- (CGFloat)tableView:(__unused UITableView *)tableView
heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return [PostTableViewCell heightForCellWithPost:self.posts[(NSUInteger)indexPath.row]];
}

- (void)tableView:(UITableView *)tableView
didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

@end
