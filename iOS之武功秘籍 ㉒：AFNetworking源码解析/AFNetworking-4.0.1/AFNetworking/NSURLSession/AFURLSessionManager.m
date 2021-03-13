// AFURLSessionManager.m
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

#import "AFURLSessionManager.h"
#import <objc/runtime.h>

//处理session的并发队列
//创建一个并发队列，用于在网络请求任务完成后处理数据的，并发队列实现多线程处理多个请求完成后的数据处理
static dispatch_queue_t url_session_manager_processing_queue() {
    static dispatch_queue_t af_url_session_manager_processing_queue;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        af_url_session_manager_processing_queue = dispatch_queue_create("com.alamofire.networking.session.manager.processing", DISPATCH_QUEUE_CONCURRENT);
    });

    return af_url_session_manager_processing_queue;
}

//处理session,完成回调的队列组
static dispatch_group_t url_session_manager_completion_group() {
    static dispatch_group_t af_url_session_manager_completion_group;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        af_url_session_manager_completion_group = dispatch_group_create();
    });

    return af_url_session_manager_completion_group;
}

//常量字符串（key或通知，用反域名显得很正式）
NSString * const AFNetworkingTaskDidResumeNotification = @"com.alamofire.networking.task.resume";
NSString * const AFNetworkingTaskDidCompleteNotification = @"com.alamofire.networking.task.complete";
NSString * const AFNetworkingTaskDidSuspendNotification = @"com.alamofire.networking.task.suspend";
NSString * const AFURLSessionDidInvalidateNotification = @"com.alamofire.networking.session.invalidate";
NSString * const AFURLSessionDownloadTaskDidMoveFileSuccessfullyNotification = @"com.alamofire.networking.session.download.file-manager-succeed";
NSString * const AFURLSessionDownloadTaskDidFailToMoveFileNotification = @"com.alamofire.networking.session.download.file-manager-error";

NSString * const AFNetworkingTaskDidCompleteSerializedResponseKey = @"com.alamofire.networking.task.complete.serializedresponse";
NSString * const AFNetworkingTaskDidCompleteResponseSerializerKey = @"com.alamofire.networking.task.complete.responseserializer";
NSString * const AFNetworkingTaskDidCompleteResponseDataKey = @"com.alamofire.networking.complete.finish.responsedata";
NSString * const AFNetworkingTaskDidCompleteErrorKey = @"com.alamofire.networking.task.complete.error";
NSString * const AFNetworkingTaskDidCompleteAssetPathKey = @"com.alamofire.networking.task.complete.assetpath";
NSString * const AFNetworkingTaskDidCompleteSessionTaskMetrics = @"com.alamofire.networking.complete.sessiontaskmetrics";

static NSString * const AFURLSessionManagerLockName = @"com.alamofire.networking.session.manager.lock";

//block的命名
typedef void (^AFURLSessionDidBecomeInvalidBlock)(NSURLSession *session, NSError *error);
typedef NSURLSessionAuthChallengeDisposition (^AFURLSessionDidReceiveAuthenticationChallengeBlock)(NSURLSession *session, NSURLAuthenticationChallenge *challenge, NSURLCredential * __autoreleasing *credential);

typedef NSURLRequest * (^AFURLSessionTaskWillPerformHTTPRedirectionBlock)(NSURLSession *session, NSURLSessionTask *task, NSURLResponse *response, NSURLRequest *request);
typedef NSURLSessionAuthChallengeDisposition (^AFURLSessionTaskDidReceiveAuthenticationChallengeBlock)(NSURLSession *session, NSURLSessionTask *task, NSURLAuthenticationChallenge *challenge, NSURLCredential * __autoreleasing *credential);
typedef id (^AFURLSessionTaskAuthenticationChallengeBlock)(NSURLSession *session, NSURLSessionTask *task, NSURLAuthenticationChallenge *challenge, void (^completionHandler)(NSURLSessionAuthChallengeDisposition disposition, NSURLCredential *credential));
typedef void (^AFURLSessionDidFinishEventsForBackgroundURLSessionBlock)(NSURLSession *session);

typedef NSInputStream * (^AFURLSessionTaskNeedNewBodyStreamBlock)(NSURLSession *session, NSURLSessionTask *task);
typedef void (^AFURLSessionTaskDidSendBodyDataBlock)(NSURLSession *session, NSURLSessionTask *task, int64_t bytesSent, int64_t totalBytesSent, int64_t totalBytesExpectedToSend);
typedef void (^AFURLSessionTaskDidCompleteBlock)(NSURLSession *session, NSURLSessionTask *task, NSError *error);
#if AF_CAN_INCLUDE_SESSION_TASK_METRICS
typedef void (^AFURLSessionTaskDidFinishCollectingMetricsBlock)(NSURLSession *session, NSURLSessionTask *task, NSURLSessionTaskMetrics * metrics) AF_API_AVAILABLE(ios(10), macosx(10.12), watchos(3), tvos(10));
#endif

typedef NSURLSessionResponseDisposition (^AFURLSessionDataTaskDidReceiveResponseBlock)(NSURLSession *session, NSURLSessionDataTask *dataTask, NSURLResponse *response);
typedef void (^AFURLSessionDataTaskDidBecomeDownloadTaskBlock)(NSURLSession *session, NSURLSessionDataTask *dataTask, NSURLSessionDownloadTask *downloadTask);
typedef void (^AFURLSessionDataTaskDidReceiveDataBlock)(NSURLSession *session, NSURLSessionDataTask *dataTask, NSData *data);
typedef NSCachedURLResponse * (^AFURLSessionDataTaskWillCacheResponseBlock)(NSURLSession *session, NSURLSessionDataTask *dataTask, NSCachedURLResponse *proposedResponse);

typedef NSURL * (^AFURLSessionDownloadTaskDidFinishDownloadingBlock)(NSURLSession *session, NSURLSessionDownloadTask *downloadTask, NSURL *location);
typedef void (^AFURLSessionDownloadTaskDidWriteDataBlock)(NSURLSession *session, NSURLSessionDownloadTask *downloadTask, int64_t bytesWritten, int64_t totalBytesWritten, int64_t totalBytesExpectedToWrite);
typedef void (^AFURLSessionDownloadTaskDidResumeBlock)(NSURLSession *session, NSURLSessionDownloadTask *downloadTask, int64_t fileOffset, int64_t expectedTotalBytes);
typedef void (^AFURLSessionTaskProgressBlock)(NSProgress *);

typedef void (^AFURLSessionTaskCompletionHandler)(NSURLResponse *response, id responseObject, NSError *error);

#pragma mark -
//此类遵守NSURLSession相关协议，方便外部直接调用协议方法
@interface AFURLSessionManagerTaskDelegate : NSObject <NSURLSessionTaskDelegate, NSURLSessionDataDelegate, NSURLSessionDownloadDelegate>
// 使用task对象初始化，task用于progress的回调操作
- (instancetype)initWithTask:(NSURLSessionTask *)task;

//weak防止循环引用（manager持有task，task和delegate是绑定的，相当于manager是持有delegate的）
@property (nonatomic, weak) AFURLSessionManager *manager;

//可变data用于存储获取到的网络数据
@property (nonatomic, strong) NSMutableData *mutableData;

//上传进度NSProgress
@property (nonatomic, strong) NSProgress *uploadProgress;

//下载进度NSProgress
@property (nonatomic, strong) NSProgress *downloadProgress;

//下载文件的NSURL
@property (nonatomic, copy) NSURL *downloadFileURL;
#if AF_CAN_INCLUDE_SESSION_TASK_METRICS
// 任务数据采集
@property (nonatomic, strong) NSURLSessionTaskMetrics *sessionTaskMetrics AF_API_AVAILABLE(ios(10), macosx(10.12), watchos(3), tvos(10));
#endif

//下载完成的回调块
@property (nonatomic, copy) AFURLSessionDownloadTaskDidFinishDownloadingBlock downloadTaskDidFinishDownloading;

//上传进度的回调块
@property (nonatomic, copy) AFURLSessionTaskProgressBlock uploadProgressBlock;

//下载进度的回调块
@property (nonatomic, copy) AFURLSessionTaskProgressBlock downloadProgressBlock;

//网络请求完成的回调块
@property (nonatomic, copy) AFURLSessionTaskCompletionHandler completionHandler;
@end

@implementation AFURLSessionManagerTaskDelegate

- (instancetype)initWithTask:(NSURLSessionTask *)task {
    self = [super init];
    if (!self) {
        return nil;
    }
    
    _mutableData = [NSMutableData data];
    _uploadProgress = [[NSProgress alloc] initWithParent:nil userInfo:nil];
    _downloadProgress = [[NSProgress alloc] initWithParent:nil userInfo:nil];
    
    //NSProgress管理task的取消，挂起和进度的
    __weak __typeof__(task) weakTask = task;
    for (NSProgress *progress in @[ _uploadProgress, _downloadProgress ])
    {
        //拿到上传下载期望的数据大小
        progress.totalUnitCount = NSURLSessionTransferSizeUnknown;
        //设置这两个NSProgress对应的cancel、pause和resume这三个状态，正好对应session task的cancel、suspend和resume三个状态
        progress.cancellable = YES;
        progress.cancellationHandler = ^{
            [weakTask cancel];
        };
        progress.pausable = YES;
        progress.pausingHandler = ^{
            [weakTask suspend];
        };
#if AF_CAN_USE_AT_AVAILABLE
        if (@available(macOS 10.11, *))
#else
        if ([progress respondsToSelector:@selector(setResumingHandler:)])
#endif
        {
            progress.resumingHandler = ^{
                [weakTask resume];
            };
        }
        // 对progress变化进行监控KVO,fractionCompleted:任务已经完成的比例，取值为0~1
        [progress addObserver:self
                   forKeyPath:NSStringFromSelector(@selector(fractionCompleted))
                      options:NSKeyValueObservingOptionNew
                      context:NULL];
    }
    return self;
}

- (void)dealloc {
    [self.downloadProgress removeObserver:self forKeyPath:NSStringFromSelector(@selector(fractionCompleted))];
    [self.uploadProgress removeObserver:self forKeyPath:NSStringFromSelector(@selector(fractionCompleted))];
}

#pragma mark - NSProgress Tracking
//KVO回调方法
- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSString *,id> *)change context:(void *)context {
    //根据NSProgress的状态做用户自定义的行为，比如需要更新UI进度条的状态之类的
   if ([object isEqual:self.downloadProgress]) {
        if (self.downloadProgressBlock) {
            self.downloadProgressBlock(object);
        }
    }
    else if ([object isEqual:self.uploadProgress]) {
        if (self.uploadProgressBlock) {
            self.uploadProgressBlock(object);
        }
    }
}

static const void * const AuthenticationChallengeErrorKey = &AuthenticationChallengeErrorKey;

#pragma mark - NSURLSessionTaskDelegate
//AF实现的代理！被从urlsession那转发到这
/*
 第一个是获取数据，将responseSerializer和downloadFileURL或data存到userInfo里面
 第二个是根据error是否为空值，做下一步处理
 */
- (void)URLSession:(__unused NSURLSession *)session
              task:(NSURLSessionTask *)task
didCompleteWithError:(NSError *)error
{
    error = objc_getAssociatedObject(task, AuthenticationChallengeErrorKey) ?: error;
    //1）强引用self.manager，防止被提前释放；因为self.manager声明为weak,类似Block
    __strong AFURLSessionManager *manager = self.manager;

    __block id responseObject = nil;
    // 因为NSNotification这个类中本身有userInfo属性，可作为响应函数的参数
    // 不过我在AFNetworking源码中还未发现使用userInfo作为参数的做法，可能需要用户自己实现
    
    /**
     * userInfo中的key值例举如下：
     * AFNetworkingTaskDidCompleteResponseDataKey session 存储task获取到的原始response数据，与序列化后的response有所不同
     * AFNetworkingTaskDidCompleteSerializedResponseKey 存储经过序列化（serialized）后的response
     * AFNetworkingTaskDidCompleteResponseSerializerKey 保存序列化response的序列化器(serializer)
     * AFNetworkingTaskDidCompleteAssetPathKey 存储下载任务后，数据文件存放在磁盘上的位置
     * AFNetworkingTaskDidCompleteErrorKey 错误信息
     */
    //用来存储一些相关信息，来发送通知用的
    NSMutableDictionary *userInfo = [NSMutableDictionary dictionary];
    //存储responseSerializer响应解析对象
    userInfo[AFNetworkingTaskDidCompleteResponseSerializerKey] = manager.responseSerializer;

    //Performance Improvement from #2672
    //具体可以查看#issue 2672。这里主要是针对大文件的时候，性能提升会很明显
    NSData *data = nil;
    if (self.mutableData) {
        data = [self.mutableData copy];
        //We no longer need the reference, so nil it out to gain back some memory.
        self.mutableData = nil;
    }

#if AF_CAN_USE_AT_AVAILABLE && AF_CAN_INCLUDE_SESSION_TASK_METRICS
    if (@available(iOS 10, macOS 10.12, watchOS 3, tvOS 10, *)) {
        if (self.sessionTaskMetrics) {
            userInfo[AFNetworkingTaskDidCompleteSessionTaskMetrics] = self.sessionTaskMetrics;
        }
    }
#endif
    
    //继续给userinfo填数据
    ////如果downloadFileURL存在，即是下载任务就设置下载完成后的文件存储url到字典中
    if (self.downloadFileURL) {
        userInfo[AFNetworkingTaskDidCompleteAssetPathKey] = self.downloadFileURL;
    } else if (data) {
        //否则就设置对应的NSData数据到字典中
        userInfo[AFNetworkingTaskDidCompleteResponseDataKey] = data;
    }

    // 如果task出错了，处理error信息
    // 所以对应的观察者在处理error的时候，比如可以先判断userInfo[AFNetworkingTaskDidCompleteErrorKey]是否有值，有值的话，就说明是要处理error
    if (error) {
        userInfo[AFNetworkingTaskDidCompleteErrorKey] = error;

        // 这里用group方式来运行task完成方法，表示当前所有的task任务完成，才会通知执行其他操作
        // 如果没有实现自定义的completionGroup和completionQueue，那么就使用AFNetworking提供的私有的dispatch_group_t和提供的dispatch_get_main_queue内容
        dispatch_group_async(manager.completionGroup ?: url_session_manager_completion_group(), manager.completionQueue ?: dispatch_get_main_queue(), ^{
            if (self.completionHandler) {
                self.completionHandler(task.response, responseObject, error);
            }

            //主线程中发送完成通知
            dispatch_async(dispatch_get_main_queue(), ^{
                [[NSNotificationCenter defaultCenter] postNotificationName:AFNetworkingTaskDidCompleteNotification object:task userInfo:userInfo];
            });
        });
    } else {//在没有error时，会先对数据进行一次序列化操作，然后下面的处理就和有error的那部分一样了
        // 请求成功了,为什么还要异步呢?
        // response 序列化 : 类型比较多.如 200 300 400 500
        dispatch_async(url_session_manager_processing_queue(), ^{
            NSError *serializationError = nil;
            // 根据对应的task和data将response data解析成可用的数据格式，比如JSON serializer就将data解析成JSON格式
            responseObject = [manager.responseSerializer responseObjectForResponse:task.response data:data error:&serializationError];

             // 注意如果有downloadFileURL，意味着data存放在了磁盘上了，所以此处responseObject保存的是data存放位置，供后面completionHandler处理。没有downloadFileURL，就直接使用内存中的解析后的data数据
            if (self.downloadFileURL) {
                responseObject = self.downloadFileURL;
            }

            //写入userInfo
            if (responseObject) {
                userInfo[AFNetworkingTaskDidCompleteSerializedResponseKey] = responseObject;
            }

            // 序列化的时候出现错误
            if (serializationError) {
                userInfo[AFNetworkingTaskDidCompleteErrorKey] = serializationError;
            }

            //回调结果
            //同理，在dispatch组中和特定队列执行回调块
            dispatch_group_async(manager.completionGroup ?: url_session_manager_completion_group(), manager.completionQueue ?: dispatch_get_main_queue(), ^{
                if (self.completionHandler) {
                    self.completionHandler(task.response, responseObject, serializationError);
                }

                //主线程发送通知
                dispatch_async(dispatch_get_main_queue(), ^{
                    [[NSNotificationCenter defaultCenter] postNotificationName:AFNetworkingTaskDidCompleteNotification object:task userInfo:userInfo];
                });
            });
        });
    }
}

#if AF_CAN_INCLUDE_SESSION_TASK_METRICS
- (void)URLSession:(NSURLSession *)session
              task:(NSURLSessionTask *)task
didFinishCollectingMetrics:(NSURLSessionTaskMetrics *)metrics AF_API_AVAILABLE(ios(10), macosx(10.12), watchos(3), tvos(10)) {
    self.sessionTaskMetrics = metrics;
}
#endif

#pragma mark - NSURLSessionDataDelegate
//回调方法，收到数据
- (void)URLSession:(__unused NSURLSession *)session
          dataTask:(__unused NSURLSessionDataTask *)dataTask
    didReceiveData:(NSData *)data
{
    self.downloadProgress.totalUnitCount = dataTask.countOfBytesExpectedToReceive;
    self.downloadProgress.completedUnitCount = dataTask.countOfBytesReceived;

    //拼接数据
    NSLog(@"delete--%@",[NSThread currentThread]);
    [self.mutableData appendData:data];
}

- (void)URLSession:(NSURLSession *)session task:(NSURLSessionTask *)task
   didSendBodyData:(int64_t)bytesSent
    totalBytesSent:(int64_t)totalBytesSent
totalBytesExpectedToSend:(int64_t)totalBytesExpectedToSend{
    
    self.uploadProgress.totalUnitCount = task.countOfBytesExpectedToSend;
    self.uploadProgress.completedUnitCount = task.countOfBytesSent;
}

#pragma mark - NSURLSessionDownloadDelegate

- (void)URLSession:(NSURLSession *)session downloadTask:(NSURLSessionDownloadTask *)downloadTask
      didWriteData:(int64_t)bytesWritten
 totalBytesWritten:(int64_t)totalBytesWritten
totalBytesExpectedToWrite:(int64_t)totalBytesExpectedToWrite{
    
    self.downloadProgress.totalUnitCount = totalBytesExpectedToWrite;
    self.downloadProgress.completedUnitCount = totalBytesWritten;
}

- (void)URLSession:(NSURLSession *)session downloadTask:(NSURLSessionDownloadTask *)downloadTask
 didResumeAtOffset:(int64_t)fileOffset
expectedTotalBytes:(int64_t)expectedTotalBytes{
    
    self.downloadProgress.totalUnitCount = expectedTotalBytes;
    self.downloadProgress.completedUnitCount = fileOffset;
}

- (void)URLSession:(NSURLSession *)session
      downloadTask:(NSURLSessionDownloadTask *)downloadTask
didFinishDownloadingToURL:(NSURL *)location
{
    self.downloadFileURL = nil;
    
    //AF代理的自定义Block
    if (self.downloadTaskDidFinishDownloading) {
        //得到自定义下载路径
        self.downloadFileURL = self.downloadTaskDidFinishDownloading(session, downloadTask, location);
        if (self.downloadFileURL) {
            NSError *fileManagerError = nil;

            //把下载路径移动到我们自定义的下载路径
            if (![[NSFileManager defaultManager] moveItemAtURL:location toURL:self.downloadFileURL error:&fileManagerError]) {
                [[NSNotificationCenter defaultCenter] postNotificationName:AFURLSessionDownloadTaskDidFailToMoveFileNotification object:downloadTask userInfo:fileManagerError.userInfo];
            } else {//错误发通知
                [[NSNotificationCenter defaultCenter] postNotificationName:AFURLSessionDownloadTaskDidMoveFileSuccessfullyNotification object:downloadTask userInfo:nil];
            }
        }
    }
}

@end

/*
_AFURLSessionTaskSwizzling类存在的目的就是为了交换NSURLSessionTask的resume和suspend方法的实现，
 因为iOS7和iOS8中NSURLSessionTask的父类不同，需要做一些处理
*/
#pragma mark -

/**
 *  A workaround for issues related to key-value observing the `state` of an `NSURLSessionTask`.
 *
 *  See:
 *  - https://github.com/AFNetworking/AFNetworking/issues/1477
 *  - https://github.com/AFNetworking/AFNetworking/issues/2638
 *  - https://github.com/AFNetworking/AFNetworking/pull/2702
 */
// 根据两个方法名称交换两个方法，内部实现是先根据函数名获取到对应方法实现
// 再调用method_exchangeImplementations交换两个方法
/*
 在调用替换和增加方法时候，用到了关键字inline，inline是为了防止反汇编之后，
 在符号表里面看不到你所调用的该方法，否则别人可以通过篡改你的返回值来造成攻击，
 iOS安全–使用static inline方式编译函数，防止静态分析，特别是在使用swizzling的时候，
 那除了使用swizzling动态替换函数方法之外，还有别的方法么？有，修改IMP指针指向的方法
 */
static inline void af_swizzleSelector(Class theClass, SEL originalSelector, SEL swizzledSelector) {
    Method originalMethod = class_getInstanceMethod(theClass, originalSelector);
    Method swizzledMethod = class_getInstanceMethod(theClass, swizzledSelector);
    //涉及到runtime
    method_exchangeImplementations(originalMethod, swizzledMethod);
}

// 给theClass添加名为selector，对应实现为method的方法
static inline BOOL af_addMethod(Class theClass, SEL selector, Method method) {
    // 内部实现使用的是class_addMethod方法，注意method_getTypeEncoding是为了获得该方法的参数和返回类型
    return class_addMethod(theClass, selector,  method_getImplementation(method),  method_getTypeEncoding(method));
}

static NSString * const AFNSURLSessionTaskDidResumeNotification  = @"com.alamofire.networking.nsurlsessiontask.resume";
static NSString * const AFNSURLSessionTaskDidSuspendNotification = @"com.alamofire.networking.nsurlsessiontask.suspend";

@interface _AFURLSessionTaskSwizzling : NSObject

@end

@implementation _AFURLSessionTaskSwizzling

+ (void)load {
    /**
     WARNING: Trouble Ahead
     https://github.com/AFNetworking/AFNetworking/pull/2702
     */

    if (NSClassFromString(@"NSURLSessionTask")) {
        /**
         iOS 7 and iOS 8 differ in NSURLSessionTask implementation, which makes the next bit of code a bit tricky.
         Many Unit Tests have been built to validate as much of this behavior has possible.
         Here is what we know:
            - NSURLSessionTasks are implemented with class clusters, meaning the class you request from the API isn't actually the type of class you will get back.
            - Simply referencing `[NSURLSessionTask class]` will not work. You need to ask an `NSURLSession` to actually create an object, and grab the class from there.
            - On iOS 7, `localDataTask` is a `__NSCFLocalDataTask`, which inherits from `__NSCFLocalSessionTask`, which inherits from `__NSCFURLSessionTask`.
            - On iOS 8, `localDataTask` is a `__NSCFLocalDataTask`, which inherits from `__NSCFLocalSessionTask`, which inherits from `NSURLSessionTask`.
            - On iOS 7, `__NSCFLocalSessionTask` and `__NSCFURLSessionTask` are the only two classes that have their own implementations of `resume` and `suspend`, and `__NSCFLocalSessionTask` DOES NOT CALL SUPER. This means both classes need to be swizzled.
            - On iOS 8, `NSURLSessionTask` is the only class that implements `resume` and `suspend`. This means this is the only class that needs to be swizzled.
            - Because `NSURLSessionTask` is not involved in the class hierarchy for every version of iOS, its easier to add the swizzled methods to a dummy class and manage them there.
        
         Some Assumptions:
            - No implementations of `resume` or `suspend` call super. If this were to change in a future version of iOS, we'd need to handle it.
            - No background task classes override `resume` or `suspend`
         
         The current solution:
            1) Grab an instance of `__NSCFLocalDataTask` by asking an instance of `NSURLSession` for a data task.
            2) Grab a pointer to the original implementation of `af_resume`
            3) Check to see if the current class has an implementation of resume. If so, continue to step 4.
            4) Grab the super class of the current class.
            5) Grab a pointer for the current class to the current implementation of `resume`.
            6) Grab a pointer for the super class to the current implementation of `resume`.
            7) If the current class implementation of `resume` is not equal to the super class implementation of `resume` AND the current implementation of `resume` is not equal to the original implementation of `af_resume`, THEN swizzle the methods
            8) Set the current class to the super class, and repeat steps 3-8
         */
        
        /**
         iOS7 和 iOS8 在NSURLSessionTask实现上有些许不同，这使得下面的代码实现略显trick
         关于这个问题，大家做了很多Unit Test，足以证明这个方法是可行的
         目前我们所知的：
         - NSURLSessionTasks是一组class的统称，如果你仅仅使用提供的API来获取NSURLSessionTask的class，并不一定返回的是你想要的那个（获取NSURLSessionTask的class目的是为了获取其resume方法）
         - 简单地使用[NSURLSessionTask class]并不起作用。你需要新建一个NSURLSession，并根据创建的session再构建出一个NSURLSessionTask对象才行。
         - iOS 7上，localDataTask（下面代码构造出的NSURLSessionDataTask类型的变量，为了获取对应Class）的类型是 __NSCFLocalDataTask，__NSCFLocalDataTask继承自__NSCFLocalSessionTask，__NSCFLocalSessionTask继承自__NSCFURLSessionTask。
         - iOS 8上，localDataTask的类型为__NSCFLocalDataTask，__NSCFLocalDataTask继承自__NSCFLocalSessionTask，__NSCFLocalSessionTask继承自NSURLSessionTask
         - iOS 7上，__NSCFLocalSessionTask和__NSCFURLSessionTask是仅有的两个实现了resume和suspend方法的类，另外__NSCFLocalSessionTask中的resume和suspend并没有调用其父类（即__NSCFURLSessionTask）方法，这也意味着两个类的方法都需要进行method swizzling。
         - iOS 8上，NSURLSessionTask是唯一实现了resume和suspend方法的类。这也意味着其是唯一需要进行method swizzling的类
         - 因为NSURLSessionTask并不是在每个iOS版本中都存在，所以把这些放在此处（即load函数中），比如给一个dummy class添加swizzled方法都会变得很方便，管理起来也方便。
         
         一些假设前提:
         - 目前iOS中resume和suspend的方法实现中并没有调用对应的父类方法。如果日后iOS改变了这种做法，我们还需要重新处理
         - 没有哪个后台task会重写resume和suspend函数
         
         */
        
        // 1) 首先构建一个NSURLSession对象session，再通过session构建出一个_NSCFLocalDataTask变量
        NSURLSessionConfiguration *configuration = [NSURLSessionConfiguration ephemeralSessionConfiguration];
        NSURLSession *session = [NSURLSession sessionWithConfiguration:configuration];
#pragma GCC diagnostic push
#pragma GCC diagnostic ignored "-Wnonnull"
        NSURLSessionDataTask *localDataTask = [session dataTaskWithURL:nil];
#pragma clang diagnostic pop
        // 2) 获取到af_resume实现的指针
        IMP originalAFResumeIMP = method_getImplementation(class_getInstanceMethod([self class], @selector(af_resume)));
        Class currentClass = [localDataTask class];
        
        // 3) 检查当前class是否实现了resume。如果实现了，继续第4步
        while (class_getInstanceMethod(currentClass, @selector(resume))) {
            // 4) 获取到当前class的父类（superClass）
            Class superClass = [currentClass superclass];
            // 5) 获取到当前class对于resume实现的指针
            IMP classResumeIMP = method_getImplementation(class_getInstanceMethod(currentClass, @selector(resume)));
            // 6) 获取到父类对于resume实现的指针
            IMP superclassResumeIMP = method_getImplementation(class_getInstanceMethod(superClass, @selector(resume)));
            // 7) 如果当前class对于resume的实现和父类不一样（类似iOS7上的情况），并且当前class的resume实现和af_resume不一样，才进行method swizzling。
            if (classResumeIMP != superclassResumeIMP &&
                originalAFResumeIMP != classResumeIMP) {
                [self swizzleResumeAndSuspendMethodForClass:currentClass];
            }
            // 8) 设置当前操作的class为其父类class，重复步骤3~8
            currentClass = [currentClass superclass];
        }
        
        [localDataTask cancel];
        [session finishTasksAndInvalidate];
    }
}

+ (void)swizzleResumeAndSuspendMethodForClass:(Class)theClass {
    // 因为af_resume和af_suspend都是类的实例方法，所以使用class_getInstanceMethod获取这两个方法
    Method afResumeMethod = class_getInstanceMethod(self, @selector(af_resume));
    Method afSuspendMethod = class_getInstanceMethod(self, @selector(af_suspend));

    // 给theClass添加一个名为af_resume的方法，使用@selector(af_resume)获取方法名，使用afResumeMethod作为方法实现
    if (af_addMethod(theClass, @selector(af_resume), afResumeMethod)) {
        // 交换resume和af_resume的方法实现
        af_swizzleSelector(theClass, @selector(resume), @selector(af_resume));
    }

    if (af_addMethod(theClass, @selector(af_suspend), afSuspendMethod)) {
        af_swizzleSelector(theClass, @selector(suspend), @selector(af_suspend));
    }
}

- (NSURLSessionTaskState)state {
    NSAssert(NO, @"State method should never be called in the actual dummy class");
    // 初始状态是NSURLSessionTaskStateCanceling;
    return NSURLSessionTaskStateCanceling;
}

- (void)af_resume {
    NSAssert([self respondsToSelector:@selector(state)], @"Does not respond to state");
    NSURLSessionTaskState state = [self state];
    [self af_resume];//注意这里不是递归哦
    
    // 因为经过method swizzling后，此处的af_resume其实就是之前的resume，所以此处调用af_resume就是调用系统的resume。但是在程序中我们还是得使用resume，因为其实际调用的是af_resume
    // 如果之前是其他状态，就变回resume状态，此处会通知调用taskDidResume
    if (state != NSURLSessionTaskStateRunning) {
        [[NSNotificationCenter defaultCenter] postNotificationName:AFNSURLSessionTaskDidResumeNotification object:self];
    }
}

// 同上
- (void)af_suspend {
    NSAssert([self respondsToSelector:@selector(state)], @"Does not respond to state");
    NSURLSessionTaskState state = [self state];
    [self af_suspend];
    
    if (state != NSURLSessionTaskStateSuspended) {
        [[NSNotificationCenter defaultCenter] postNotificationName:AFNSURLSessionTaskDidSuspendNotification object:self];
    }
}
@end

#pragma mark -
/* 隐式声明 */
@interface AFURLSessionManager ()
//管理的session运行模式，默认情况下使用默认运行模式，defaultConfiguration
@property (readwrite, nonatomic, strong) NSURLSessionConfiguration *sessionConfiguration;
//NSOperation队列，代理方法执行的队列
@property (readwrite, nonatomic, strong) NSOperationQueue *operationQueue;
//管理的session
@property (readwrite, nonatomic, strong) NSURLSession *session;
//可变字典，key是NSURLSessionTask的唯一NSUInteger类型标识，value是对应的AFURLSessionManagerTaskDelgate对象
@property (readwrite, nonatomic, strong) NSMutableDictionary *mutableTaskDelegatesKeyedByTaskIdentifier;
//只读属性，通过getter返回数据
@property (readonly, nonatomic, copy) NSString *taskDescriptionForSessionTasks;
//NSLock锁
@property (readwrite, nonatomic, strong) NSLock *lock;
@property (readwrite, nonatomic, copy) AFURLSessionDidBecomeInvalidBlock sessionDidBecomeInvalid;
@property (readwrite, nonatomic, copy) AFURLSessionDidReceiveAuthenticationChallengeBlock sessionDidReceiveAuthenticationChallenge;
@property (readwrite, nonatomic, copy) AFURLSessionDidFinishEventsForBackgroundURLSessionBlock didFinishEventsForBackgroundURLSession AF_API_UNAVAILABLE(macos);
@property (readwrite, nonatomic, copy) AFURLSessionTaskWillPerformHTTPRedirectionBlock taskWillPerformHTTPRedirection;
@property (readwrite, nonatomic, copy) AFURLSessionTaskAuthenticationChallengeBlock authenticationChallengeHandler;
@property (readwrite, nonatomic, copy) AFURLSessionTaskNeedNewBodyStreamBlock taskNeedNewBodyStream;
@property (readwrite, nonatomic, copy) AFURLSessionTaskDidSendBodyDataBlock taskDidSendBodyData;
@property (readwrite, nonatomic, copy) AFURLSessionTaskDidCompleteBlock taskDidComplete;
#if AF_CAN_INCLUDE_SESSION_TASK_METRICS
@property (readwrite, nonatomic, copy) AFURLSessionTaskDidFinishCollectingMetricsBlock taskDidFinishCollectingMetrics AF_API_AVAILABLE(ios(10), macosx(10.12), watchos(3), tvos(10));
#endif
@property (readwrite, nonatomic, copy) AFURLSessionDataTaskDidReceiveResponseBlock dataTaskDidReceiveResponse;
@property (readwrite, nonatomic, copy) AFURLSessionDataTaskDidBecomeDownloadTaskBlock dataTaskDidBecomeDownloadTask;
@property (readwrite, nonatomic, copy) AFURLSessionDataTaskDidReceiveDataBlock dataTaskDidReceiveData;
@property (readwrite, nonatomic, copy) AFURLSessionDataTaskWillCacheResponseBlock dataTaskWillCacheResponse;
@property (readwrite, nonatomic, copy) AFURLSessionDownloadTaskDidFinishDownloadingBlock downloadTaskDidFinishDownloading;
@property (readwrite, nonatomic, copy) AFURLSessionDownloadTaskDidWriteDataBlock downloadTaskDidWriteData;
@property (readwrite, nonatomic, copy) AFURLSessionDownloadTaskDidResumeBlock downloadTaskDidResume;
@end

@implementation AFURLSessionManager
//构造函数
- (instancetype)init {
    return [self initWithSessionConfiguration:nil];
}

/*
1.初始化一个session
2.给manager的属性设置初始值
*/
- (instancetype)initWithSessionConfiguration:(NSURLSessionConfiguration *)configuration {
    self = [super init];
    if (!self) {
        return nil;
    }

    //设置默认的configuration,配置我们的session
    if (!configuration) {
        configuration = [NSURLSessionConfiguration defaultSessionConfiguration];
    }

    //持有configuration
    self.sessionConfiguration = configuration;

    //设置为delegate的操作队列并发的线程数量1，也就是串行队列 目的是想要让并发的请求串行的进行回调
    self.operationQueue = [[NSOperationQueue alloc] init];
    // 线程安全考虑.. 思考为什么这样呢?能不能多开几个线程呢?---答案是不能
    self.operationQueue.maxConcurrentOperationCount = 1;
    
    /*
    －如果完成后需要做复杂(耗时)的处理，可以选择异步队列
    －如果完成后直接更新UI，可以选择主队列
    [NSOperationQueue mainQueue]
    */

    //默认为json解析
    self.responseSerializer = [AFJSONResponseSerializer serializer];

    //设置默认证书 无条件信任证书https认证
    self.securityPolicy = [AFSecurityPolicy defaultPolicy];

#if !TARGET_OS_WATCH
    //网络状态监听
    self.reachabilityManager = [AFNetworkReachabilityManager sharedManager];
#endif
    //为什么要收集: cancel resume supend : task : id
    //delegate= value taskid = key
    self.mutableTaskDelegatesKeyedByTaskIdentifier = [[NSMutableDictionary alloc] init];

    //使用NSLock确保线程安全
    self.lock = [[NSLock alloc] init];
    self.lock.name = AFURLSessionManagerLockName;

    //异步的获取当前session的所有未完成的task。其实讲道理来说在初始化中调用这个方法应该里面一个task都不会有
    //后台任务重新回来初始化session，可能就会有先前的任务
    //https://github.com/AFNetworking/AFNetworking/issues/3499
    [self.session getTasksWithCompletionHandler:^(NSArray *dataTasks, NSArray *uploadTasks, NSArray *downloadTasks) {
        for (NSURLSessionDataTask *task in dataTasks) {
            [self addDelegateForDataTask:task uploadProgress:nil downloadProgress:nil completionHandler:nil];
        }

        for (NSURLSessionUploadTask *uploadTask in uploadTasks) {
            [self addDelegateForUploadTask:uploadTask progress:nil completionHandler:nil];
        }

        for (NSURLSessionDownloadTask *downloadTask in downloadTasks) {
            [self addDelegateForDownloadTask:downloadTask progress:nil destination:nil completionHandler:nil];
        }
    }];

    return self;
}

//析构方法，移除所有通知监听
- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

#pragma mark -

- (NSURLSession *)session {
    
    @synchronized (self) {
        if (!_session) {
            _session = [NSURLSession sessionWithConfiguration:self.sessionConfiguration delegate:self delegateQueue:self.operationQueue];
        }
    }
    return _session;
}

#pragma mark -

//taskDescriptionForSessionTasks属性的getter，返回地址的字符串形式数据，可以保证这个字符串是唯一的
- (NSString *)taskDescriptionForSessionTasks {
    return [NSString stringWithFormat:@"%p", self];
}

//通知的回调方法，接下来的代码会添加相关通知
- (void)taskDidResume:(NSNotification *)notification {
    //发送通知的时候会将task添加进通知中
    NSURLSessionTask *task = notification.object;
    //判断这个任务是否是当前manager管理的，如果是就发送相关通知
    //task的taskDescription属性在下文的源码中会设置
    if ([task respondsToSelector:@selector(taskDescription)]) {
        if ([task.taskDescription isEqualToString:self.taskDescriptionForSessionTasks]) {
            dispatch_async(dispatch_get_main_queue(), ^{
                [[NSNotificationCenter defaultCenter] postNotificationName:AFNetworkingTaskDidResumeNotification object:task];
            });
        }
    }
}

//同上
- (void)taskDidSuspend:(NSNotification *)notification {
    NSURLSessionTask *task = notification.object;
    if ([task respondsToSelector:@selector(taskDescription)]) {
        if ([task.taskDescription isEqualToString:self.taskDescriptionForSessionTasks]) {
            dispatch_async(dispatch_get_main_queue(), ^{
                [[NSNotificationCenter defaultCenter] postNotificationName:AFNetworkingTaskDidSuspendNotification object:task];
            });
        }
    }
}

#pragma mark -
//根据task获取相关联的AFURLSessionManagerTaskDelegate对象
- (AFURLSessionManagerTaskDelegate *)delegateForTask:(NSURLSessionTask *)task {
    //task不能为空
    NSParameterAssert(task);
    //上锁，通过task的唯一taskIdentifier从字典中取值，这个唯一标识是在创建task的时候NSURLSessionTask为其设置的，不需要手动设置，保证唯一性
    AFURLSessionManagerTaskDelegate *delegate = nil;
    [self.lock lock];
    delegate = self.mutableTaskDelegatesKeyedByTaskIdentifier[@(task.taskIdentifier)];
    [self.lock unlock];

    return delegate;
}

//为task设置关联的delegate
- (void)setDelegate:(AFURLSessionManagerTaskDelegate *)delegate
            forTask:(NSURLSessionTask *)task
{
    //task和delegate都不能为空
    NSParameterAssert(task);
    NSParameterAssert(delegate);

    //加锁确保中间代码块是原子操作，线程安全
    [self.lock lock];
    //将delegate存入字典，以taskid作为key，说明每个task都有各自的代理
    // task--->delegate
    self.mutableTaskDelegatesKeyedByTaskIdentifier[@(task.taskIdentifier)] = delegate;
    [self addNotificationObserverForTask:task];
    [self.lock unlock];
}

/*
注意addDelegateForDataTask:这个函数并不是AFURLSessionManagerTaskDelegate的函数，而是AFURLSessionManager的一个函数。这也侧面说明了AFURLSessionManagerTaskDelegate和NSURLSessionTask的关系是由AFURLSessionManager管理的。
*/
- (void)addDelegateForDataTask:(NSURLSessionDataTask *)dataTask
                uploadProgress:(nullable void (^)(NSProgress *uploadProgress)) uploadProgressBlock
              downloadProgress:(nullable void (^)(NSProgress *downloadProgress)) downloadProgressBlock
             completionHandler:(void (^)(NSURLResponse *response, id responseObject, NSError *error))completionHandler
{
    // 初始化delegate
    // manager-->session--->task--->delegate-/weak/-->manager
    // delegate--->manager
    // task--->delegate
    AFURLSessionManagerTaskDelegate *delegate = [[AFURLSessionManagerTaskDelegate alloc] initWithTask:dataTask];
    delegate.manager = self;
    delegate.completionHandler = completionHandler;

    /*
    taskidentifier=key delegate=value,确保task唯一
    taskDescription自行设置的，区分是否是当前的session创建的
    */
    dataTask.taskDescription = self.taskDescriptionForSessionTasks;
    //函数字面意思是将一个session task和一个AFURLSessionManagerTaskDelegate类型的delegate变量绑在一起，而这个绑在一起的工作是由我们的AFURLSessionManager所做。至于绑定的过程，就是以该session task的taskIdentifier为key，delegate为value，赋值给mutableTaskDelegatesKeyedByTaskIdentifier这个NSMutableDictionary类型的变量。知道了这两者是关联在一起的话，马上就会产生另外的问题 —— 为什么要关联以及怎么关联在一起？
    [self setDelegate:delegate forTask:dataTask];

    //设置回调块
    // task delegate
    delegate.uploadProgressBlock = uploadProgressBlock;
    delegate.downloadProgressBlock = downloadProgressBlock;
}

- (void)extracted:(AFURLSessionManagerTaskDelegate *)delegate uploadTask:(NSURLSessionUploadTask *)uploadTask {
    [self setDelegate:delegate forTask:uploadTask];
}

//同上，创建上传任务的AFURLSessionManagerTaskDelegate对象，并加入到字典中
- (void)addDelegateForUploadTask:(NSURLSessionUploadTask *)uploadTask
                        progress:(void (^)(NSProgress *uploadProgress)) uploadProgressBlock
               completionHandler:(void (^)(NSURLResponse *response, id responseObject, NSError *error))completionHandler
{
    AFURLSessionManagerTaskDelegate *delegate = [[AFURLSessionManagerTaskDelegate alloc] initWithTask:uploadTask];
    delegate.manager = self;
    delegate.completionHandler = completionHandler;

    uploadTask.taskDescription = self.taskDescriptionForSessionTasks;

    [self extracted:delegate uploadTask:uploadTask];

    delegate.uploadProgressBlock = uploadProgressBlock;
}

//同上，创建下载文件任务的AFURLSessionManagerTaskDelegate对象，并加入到字典中
- (void)addDelegateForDownloadTask:(NSURLSessionDownloadTask *)downloadTask
                          progress:(void (^)(NSProgress *downloadProgress)) downloadProgressBlock
                       destination:(NSURL * (^)(NSURL *targetPath, NSURLResponse *response))destination
                 completionHandler:(void (^)(NSURLResponse *response, NSURL *filePath, NSError *error))completionHandler
{
    AFURLSessionManagerTaskDelegate *delegate = [[AFURLSessionManagerTaskDelegate alloc] initWithTask:downloadTask];
    delegate.manager = self;
    delegate.completionHandler = completionHandler;

    /*
     需要注意下，AFURLSessionManagerTaskDelegate中下载文件完成后会调用delegate.downloadTaskDidFinishDownloading回调块
     来获取下载文件要移动到的目录URL
     所以这里就是创建这个回调块，直接返回参数中的destination回调块
     */
    //返回地址的Block
    if (destination) {
        //有点绕，就是把一个block赋值给我们代理的downloadTaskDidFinishDownloading，这个Block里的内部返回也是调用Block去获取到的，这里面的参数都是AF代理传过去的。
        delegate.downloadTaskDidFinishDownloading = ^NSURL * (NSURLSession * __unused session, NSURLSessionDownloadTask *task, NSURL *location) {
            //把Block返回的地址返回
            return destination(location, task.response);
        };
    }

    downloadTask.taskDescription = self.taskDescriptionForSessionTasks;

    [self setDelegate:delegate forTask:downloadTask];

    delegate.downloadProgressBlock = downloadProgressBlock;
}

//从字典中删除task对应的delegate的key-value对
- (void)removeDelegateForTask:(NSURLSessionTask *)task {
    NSParameterAssert(task);

    [self.lock lock];
    [self removeNotificationObserverForTask:task];
    [self.mutableTaskDelegatesKeyedByTaskIdentifier removeObjectForKey:@(task.taskIdentifier)];
    [self.lock unlock];
}

/*

上面的代码就是对AFURLSessionManagerTaskDelegate的创建、添加进字典、删除、获取的操作，这样就实现了每一个NSURLSessionTask对应一个AFURLSessionManagerTaskDelegate对象，可能读者会有疑问，AFURLSessionManager既然已经实现了代理的方法，为什么不直接使用它来处理代理方法，为什么要创建一个类来专门处理，继续看完源码可能你就会明白了
*/
#pragma mark -
//根据keyPath获取不同类型任务的集合
- (NSArray *)tasksForKeyPath:(NSString *)keyPath {
    __block NSArray *tasks = nil;
    //创建一个信号量，值是0
    dispatch_semaphore_t semaphore = dispatch_semaphore_create(0);
    //这个方法是异步的，所以为了同步返回结果，需要使用锁，信号量值设置为0或者1时就可以当锁来使用了
    [self.session getTasksWithCompletionHandler:^(NSArray *dataTasks, NSArray *uploadTasks, NSArray *downloadTasks) {
        if ([keyPath isEqualToString:NSStringFromSelector(@selector(dataTasks))]) {
            tasks = dataTasks;
        } else if ([keyPath isEqualToString:NSStringFromSelector(@selector(uploadTasks))]) {
            tasks = uploadTasks;
        } else if ([keyPath isEqualToString:NSStringFromSelector(@selector(downloadTasks))]) {
            tasks = downloadTasks;
        } else if ([keyPath isEqualToString:NSStringFromSelector(@selector(tasks))]) {
            tasks = [@[dataTasks, uploadTasks, downloadTasks] valueForKeyPath:@"@unionOfArrays.self"];
        }
        
        //signal通知信号量，信号量值加1
        dispatch_semaphore_signal(semaphore);
    }];

    //等待信号量，直到值大于0，等待时间是forever
    dispatch_semaphore_wait(semaphore, DISPATCH_TIME_FOREVER);

    return tasks;
}

//下面是tasks、dataTasks、uploadTasks、downloadTasks属性的getter，都是调用上述方法来获取对应类型的任务集合
- (NSArray *)tasks {
    return [self tasksForKeyPath:NSStringFromSelector(_cmd)];
}

- (NSArray *)dataTasks {
    return [self tasksForKeyPath:NSStringFromSelector(_cmd)];
}

- (NSArray *)uploadTasks {
    return [self tasksForKeyPath:NSStringFromSelector(_cmd)];
}

- (NSArray *)downloadTasks {
    return [self tasksForKeyPath:NSStringFromSelector(_cmd)];
}

#pragma mark -
//设置session无效，根据参数判断是否需要取消正在执行的任务
- (void)invalidateSessionCancelingTasks:(BOOL)cancelPendingTasks resetSession:(BOOL)resetSession {
    //调用NSURLSession对应的方法来设置session无效，同时打破引用循环
    if (cancelPendingTasks) {
        [self.session invalidateAndCancel];
    } else {
        [self.session finishTasksAndInvalidate];
    }
    if (resetSession) {
        self.session = nil;
    }
}

#pragma mark -

- (void)setResponseSerializer:(id <AFURLResponseSerialization>)responseSerializer {
    NSParameterAssert(responseSerializer);

    _responseSerializer = responseSerializer;
}

#pragma mark -
//当NSURLSessionTask调用resume函数时，会postNotificationName:AFNSURLSessionTaskDidResumeNotification，从而执行taskDidResume:方法
- (void)addNotificationObserverForTask:(NSURLSessionTask *)task {
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(taskDidResume:) name:AFNSURLSessionTaskDidResumeNotification object:task];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(taskDidSuspend:) name:AFNSURLSessionTaskDidSuspendNotification object:task];
}

- (void)removeNotificationObserverForTask:(NSURLSessionTask *)task {
    [[NSNotificationCenter defaultCenter] removeObserver:self name:AFNSURLSessionTaskDidSuspendNotification object:task];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:AFNSURLSessionTaskDidResumeNotification object:task];
}

#pragma mark -
// 这个方法需要的东西是什么呢??--
- (NSURLSessionDataTask *)dataTaskWithRequest:(NSURLRequest *)request
                               uploadProgress:(nullable void (^)(NSProgress *uploadProgress)) uploadProgressBlock
                             downloadProgress:(nullable void (^)(NSProgress *downloadProgress)) downloadProgressBlock
                            completionHandler:(nullable void (^)(NSURLResponse *response, id _Nullable responseObject,  NSError * _Nullable error))completionHandler {
    //使用session来创建一个NSURLSessionDataTask对象
    NSURLSessionDataTask *dataTask = [self.session dataTaskWithRequest:request];
    //为什么要给task添加代理呢？
    [self addDelegateForDataTask:dataTask uploadProgress:uploadProgressBlock downloadProgress:downloadProgressBlock completionHandler:completionHandler];

    return dataTask;
}

#pragma mark -
//创建一个NSURLSessionUploadTask对象
- (NSURLSessionUploadTask *)uploadTaskWithRequest:(NSURLRequest *)request
                                         fromFile:(NSURL *)fileURL
                                         progress:(void (^)(NSProgress *uploadProgress)) uploadProgressBlock
                                completionHandler:(void (^)(NSURLResponse *response, id responseObject, NSError *error))completionHandler
{
    NSURLSessionUploadTask *uploadTask = [self.session uploadTaskWithRequest:request fromFile:fileURL];
    
    if (uploadTask) {
        //创建关联的delegate并添加到字典中
        [self addDelegateForUploadTask:uploadTask
                              progress:uploadProgressBlock
                     completionHandler:completionHandler];
    }

    return uploadTask;
}

- (NSURLSessionUploadTask *)uploadTaskWithRequest:(NSURLRequest *)request
                                         fromData:(NSData *)bodyData
                                         progress:(void (^)(NSProgress *uploadProgress)) uploadProgressBlock
                                completionHandler:(void (^)(NSURLResponse *response, id responseObject, NSError *error))completionHandler
{
    NSURLSessionUploadTask *uploadTask = [self.session uploadTaskWithRequest:request fromData:bodyData];
    
    [self addDelegateForUploadTask:uploadTask progress:uploadProgressBlock completionHandler:completionHandler];

    return uploadTask;
}

- (NSURLSessionUploadTask *)uploadTaskWithStreamedRequest:(NSURLRequest *)request
                                                 progress:(void (^)(NSProgress *uploadProgress)) uploadProgressBlock
                                        completionHandler:(void (^)(NSURLResponse *response, id responseObject, NSError *error))completionHandler
{
    NSURLSessionUploadTask *uploadTask = [self.session uploadTaskWithStreamedRequest:request];

    [self addDelegateForUploadTask:uploadTask progress:uploadProgressBlock completionHandler:completionHandler];

    return uploadTask;
}

#pragma mark -

- (NSURLSessionDownloadTask *)downloadTaskWithRequest:(NSURLRequest *)request
                                             progress:(void (^)(NSProgress *downloadProgress)) downloadProgressBlock
                                          destination:(NSURL * (^)(NSURL *targetPath, NSURLResponse *response))destination
                                    completionHandler:(void (^)(NSURLResponse *response, NSURL *filePath, NSError *error))completionHandler
{
    NSURLSessionDownloadTask *downloadTask = [self.session downloadTaskWithRequest:request];
    
    [self addDelegateForDownloadTask:downloadTask progress:downloadProgressBlock destination:destination completionHandler:completionHandler];

    return downloadTask;
}

- (NSURLSessionDownloadTask *)downloadTaskWithResumeData:(NSData *)resumeData
                                                progress:(void (^)(NSProgress *downloadProgress)) downloadProgressBlock
                                             destination:(NSURL * (^)(NSURL *targetPath, NSURLResponse *response))destination
                                       completionHandler:(void (^)(NSURLResponse *response, NSURL *filePath, NSError *error))completionHandler
{
    NSURLSessionDownloadTask *downloadTask = [self.session downloadTaskWithResumeData:resumeData];

    [self addDelegateForDownloadTask:downloadTask progress:downloadProgressBlock destination:destination completionHandler:completionHandler];

    return downloadTask;
}

/*
上面的方法就是AFURLSessionManager为我们提供的获取NSURLSessionDataTask、NSURLSessionUploadTask和NSURLSessionDownloadTask的方法，上面这些方法主要目的就是传入进度或完成回调块，然后构造一个AFURLSessionManagerTaskDeleagte对象并关联，这样就不需要开发者自行实现和管理代理方法做相关数据处理，只需要在回调块中做处理即可
*/
#pragma mark -
- (NSProgress *)uploadProgressForTask:(NSURLSessionTask *)task {
    return [[self delegateForTask:task] uploadProgress];
}

- (NSProgress *)downloadProgressForTask:(NSURLSessionTask *)task {
    return [[self delegateForTask:task] downloadProgress];
}

#pragma mark -
/*
 方法都是一样的，就不重复粘贴占篇幅了。
 主要谈谈这个设计思路
 
 作者用@property把这个些Block属性在.m文件中声明,然后复写了set方法。
 然后在.h中去声明这些set方法
 
 为什么要绕这么一大圈呢？原来这是为了我们这些用户使用起来方便，调用set方法去设置这些Block，能很清晰的看到Block的各个参数与返回值。大神的精髓的编程思想无处不体现...
 */
//一系列回调块的setter方法
- (void)setSessionDidBecomeInvalidBlock:(void (^)(NSURLSession *session, NSError *error))block {
    self.sessionDidBecomeInvalid = block;
}

- (void)setSessionDidReceiveAuthenticationChallengeBlock:(NSURLSessionAuthChallengeDisposition (^)(NSURLSession *session, NSURLAuthenticationChallenge *challenge, NSURLCredential * __autoreleasing *credential))block {
    self.sessionDidReceiveAuthenticationChallenge = block;
}

#if !TARGET_OS_OSX
- (void)setDidFinishEventsForBackgroundURLSessionBlock:(void (^)(NSURLSession *session))block {
    self.didFinishEventsForBackgroundURLSession = block;
}
#endif

#pragma mark -

- (void)setTaskNeedNewBodyStreamBlock:(NSInputStream * (^)(NSURLSession *session, NSURLSessionTask *task))block {
    self.taskNeedNewBodyStream = block;
}

- (void)setTaskWillPerformHTTPRedirectionBlock:(NSURLRequest * (^)(NSURLSession *session, NSURLSessionTask *task, NSURLResponse *response, NSURLRequest *request))block {
    self.taskWillPerformHTTPRedirection = block;
}

- (void)setTaskDidSendBodyDataBlock:(void (^)(NSURLSession *session, NSURLSessionTask *task, int64_t bytesSent, int64_t totalBytesSent, int64_t totalBytesExpectedToSend))block {
    self.taskDidSendBodyData = block;
}

- (void)setTaskDidCompleteBlock:(void (^)(NSURLSession *session, NSURLSessionTask *task, NSError *error))block {
    self.taskDidComplete = block;
}

#if AF_CAN_INCLUDE_SESSION_TASK_METRICS
- (void)setTaskDidFinishCollectingMetricsBlock:(void (^)(NSURLSession * _Nonnull, NSURLSessionTask * _Nonnull, NSURLSessionTaskMetrics * _Nullable))block AF_API_AVAILABLE(ios(10), macosx(10.12), watchos(3), tvos(10)) {
    self.taskDidFinishCollectingMetrics = block;
}
#endif

#pragma mark -

- (void)setDataTaskDidReceiveResponseBlock:(NSURLSessionResponseDisposition (^)(NSURLSession *session, NSURLSessionDataTask *dataTask, NSURLResponse *response))block {
    self.dataTaskDidReceiveResponse = block;
}

- (void)setDataTaskDidBecomeDownloadTaskBlock:(void (^)(NSURLSession *session, NSURLSessionDataTask *dataTask, NSURLSessionDownloadTask *downloadTask))block {
    self.dataTaskDidBecomeDownloadTask = block;
}

- (void)setDataTaskDidReceiveDataBlock:(void (^)(NSURLSession *session, NSURLSessionDataTask *dataTask, NSData *data))block {
    self.dataTaskDidReceiveData = block;
}

- (void)setDataTaskWillCacheResponseBlock:(NSCachedURLResponse * (^)(NSURLSession *session, NSURLSessionDataTask *dataTask, NSCachedURLResponse *proposedResponse))block {
    self.dataTaskWillCacheResponse = block;
}

#pragma mark -

- (void)setDownloadTaskDidFinishDownloadingBlock:(NSURL * (^)(NSURLSession *session, NSURLSessionDownloadTask *downloadTask, NSURL *location))block {
    self.downloadTaskDidFinishDownloading = block;
}

- (void)setDownloadTaskDidWriteDataBlock:(void (^)(NSURLSession *session, NSURLSessionDownloadTask *downloadTask, int64_t bytesWritten, int64_t totalBytesWritten, int64_t totalBytesExpectedToWrite))block {
    self.downloadTaskDidWriteData = block;
}

- (void)setDownloadTaskDidResumeBlock:(void (^)(NSURLSession *session, NSURLSessionDownloadTask *downloadTask, int64_t fileOffset, int64_t expectedTotalBytes))block {
    self.downloadTaskDidResume = block;
}

#pragma mark - NSObject

- (NSString *)description {
    return [NSString stringWithFormat:@"<%@: %p, session: %@, operationQueue: %@>", NSStringFromClass([self class]), self, self.session, self.operationQueue];
}

/*
 这样如果没实现这些我们自定义的Block也不会去回调这些代理。因为本身某些代理，只执行了这些自定义的Block，如果Block都没有赋值，那我们调用代理也没有任何意义
 */
//复写了selector的方法，这几个方法是在本类有实现的，但是如果外面的Block没赋值的话，则返回NO，相当于没有实现！
- (BOOL)respondsToSelector:(SEL)selector {
    if (selector == @selector(URLSession:didReceiveChallenge:completionHandler:)) {
        return self.sessionDidReceiveAuthenticationChallenge != nil;
    } else if (selector == @selector(URLSession:task:willPerformHTTPRedirection:newRequest:completionHandler:)) {
        return self.taskWillPerformHTTPRedirection != nil;
    } else if (selector == @selector(URLSession:dataTask:didReceiveResponse:completionHandler:)) {
        return self.dataTaskDidReceiveResponse != nil;
    } else if (selector == @selector(URLSession:dataTask:willCacheResponse:completionHandler:)) {
        return self.dataTaskWillCacheResponse != nil;
    }
#if !TARGET_OS_OSX
    else if (selector == @selector(URLSessionDidFinishEventsForBackgroundURLSession:)) {
        return self.didFinishEventsForBackgroundURLSession != nil;
    }
#endif

    return [[self class] instancesRespondToSelector:selector];
}

#pragma mark - NSURLSessionDelegate
/*
当前session失效，会调用
如果你使用finishTasksAndInvalidate函数使该session失效，
那么session首先会先完成最后一个task，然后再调用URLSession:didBecomeInvalidWithError:代理方法，
如果你调用invalidateAndCancel方法来使session失效，那么该session会立即调用这个代理方法。


*/
- (void)URLSession:(NSURLSession *)session
didBecomeInvalidWithError:(NSError *)error
{
    if (self.sessionDidBecomeInvalid) {
        self.sessionDidBecomeInvalid(session, error);
    }

    // 不过源代码中没有举例如何使用这个Notification，所以需要用户自己定义，比如结束进度条的显示啊
    [[NSNotificationCenter defaultCenter] postNotificationName:AFURLSessionDidInvalidateNotification object:session];
}

//HTTPS认证
/*
 
 该代理方法会在下面两种情况调用：
 当服务器端要求客户端提供证书时或者进行NTLM认证（Windows NT LAN Manager，微软提出的WindowsNT挑战/响应验证机制）时，此方法允许你的app提供正确的挑战证书。
 当某个session使用SSL/TLS协议，第一次和服务器端建立连接的时候，服务器会发送给iOS客户端一个证书，此方法允许你的app验证服务期端的证书链（certificate keychain）
 注：如果你没有实现该方法，该session会调用其NSURLSessionTaskDelegate的代理方法URLSession:task:didReceiveChallenge:completionHandler: 。
 这里，我把官方文档对这个方法的描述翻译了一下。
 总结一下，这个方法其实就是做https认证的。看看上面的注释，大概能看明白这个方法做认证的步骤，我们还是如果有自定义的做认证的Block，则调用我们自定义的，否则去执行默认的认证步骤，最后调用完成认证
 
服务端发起的一个验证挑战,客户端需要根据挑战的类型提供相应的挑战凭证。当然,挑战凭证不一定都是进行HTTPS证书的信任,也可能是需要客户端提供用户密码或者提供双向验证时的客户端证书。当这个挑战凭证被验证通过时,请求便可以继续顺利进行
 */
//收到服务端的challenge，例如https需要验证证书等 ats开启
- (void)URLSession:(NSURLSession *)session
didReceiveChallenge:(NSURLAuthenticationChallenge *)challenge
 completionHandler:(void (^)(NSURLSessionAuthChallengeDisposition disposition, NSURLCredential *credential))completionHandler
{
    NSAssert(self.sessionDidReceiveAuthenticationChallenge != nil, @"`respondsToSelector:` implementation forces `URLSession:didReceiveChallenge:completionHandler:` to be called only if `self.sessionDidReceiveAuthenticationChallenge` is not nil");

    NSURLCredential *credential = nil;//证书
    //挑战处理类型为 默认
    /*
     NSURLSessionAuthChallengeUseCredential：使用指定的证书
     NSURLSessionAuthChallengePerformDefaultHandling：默认方式处理
     NSURLSessionAuthChallengeCancelAuthenticationChallenge：取消挑战
     NSURLSessionAuthChallengeRejectProtectionSpace:拒绝此挑战，并尝试下一个验证保护空间；忽略证书参数
     */

    // 自定义方法，用来如何应对服务器端的认证挑战
    NSURLSessionAuthChallengeDisposition disposition = self.sessionDidReceiveAuthenticationChallenge(session, challenge, &credential);
    // 将信任凭证发送给服务端
    if (completionHandler) {
        completionHandler(disposition, credential);
    }
}

#pragma mark - NSURLSessionTaskDelegate
//客户端告知服务器端需要HTTP重定向
//此方法只会在default session或者ephemeral session中调用，而在background session中，session task会自动重定向
- (void)URLSession:(NSURLSession *)session
              task:(NSURLSessionTask *)task
willPerformHTTPRedirection:(NSHTTPURLResponse *)response
        newRequest:(NSURLRequest *)request
 completionHandler:(void (^)(NSURLRequest *))completionHandler
{
    NSURLRequest *redirectRequest = request;

    // 自定义如何处理重定向请求，注意会生成一个新的request
    if (self.taskWillPerformHTTPRedirection) {
        redirectRequest = self.taskWillPerformHTTPRedirection(session, task, response, request);
    }

    if (completionHandler) {
        completionHandler(redirectRequest);
    }
}

/*
该方法是处理task-level的认证挑战。在NSURLSessionDelegate中提供了一个session-level的认证挑战代理方法。该方法的调用取决于认证挑战的类型：

对于session-level的认证挑战，挑战类型有 — NSURLAuthenticationMethodNTLM, NSURLAuthenticationMethodNegotiate, NSURLAuthenticationMethodClientCertificate, 或NSURLAuthenticationMethodServerTrust — 此时session会调用其代理方法URLSession:didReceiveChallenge:completionHandler:。如果你的app没有提供对应的NSURLSessionDelegate方法，那么NSURLSession对象就会调用URLSession:task:didReceiveChallenge:completionHandler:来处理认证挑战。
对于non-session-level的认证挑战，NSURLSession对象调用URLSession:task:didReceiveChallenge:completionHandler:来处理认证挑战。如果你在app中使用了session代理方法，而且也确实要处理认证挑战这个问题，那么你必须还是在task level来处理这个问题，或者提供一个task-level的handler来显式调用每个session的handler。而对于non-session-level的认证挑战，session的delegate中的URLSession:didReceiveChallenge:completionHandler:方法不会被调用。
*/
- (void)URLSession:(NSURLSession *)session
              task:(NSURLSessionTask *)task
didReceiveChallenge:(NSURLAuthenticationChallenge *)challenge
 completionHandler:(void (^)(NSURLSessionAuthChallengeDisposition disposition, NSURLCredential *credential))completionHandler
{
    BOOL evaluateServerTrust = NO;
    NSURLSessionAuthChallengeDisposition disposition = NSURLSessionAuthChallengePerformDefaultHandling;
    NSURLCredential *credential = nil;

    if (self.authenticationChallengeHandler) {
        id result = self.authenticationChallengeHandler(session, task, challenge, completionHandler);
        if (result == nil) {
            return;
        } else if ([result isKindOfClass:NSError.class]) {
            objc_setAssociatedObject(task, AuthenticationChallengeErrorKey, result, OBJC_ASSOCIATION_RETAIN);
            disposition = NSURLSessionAuthChallengeCancelAuthenticationChallenge;
        } else if ([result isKindOfClass:NSURLCredential.class]) {
            credential = result;
            disposition = NSURLSessionAuthChallengeUseCredential;
        } else if ([result isKindOfClass:NSNumber.class]) {
            disposition = [result integerValue];
            NSAssert(disposition == NSURLSessionAuthChallengePerformDefaultHandling || disposition == NSURLSessionAuthChallengeCancelAuthenticationChallenge || disposition == NSURLSessionAuthChallengeRejectProtectionSpace, @"");
            evaluateServerTrust = disposition == NSURLSessionAuthChallengePerformDefaultHandling && [challenge.protectionSpace.authenticationMethod isEqualToString:NSURLAuthenticationMethodServerTrust];
        } else {
            @throw [NSException exceptionWithName:@"Invalid Return Value" reason:@"The return value from the authentication challenge handler must be nil, an NSError, an NSURLCredential or an NSNumber." userInfo:nil];
        }
    } else {
        evaluateServerTrust = [challenge.protectionSpace.authenticationMethod isEqualToString:NSURLAuthenticationMethodServerTrust];
    }

    if (evaluateServerTrust) {
        if ([self.securityPolicy evaluateServerTrust:challenge.protectionSpace.serverTrust forDomain:challenge.protectionSpace.host]) {
            disposition = NSURLSessionAuthChallengeUseCredential;
            credential = [NSURLCredential credentialForTrust:challenge.protectionSpace.serverTrust];
        } else {
            objc_setAssociatedObject(task, AuthenticationChallengeErrorKey,
                                     [self serverTrustErrorForServerTrust:challenge.protectionSpace.serverTrust url:task.currentRequest.URL],
                                     OBJC_ASSOCIATION_RETAIN);
            disposition = NSURLSessionAuthChallengeCancelAuthenticationChallenge;
        }
    }

    if (completionHandler) {
        completionHandler(disposition, credential);
    }
}

- (nonnull NSError *)serverTrustErrorForServerTrust:(nullable SecTrustRef)serverTrust url:(nullable NSURL *)url
{
    NSBundle *CFNetworkBundle = [NSBundle bundleWithIdentifier:@"com.apple.CFNetwork"];
    NSString *defaultValue = @"The certificate for this server is invalid. You might be connecting to a server that is pretending to be “%@” which could put your confidential information at risk.";
    NSString *descriptionFormat = NSLocalizedStringWithDefaultValue(@"Err-1202.w", nil, CFNetworkBundle, defaultValue, @"") ?: defaultValue;
    NSString *localizedDescription = [descriptionFormat componentsSeparatedByString:@"%@"].count <= 2 ? [NSString localizedStringWithFormat:descriptionFormat, url.host] : descriptionFormat;
    NSMutableDictionary *userInfo = [@{
        NSLocalizedDescriptionKey: localizedDescription
    } mutableCopy];

    if (serverTrust) {
        userInfo[NSURLErrorFailingURLPeerTrustErrorKey] = (__bridge id)serverTrust;
    }

    if (url) {
        userInfo[NSURLErrorFailingURLErrorKey] = url;

        if (url.absoluteString) {
            userInfo[NSURLErrorFailingURLStringErrorKey] = url.absoluteString;
        }
    }

    return [NSError errorWithDomain:NSURLErrorDomain code:NSURLErrorServerCertificateUntrusted userInfo:userInfo];
}

//当一个session task需要发送一个新的request body stream到服务器端的时候，调用该代理方法
/*
 该代理方法会在下面两种情况被调用：
 
 如果task是由uploadTaskWithStreamedRequest:创建的，那么提供初始的request body stream时候会调用该代理方法。
 因为认证挑战或者其他可恢复的服务器错误，而导致需要客户端重新发送一个含有body stream的request，这时候会调用该代理。
 */
- (void)URLSession:(NSURLSession *)session
              task:(NSURLSessionTask *)task
 needNewBodyStream:(void (^)(NSInputStream *bodyStream))completionHandler
{
    NSInputStream *inputStream = nil;

    if (self.taskNeedNewBodyStream) {
        // 自定义的获取到新的bodyStream方法
        inputStream = self.taskNeedNewBodyStream(session, task);
    } else if (task.originalRequest.HTTPBodyStream && [task.originalRequest.HTTPBodyStream conformsToProtocol:@protocol(NSCopying)]) {
        // 拷贝一份数据出来到新的bodyStream中（即inputStream）
        inputStream = [task.originalRequest.HTTPBodyStream copy];
    }

    if (completionHandler) {
        completionHandler(inputStream);
    }
}
//上传任务的回调方法
//周期性地通知代理发送到服务器端数据的进度
- (void)URLSession:(NSURLSession *)session
              task:(NSURLSessionTask *)task
   didSendBodyData:(int64_t)bytesSent
    totalBytesSent:(int64_t)totalBytesSent
totalBytesExpectedToSend:(int64_t)totalBytesExpectedToSend
{
    // 如果totalUnitCount获取失败，就使用HTTP header中的Content-Length作为totalUnitCount
    int64_t totalUnitCount = totalBytesExpectedToSend;
    if (totalUnitCount == NSURLSessionTransferSizeUnknown) {
        NSString *contentLength = [task.originalRequest valueForHTTPHeaderField:@"Content-Length"];
        if (contentLength) {
            totalUnitCount = (int64_t) [contentLength longLongValue];
        }
    }
    
    AFURLSessionManagerTaskDelegate *delegate = [self delegateForTask:task];
    
    if (delegate) {
        [delegate URLSession:session task:task didSendBodyData:bytesSent totalBytesSent:totalBytesSent totalBytesExpectedToSend:totalBytesExpectedToSend];
    }
    // 每次发送数据后的相关自定义处理，比如根据totalBytesSent来进行UI界面的数据上传显示
    if (self.taskDidSendBodyData) {
        self.taskDidSendBodyData(session, task, bytesSent, totalBytesSent, totalUnitCount);
    }
}
/*
 task完成之后的回调，成功和失败都会回调这里
 函数讨论：
 注意这里的error不会报告服务期端的error，他表示的是客户端这边的error，比如无法解析hostname或者连不上host主机。
 */
- (void)URLSession:(NSURLSession *)session
              task:(NSURLSessionTask *)task
didCompleteWithError:(NSError *)error
{
    AFURLSessionManagerTaskDelegate *delegate = [self delegateForTask:task];

    // delegate may be nil when completing a task in the background
    // 如果task是在后台完成的，可能delegate会为nil
    if (delegate) {
        [delegate URLSession:session task:task didCompleteWithError:error];
        // 该task结束了，就移除对应的delegate
        [self removeDelegateForTask:task];
    }
    //自定义Block回调
    if (self.taskDidComplete) {
        self.taskDidComplete(session, task, error);
    }
}

#if AF_CAN_INCLUDE_SESSION_TASK_METRICS
- (void)URLSession:(NSURLSession *)session
              task:(NSURLSessionTask *)task
didFinishCollectingMetrics:(NSURLSessionTaskMetrics *)metrics AF_API_AVAILABLE(ios(10), macosx(10.12), watchos(3), tvos(10))
{
    AFURLSessionManagerTaskDelegate *delegate = [self delegateForTask:task];
    // Metrics may fire after URLSession:task:didCompleteWithError: is called, delegate may be nil
    if (delegate) {
        [delegate URLSession:session task:task didFinishCollectingMetrics:metrics];
    }

    if (self.taskDidFinishCollectingMetrics) {
        self.taskDidFinishCollectingMetrics(session, task, metrics);
    }
}
#endif
/*
 以上代码是NSURLSessionTaskDelegate的回调方法，通过上面的代码可以发现AFURLSessionManagerTaskDelegate的作用了，AFURLSessionManager的代理方法中会根据task获取到对应的delegate，如果需要提前处理一些数据就先处理，处理完成后手动触发delegate中的对应方法，然后具体的数据处理就交由AFURLSessionManagerTaskDelegate来处理
 */
#pragma mark - NSURLSessionDataDelegate
/*
 告诉代理，该data task获取到了服务器端传回的最初始回复（response）。注意其中的completionHandler这个block，通过传入一个类型为NSURLSessionResponseDisposition的变量来决定该传输任务接下来该做什么：
 
 NSURLSessionResponseAllow 该task正常进行
 NSURLSessionResponseCancel 该task会被取消
 NSURLSessionResponseBecomeDownload 会调用URLSession:dataTask:didBecomeDownloadTask:方法来新建一个download task以代替当前的data task
 该方法是可选的，除非你必须支持“multipart/x-mixed-replace”类型的content-type。因为如果你的request中包含了这种类型的content-type，服务器会将数据分片传回来，而且每次传回来的数据会覆盖之前的数据。每次返回新的数据时，session都会调用该函数，你应该在这个函数中合理地处理先前的数据，否则会被新数据覆盖。如果你没有提供该方法的实现，那么session将会继续任务，也就是说会覆盖之前的数据。
 */
- (void)URLSession:(NSURLSession *)session
          dataTask:(NSURLSessionDataTask *)dataTask
didReceiveResponse:(NSURLResponse *)response
 completionHandler:(void (^)(NSURLSessionResponseDisposition disposition))completionHandler
{
    //设置默认为继续进行
    NSURLSessionResponseDisposition disposition = NSURLSessionResponseAllow;
    //自定义去设置
    if (self.dataTaskDidReceiveResponse) {
        disposition = self.dataTaskDidReceiveResponse(session, dataTask, response);
    }

    if (completionHandler) {
        completionHandler(disposition);
    }
}
//上面的代理如果设置为NSURLSessionResponseBecomeDownload，则会调用这个方法
//比如在- URLSession:dataTask:didReceiveResponse:completionHandler:给completionHandler方法传递NSURLSessionResponseBecomeDownload，就会使data task变成download task。而且之前的data task不会再响应代理方法了
- (void)URLSession:(NSURLSession *)session
          dataTask:(NSURLSessionDataTask *)dataTask
didBecomeDownloadTask:(NSURLSessionDownloadTask *)downloadTask
{
    AFURLSessionManagerTaskDelegate *delegate = [self delegateForTask:dataTask];
    if (delegate) {
        // 将delegate关联的data task移除，换成新产生的download task
        [self removeDelegateForTask:dataTask];
        [self setDelegate:delegate forTask:downloadTask];
    }
    //执行自定义Block
    if (self.dataTaskDidBecomeDownloadTask) {
        self.dataTaskDidBecomeDownloadTask(session, dataTask, downloadTask);
    }
}
//当接收到部分期望得到的数据（expected data）时，会调用该代理方法
/*一个NSData类型的数据通常是由一系列不同的数据整合到一起得到的，不管是不是这样，请使用- enumerateByteRangesUsingBlock:来遍历数据然不是使用bytes方法（因为bytes缺少enumerateByteRangesUsingBlock方法中的range，有了range，enumerateByteRangesUsingBlock就可以对NSData不同的数据块进行遍历，而不像bytes把所有NSData看成一个数据块）。
 
 该代理方法可能会调用多次（比如分片获取数据），你需要自己实现函数将所有数据整合在一起。
 */
- (void)URLSession:(NSURLSession *)session
          dataTask:(NSURLSessionDataTask *)dataTask
    didReceiveData:(NSData *)data
{
    // 调用的是AFURLSessionManagerTaskDelegate的didReceiveData方法
    AFURLSessionManagerTaskDelegate *delegate = [self delegateForTask:dataTask];
    [delegate URLSession:session dataTask:dataTask didReceiveData:data];

    if (self.dataTaskDidReceiveData) {
        self.dataTaskDidReceiveData(session, dataTask, data);
    }
}
//询问data task或上传任务（upload task）是否缓存response。
/*
 当task接收到所有期望的数据后，session会调用此代理方法。如果你没有实现该方法，那么就会使用创建session时使用的configuration对象决定缓存策略。这个代理方法最初的目的是为了阻止缓存特定的URLs或者修改NSCacheURLResponse对象相关的userInfo字典。
 
 该方法只会当request决定缓存response时候调用。作为准则，responses只会当以下条件都成立的时候返回缓存：
 
 该request是HTTP或HTTPS URL的请求（或者你自定义的网络协议，并且确保该协议支持缓存）
 确保request请求是成功的（返回的status code为200-299）
 返回的response是来自服务器端的，而非缓存中本身就有的
 提供的NSURLRequest对象的缓存策略要允许进行缓存
 服务器返回的response中与缓存相关的header要允许缓存
 该response的大小不能比提供的缓存空间大太多（比如你提供了一个磁盘缓存，那么response大小一定不能比磁盘缓存空间还要大5%）
 */
- (void)URLSession:(NSURLSession *)session
          dataTask:(NSURLSessionDataTask *)dataTask
 willCacheResponse:(NSCachedURLResponse *)proposedResponse
 completionHandler:(void (^)(NSCachedURLResponse *cachedResponse))completionHandler
{
    NSCachedURLResponse *cachedResponse = proposedResponse;
    // 自定义方法，你可以什么都不做，返回原始的cachedResponse，或者使用修改后的cachedResponse
    // 当然，你也可以返回NULL，这就意味着不需要缓存Response
    if (self.dataTaskWillCacheResponse) {
        cachedResponse = self.dataTaskWillCacheResponse(session, dataTask, proposedResponse);
    }

    if (completionHandler) {
        completionHandler(cachedResponse);
    }
}

#if !TARGET_OS_OSX
//当session中所有已经入队的消息被发送出去后，会调用该代理方法。
/*
 在iOS中，当一个后台传输任务完成或者后台传输时需要证书，而此时你的app正在后台挂起，那么你的app在后台会自动重新启动运行，并且这个app的UIApplicationDelegate会发送一个application:handleEventsForBackgroundURLSession:completionHandler:消息。该消息包含了对应后台的session的identifier，而且这个消息会导致你的app启动。你的app随后应该先存储completion handler，然后再使用相同的identifier创建一个background configuration，并根据这个background configuration创建一个新的session。这个新创建的session会自动与后台任务重新关联在一起。
 
 当你的app获取了一个URLSessionDidFinishEventsForBackgroundURLSession:消息，这就意味着之前这个session中已经入队的所有消息都转发出去了，这时候再调用先前存取的completion handler是安全的，或者因为内部更新而导致调用completion handler也是安全的
 */
- (void)URLSessionDidFinishEventsForBackgroundURLSession:(NSURLSession *)session {
    if (self.didFinishEventsForBackgroundURLSession) {
        dispatch_async(dispatch_get_main_queue(), ^{
            // 意味着background session中的消息已经全部发送出去了，返回到主进程执行自定义的函数
            self.didFinishEventsForBackgroundURLSession(session);
        });
    }
}
#endif
/*
 上面的代码是NSURLSessionDataDelegate的代理方法，同样的，如果AFURLSessionManagerTaskDelegate能响应的关于数据处理的方法都会通过task找到对应delegate后调用其对应的方法，然后执行用户自定义的回调块，如果代理不能响应的方法就由AFURLSessionManager自行处理
 */
#pragma mark - NSURLSessionDownloadDelegate
//下载完成的时候调用(必须实现)
- (void)URLSession:(NSURLSession *)session
      downloadTask:(NSURLSessionDownloadTask *)downloadTask
didFinishDownloadingToURL:(NSURL *)location
{
    AFURLSessionManagerTaskDelegate *delegate = [self delegateForTask:downloadTask];
    //这个是session的，也就是全局的，后面的个人代理也会做同样的这件事
    if (self.downloadTaskDidFinishDownloading) {
        // 自定义函数，根据从服务器端获取到的数据临时地址location等参数构建出你想要将临时文件移动的位置
        NSURL *fileURL = self.downloadTaskDidFinishDownloading(session, downloadTask, location);
        if (fileURL) {
            // 如果fileURL存在的话，表示用户希望把临时数据存起来
            delegate.downloadFileURL = fileURL;
            NSError *error = nil;
            // 将位于location位置的文件全部移到fileURL位置
            if (![[NSFileManager defaultManager] moveItemAtURL:location toURL:fileURL error:&error]) {
                // 如果移动文件失败，就发送AFURLSessionDownloadTaskDidFailToMoveFileNotification
                [[NSNotificationCenter defaultCenter] postNotificationName:AFURLSessionDownloadTaskDidFailToMoveFileNotification object:downloadTask userInfo:error.userInfo];
            } else {
                [[NSNotificationCenter defaultCenter] postNotificationName:AFURLSessionDownloadTaskDidMoveFileSuccessfullyNotification object:downloadTask userInfo:nil];
            }

            return;
        }
    }
    // 这一步比较诡异，感觉有重复的嫌疑。或许是为了兼容以前代码吧
    if (delegate) {
        [delegate URLSession:session downloadTask:downloadTask didFinishDownloadingToURL:location];
    }
}
//周期性地通知下载进度调用
// bytesWritten 表示自上次调用该方法后，接收到的数据字节数
// totalBytesWritten 表示目前已经接收到的数据字节数
// totalBytesExpectedToWrite 表示期望收到的文件总字节数，是由Content-Length header提供。如果没有提供，默认是NSURLSessionTransferSizeUnknown
- (void)URLSession:(NSURLSession *)session
      downloadTask:(NSURLSessionDownloadTask *)downloadTask
      didWriteData:(int64_t)bytesWritten
 totalBytesWritten:(int64_t)totalBytesWritten
totalBytesExpectedToWrite:(int64_t)totalBytesExpectedToWrite
{
    
    AFURLSessionManagerTaskDelegate *delegate = [self delegateForTask:downloadTask];
    
    if (delegate) {
        [delegate URLSession:session downloadTask:downloadTask didWriteData:bytesWritten totalBytesWritten:totalBytesWritten totalBytesExpectedToWrite:totalBytesExpectedToWrite];
    }

    if (self.downloadTaskDidWriteData) {
        self.downloadTaskDidWriteData(session, downloadTask, bytesWritten, totalBytesWritten, totalBytesExpectedToWrite);
    }
}
//告诉代理，下载任务重新开始下载了
/*
 如果一个resumable（不是很会翻译）下载任务被取消或者失败了，你可以请求一个resumeData对象（比如在userInfo字典中通过NSURLSessionDownloadTaskResumeData这个键来获取到resumeData）并使用它来提供足够的信息以重新开始下载任务。随后，你可以使用resumeData作为downloadTaskWithResumeData:或downloadTaskWithResumeData:completionHandler:的参数。
 
 当你调用这些方法时，你将开始一个新的下载任务。一旦你继续下载任务，session会调用它的代理方法URLSession:downloadTask:didResumeAtOffset:expectedTotalBytes:其中的downloadTask参数表示的就是新的下载任务，这也意味着下载重新开始了
 
 // fileOffset如果文件缓存策略或者最后文件更新日期阻止重用已经存在的文件内容，那么该值为0。
 // 否则，该值表示已经存在磁盘上的，不需要重新获取的数据——— 这是断点续传啊！
 */
- (void)URLSession:(NSURLSession *)session
      downloadTask:(NSURLSessionDownloadTask *)downloadTask
 didResumeAtOffset:(int64_t)fileOffset
expectedTotalBytes:(int64_t)expectedTotalBytes
{
    
    AFURLSessionManagerTaskDelegate *delegate = [self delegateForTask:downloadTask];
    
    if (delegate) {
        [delegate URLSession:session downloadTask:downloadTask didResumeAtOffset:fileOffset expectedTotalBytes:expectedTotalBytes];
    }

    if (self.downloadTaskDidResume) {
        self.downloadTaskDidResume(session, downloadTask, fileOffset, expectedTotalBytes);
    }
}

#pragma mark - NSSecureCoding

+ (BOOL)supportsSecureCoding {
    return YES;
}

- (instancetype)initWithCoder:(NSCoder *)decoder {
    NSURLSessionConfiguration *configuration = [decoder decodeObjectOfClass:[NSURLSessionConfiguration class] forKey:@"sessionConfiguration"];

    self = [self initWithSessionConfiguration:configuration];
    if (!self) {
        return nil;
    }

    return self;
}

- (void)encodeWithCoder:(NSCoder *)coder {
    [coder encodeObject:self.session.configuration forKey:@"sessionConfiguration"];
}

#pragma mark - NSCopying

- (instancetype)copyWithZone:(NSZone *)zone {
    return [[[self class] allocWithZone:zone] initWithSessionConfiguration:self.session.configuration];
}
/*
 总结：这里securityPolicy存在的作用就是，使得在系统底层自己去验证之前，AF可以先去验证服务端的证书。如果通不过，则直接越过系统的验证，取消https的网络请求。否则，继续去走系统根证书的验证。
 系统验证的流程：
 系统的验证，首先是去系统的根证书找，看是否有能匹配服务端的证书，如果匹配，则验证成功，返回https的安全数据。
 如果不匹配则去判断ATS是否关闭，如果关闭，则返回https不安全连接的数据。如果开启ATS，则拒绝这个请求，请求失败。
 AF的验证方式不是必须的，但是对有特殊验证需求的用户确是必要的
 
 */
@end
