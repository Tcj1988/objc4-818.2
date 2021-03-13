// AFURLSessionManager.h
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


#import <Foundation/Foundation.h>

#import "AFURLResponseSerialization.h"
#import "AFURLRequestSerialization.h"
#import "AFSecurityPolicy.h"
#import "AFCompatibilityMacros.h"
#if !TARGET_OS_WATCH
#import "AFNetworkReachabilityManager.h"
#endif

/**
 `AFURLSessionManager` creates and manages an `NSURLSession` object based on a specified `NSURLSessionConfiguration` object, which conforms to `<NSURLSessionTaskDelegate>`, `<NSURLSessionDataDelegate>`, `<NSURLSessionDownloadDelegate>`, and `<NSURLSessionDelegate>`.
 
 ===========
 AFURLSessionManager创建并且管理这一个基于`NSURLSessionConfiguration`创建的`NSURLSession`对象，并且遵循`<NSURLSessionTaskDelegate>`, `<NSURLSessionDataDelegate>`, `<NSURLSessionDownloadDelegate>`, and `<NSURLSessionDelegate>`
 所有的urlsession的代理必须继承或者实现
 ============

 ## Subclassing Notes

 This is the base class for `AFHTTPSessionManager`, which adds functionality specific to making HTTP requests. If you are looking to extend `AFURLSessionManager` specifically for HTTP, consider subclassing `AFHTTPSessionManager` instead.

 ============
 这是AFHTTPSessionManager的父类，为发送HTTP请求而增加了具体的功能。如果你打算扩展HTTP 来做HTTP相关的功能，可以直接使用AFHTTPSessionManager
 ============
 
 ## NSURLSession & NSURLSessionTask Delegate Methods

 `AFURLSessionManager` implements the following delegate methods:
 
 ============
  AFURLSessionManager 实现了以下的代理方法
 ============

 ### `NSURLSessionDelegate`

 - `URLSession:didBecomeInvalidWithError:`
 - `URLSession:didReceiveChallenge:completionHandler:`
 - `URLSessionDidFinishEventsForBackgroundURLSession:`

 ### `NSURLSessionTaskDelegate`

 - `URLSession:willPerformHTTPRedirection:newRequest:completionHandler:`
 - `URLSession:task:didReceiveChallenge:completionHandler:`
 - `URLSession:task:didSendBodyData:totalBytesSent:totalBytesExpectedToSend:`
 - `URLSession:task:needNewBodyStream:`
 - `URLSession:task:didCompleteWithError:`

 ### `NSURLSessionDataDelegate`

 - `URLSession:dataTask:didReceiveResponse:completionHandler:`
 - `URLSession:dataTask:didBecomeDownloadTask:`
 - `URLSession:dataTask:didReceiveData:`
 - `URLSession:dataTask:willCacheResponse:completionHandler:`

 ### `NSURLSessionDownloadDelegate`

 - `URLSession:downloadTask:didFinishDownloadingToURL:`
 - `URLSession:downloadTask:didWriteData:totalBytesWritten:totalBytesExpectedToWrite:`
 - `URLSession:downloadTask:didResumeAtOffset:expectedTotalBytes:`

 If any of these methods are overridden in a subclass, they _must_ call the `super` implementation first.
 
 ============
如果要在子类中重写这些方法，那必须先调用父类的实现（否则你会漏掉afn作者在父类中的一些处理）
 ============

 ## Network Reachability Monitoring

 Network reachability status and change monitoring is available through the `reachabilityManager` property. Applications may choose to monitor network reachability conditions in order to prevent or suspend any outbound requests. See `AFNetworkReachabilityManager` for more details.

 ## NSCoding Caveats

 - Encoded managers do not include any block properties. Be sure to set delegate callback blocks when using `-initWithCoder:` or `NSKeyedUnarchiver`.

 ## NSCopying Caveats

 - `-copy` and `-copyWithZone:` return a new manager with a new `NSURLSession` created from the configuration of the original.
 - Operation copies do not include any delegate callback blocks, as they often strongly captures a reference to `self`, which would otherwise have the unintuitive side-effect of pointing to the _original_ session manager when copied.

 @warning Managers for background sessions must be owned for the duration of their use. This can be accomplished by creating an application-wide or shared singleton instance.
 */

NS_ASSUME_NONNULL_BEGIN
// 遵循了NSURLSession的各个协议 只要设置了一个代理，就会一起设置这四个代理。 而最终会根据task的类型来触发哪种代理
@interface AFURLSessionManager : NSObject <NSURLSessionDelegate, NSURLSessionTaskDelegate, NSURLSessionDataDelegate, NSURLSessionDownloadDelegate, NSSecureCoding, NSCopying>

/**
 The managed session.
 */
// NSURLSession 作为一个实例变量，AFN发起的网络请求都是通过该session创建的task实现的
@property (readonly, nonatomic, strong) NSURLSession *session;

/**
 The operation queue on which delegate callbacks are run.
 */
// 为session绑定的代理回调所使用的队列 默认最大并发数为1
@property (readonly, nonatomic, strong) NSOperationQueue *operationQueue;

/**
 Responses sent from the server in data tasks created with `dataTaskWithRequest:success:failure:` and run using the `GET` / `POST` / et al. convenience methods are automatically validated and serialized by the response serializer. By default, this property is set to an instance of `AFJSONResponseSerializer`.

 @warning `responseSerializer` must not be `nil`.
 */
// 通过`dataTaskWithRequest:success:failure:`方法从服务端得到的响应数据，通过 response serializer自动进行验证和序列化。默认使用AFJSONResponseSerializer
@property (nonatomic, strong) id <AFURLResponseSerialization> responseSerializer;

///-------------------------------
/// @name Managing Security Policy
///-------------------------------

/**
 The security policy used by created session to evaluate server trust for secure connections. `AFURLSessionManager` uses the `defaultPolicy` unless otherwise specified.
 */
// https证书校验对象 security policy被用来校验服务端安全信任连接 使用defaultPolicy初始化
@property (nonatomic, strong) AFSecurityPolicy *securityPolicy;

#if !TARGET_OS_WATCH
///--------------------------------------
/// @name Monitoring Network Reachability
///--------------------------------------

/**
 The network reachability manager. `AFURLSessionManager` uses the `sharedManager` by default.
 */
// 网络状态监听管理   默认使用sharedManager
@property (readwrite, nonatomic, strong) AFNetworkReachabilityManager *reachabilityManager;
#endif

///----------------------------
/// @name Getting Session Tasks
///----------------------------

/**
 The data, upload, and download tasks currently run by the managed session.
 */
// 在session中的dataTask uploadTask downloadTask  指定数组内容的类型
@property (readonly, nonatomic, strong) NSArray <NSURLSessionTask *> *tasks;

/**
 The data tasks currently run by the managed session.
 */
// 在session中的dataTask的集合
@property (readonly, nonatomic, strong) NSArray <NSURLSessionDataTask *> *dataTasks;

/**
 The upload tasks currently run by the managed session.
 */
// 在session中的uploadTask的集合
@property (readonly, nonatomic, strong) NSArray <NSURLSessionUploadTask *> *uploadTasks;

/**
 The download tasks currently run by the managed session.
 */
// 在session中的downloadTask的集合
@property (readonly, nonatomic, strong) NSArray <NSURLSessionDownloadTask *> *downloadTasks;

///-------------------------------
/// @name Managing Callback Queues
///-------------------------------

/**
 The dispatch queue for `completionBlock`. If `NULL` (default), the main queue is used.
 */
// 统一在completionQueue中执行completionBlock  默认null，则会使用主队列
@property (nonatomic, strong, nullable) dispatch_queue_t completionQueue;

/**
 The dispatch group for `completionBlock`. If `NULL` (default), a private dispatch group is used.
 */
// completionBlock的任务组  默认会使用私有的一个group  dispatch_group_notify
@property (nonatomic, strong, nullable) dispatch_group_t completionGroup;

///---------------------
/// @name Initialization
///---------------------

/**
 Creates and returns a manager for a session created with the specified configuration. This is the designated initializer.

 @param configuration The configuration used to create the managed session.

 @return A manager for a newly-created session.
  
 */
// 创建一个manager，指定一个NSURLSessionConfiguration
- (instancetype)initWithSessionConfiguration:(nullable NSURLSessionConfiguration *)configuration NS_DESIGNATED_INITIALIZER;

/**
 Invalidates the managed session, optionally canceling pending tasks and optionally resets given session.
 
 @param cancelPendingTasks  Whether or not to cancel pending tasks.
 @param resetSession        Whether or not to reset the session of the manager.
 
 */

// 是否根据取消未完成的任务来使session失效
/* NSURLSession有两个方法：
 -(void)finishTasksAndInvalidate; 标示待完成所有的任务后失效
 -(void)invalidateAndCancel; 标示 立即失效，未完成的任务也将结束
 */
- (void)invalidateSessionCancelingTasks:(BOOL)cancelPendingTasks resetSession:(BOOL)resetSession;

///-------------------------
/// @name Running Data Tasks
///-------------------------

/**
 Creates an `NSURLSessionDataTask` with the specified request.

 @param request The HTTP request for the request.
 @param uploadProgressBlock A block object to be executed when the upload progress is updated. Note this block is called on the session queue, not the main queue.
 @param downloadProgressBlock A block object to be executed when the download progress is updated. Note this block is called on the session queue, not the main queue.
 @param completionHandler A block object to be executed when the task finishes. This block has no return value and takes three arguments: the server response, the response object created by that serializer, and the error that occurred, if any.
 */
// 根据request创建一个datatask，并且可以设置上传进度的block 下载进度的block 完成的block。不过都是在session的队列中
- (NSURLSessionDataTask *)dataTaskWithRequest:(NSURLRequest *)request
                               uploadProgress:(nullable void (^)(NSProgress *uploadProgress))uploadProgressBlock
                             downloadProgress:(nullable void (^)(NSProgress *downloadProgress))downloadProgressBlock
                            completionHandler:(nullable void (^)(NSURLResponse *response, id _Nullable responseObject,  NSError * _Nullable error))completionHandler;

///---------------------------
/// @name Running Upload Tasks
///---------------------------

/**
 Creates an `NSURLSessionUploadTask` with the specified request for a local file.

 @param request The HTTP request for the request.
 @param fileURL A URL to the local file to be uploaded.
 @param uploadProgressBlock A block object to be executed when the upload progress is updated. Note this block is called on the session queue, not the main queue.
 @param completionHandler A block object to be executed when the task finishes. This block has no return value and takes three arguments: the server response, the response object created by that serializer, and the error that occurred, if any.

 @see `attemptsToRecreateUploadTasksForBackgroundSessions`
 */
// 通过request和本地文件url创建一个uploadTask
- (NSURLSessionUploadTask *)uploadTaskWithRequest:(NSURLRequest *)request
                                         fromFile:(NSURL *)fileURL
                                         progress:(nullable void (^)(NSProgress *uploadProgress))uploadProgressBlock
                                completionHandler:(nullable void (^)(NSURLResponse *response, id _Nullable responseObject, NSError  * _Nullable error))completionHandler;

/**
 Creates an `NSURLSessionUploadTask` with the specified request for an HTTP body.

 @param request The HTTP request for the request.
 @param bodyData A data object containing the HTTP body to be uploaded.
 @param uploadProgressBlock A block object to be executed when the upload progress is updated. Note this block is called on the session queue, not the main queue.
 @param completionHandler A block object to be executed when the task finishes. This block has no return value and takes three arguments: the server response, the response object created by that serializer, and the error that occurred, if any.
 */
// 通过request和要提交的数据data创建一个uploadTask
- (NSURLSessionUploadTask *)uploadTaskWithRequest:(NSURLRequest *)request
                                         fromData:(nullable NSData *)bodyData
                                         progress:(nullable void (^)(NSProgress *uploadProgress))uploadProgressBlock
                                completionHandler:(nullable void (^)(NSURLResponse *response, id _Nullable responseObject, NSError * _Nullable error))completionHandler;

/**
 Creates an `NSURLSessionUploadTask` with the specified streaming request.

 @param request The HTTP request for the request.
 @param uploadProgressBlock A block object to be executed when the upload progress is updated. Note this block is called on the session queue, not the main queue.
 @param completionHandler A block object to be executed when the task finishes. This block has no return value and takes three arguments: the server response, the response object created by that serializer, and the error that occurred, if any.
 */
// 通过request创建一个stream数据上传的 uploadTask
- (NSURLSessionUploadTask *)uploadTaskWithStreamedRequest:(NSURLRequest *)request
                                                 progress:(nullable void (^)(NSProgress *uploadProgress))uploadProgressBlock
                                        completionHandler:(nullable void (^)(NSURLResponse *response, id _Nullable responseObject, NSError * _Nullable error))completionHandler;

///-----------------------------
/// @name Running Download Tasks
///-----------------------------

/**
 Creates an `NSURLSessionDownloadTask` with the specified request.

 @param request The HTTP request for the request.
 @param downloadProgressBlock A block object to be executed when the download progress is updated. Note this block is called on the session queue, not the main queue.
 @param destination A block object to be executed in order to determine the destination of the downloaded file. This block takes two arguments, the target path & the server response, and returns the desired file URL of the resulting download. The temporary file used during the download will be automatically deleted after being moved to the returned URL.
 @param completionHandler A block to be executed when a task finishes. This block has no return value and takes three arguments: the server response, the path of the downloaded file, and the error describing the network or parsing error that occurred, if any.

 @warning If using a background `NSURLSessionConfiguration` on iOS, these blocks will be lost when the app is terminated. Background sessions may prefer to use `-setDownloadTaskDidFinishDownloadingBlock:` to specify the URL for saving the downloaded file, rather than the destination block of this method.
 */
// destination的block需要一个返回值，作为下载文件的目标地址url 。 如果是一个后台下载任务，那么这里的回调block不会被调用。 需要使用-setDownloadTaskDidFinishDownloadingBlock: 来操作文件的保存
- (NSURLSessionDownloadTask *)downloadTaskWithRequest:(NSURLRequest *)request
                                             progress:(nullable void (^)(NSProgress *downloadProgress))downloadProgressBlock
                                          destination:(nullable NSURL * (^)(NSURL *targetPath, NSURLResponse *response))destination
                                    completionHandler:(nullable void (^)(NSURLResponse *response, NSURL * _Nullable filePath, NSError * _Nullable error))completionHandler;

/**
 Creates an `NSURLSessionDownloadTask` with the specified resume data.

 @param resumeData The data used to resume downloading.
 @param downloadProgressBlock A block object to be executed when the download progress is updated. Note this block is called on the session queue, not the main queue.
 @param destination A block object to be executed in order to determine the destination of the downloaded file. This block takes two arguments, the target path & the server response, and returns the desired file URL of the resulting download. The temporary file used during the download will be automatically deleted after being moved to the returned URL.
 @param completionHandler A block to be executed when a task finishes. This block has no return value and takes three arguments: the server response, the path of the downloaded file, and the error describing the network or parsing error that occurred, if any.
 */
// 通过resumeData来创建一个断点下载的downloadTask
- (NSURLSessionDownloadTask *)downloadTaskWithResumeData:(NSData *)resumeData
                                                progress:(nullable void (^)(NSProgress *downloadProgress))downloadProgressBlock
                                             destination:(nullable NSURL * (^)(NSURL *targetPath, NSURLResponse *response))destination
                                       completionHandler:(nullable void (^)(NSURLResponse *response, NSURL * _Nullable filePath, NSError * _Nullable error))completionHandler;

///---------------------------------
/// @name Getting Progress for Tasks
///---------------------------------

/**
 Returns the upload progress of the specified task.

 @param task The session task. Must not be `nil`.

 @return An `NSProgress` object reporting the upload progress of a task, or `nil` if the progress is unavailable.
 */
//根据NSURLSessionTask获取对应的任务完成进度NSProgress
- (nullable NSProgress *)uploadProgressForTask:(NSURLSessionTask *)task;

/**
 Returns the download progress of the specified task.

 @param task The session task. Must not be `nil`.

 @return An `NSProgress` object reporting the download progress of a task, or `nil` if the progress is unavailable.
 */
//根据NSURLSessionTask获取对应下载任务的进度NSProgress
- (nullable NSProgress *)downloadProgressForTask:(NSURLSessionTask *)task;

///-----------------------------------------
/// @name Setting Session Delegate Callbacks
///-----------------------------------------

/**
 Sets a block to be executed when the managed session becomes invalid, as handled by the `NSURLSessionDelegate` method `URLSession:didBecomeInvalidWithError:`.

 @param block A block object to be executed when the managed session becomes invalid. The block has no return value, and takes two arguments: the session, and the error related to the cause of invalidation.
 */
// 会在`URLSession:didBecomeInvalidWithError:`中被调用
//设置session无效时执行的回调块
- (void)setSessionDidBecomeInvalidBlock:(nullable void (^)(NSURLSession *session, NSError *error))block;

/**
 Sets a block to be executed when a connection level authentication challenge has occurred, as handled by the `NSURLSessionDelegate` method `URLSession:didReceiveChallenge:completionHandler:`.

 @param block A block object to be executed when a connection level authentication challenge has occurred. The block returns the disposition of the authentication challenge, and takes three arguments: the session, the authentication challenge, and a pointer to the credential that should be used to resolve the challenge.

 @warning Implementing a session authentication challenge handler yourself totally bypasses AFNetworking's security policy defined in `AFSecurityPolicy`. Make sure you fully understand the implications before implementing a custom session authentication challenge handler. If you do not want to bypass AFNetworking's security policy, use `-setAuthenticationChallengeHandler:` instead.

 @see -securityPolicy
 @see -setAuthenticationChallengeHandler:
 */
// 设置网络连接信任的block操作 会在URLSession:didReceiveChallenge:completionHandler:时调用
//设置session收到challenge时执行的回调块
- (void)setSessionDidReceiveAuthenticationChallengeBlock:(nullable NSURLSessionAuthChallengeDisposition (^)(NSURLSession *session, NSURLAuthenticationChallenge *challenge, NSURLCredential * _Nullable __autoreleasing * _Nullable credential))block;

///--------------------------------------
/// @name Setting Task Delegate Callbacks
///--------------------------------------

/**
 Sets a block to be executed when a task requires a new request body stream to send to the remote server, as handled by the `NSURLSessionTaskDelegate` method `URLSession:task:needNewBodyStream:`.

 @param block A block object to be executed when a task requires a new request body stream.
 */
//设置session需要新的流时执行的回调块
- (void)setTaskNeedNewBodyStreamBlock:(nullable NSInputStream * (^)(NSURLSession *session, NSURLSessionTask *task))block;

/**
 Sets a block to be executed when an HTTP request is attempting to perform a redirection to a different URL, as handled by the `NSURLSessionTaskDelegate` method `URLSession:willPerformHTTPRedirection:newRequest:completionHandler:`.

 @param block A block object to be executed when an HTTP request is attempting to perform a redirection to a different URL. The block returns the request to be made for the redirection, and takes four arguments: the session, the task, the redirection response, and the request corresponding to the redirection response.
 */
// 请求需要一个全新的，未打开的数据时调用。特别是请求一个body失败时，可以通过这个方法给一个新的body- (void)URLSession:(NSURLSession *)session
//设置session的任务需要执行重定向时执行的回调块
- (void)setTaskWillPerformHTTPRedirectionBlock:(nullable NSURLRequest * _Nullable (^)(NSURLSession *session, NSURLSessionTask *task, NSURLResponse *response, NSURLRequest *request))block;

/**
 Sets a block to be executed when a session task has received a request specific authentication challenge, as handled by the `NSURLSessionTaskDelegate` method `URLSession:task:didReceiveChallenge:completionHandler:`.
 
 @param authenticationChallengeHandler A block object to be executed when a session task has received a request specific authentication challenge.
 
 When implementing an authentication challenge handler, you should check the authentication method first (`challenge.protectionSpace.authenticationMethod `) to decide if you want to handle the authentication challenge yourself or if you want AFNetworking to handle it. If you want AFNetworking to handle the authentication challenge, just return `@(NSURLSessionAuthChallengePerformDefaultHandling)`. For example, you certainly want AFNetworking to handle certificate validation (i.e. authentication method == `NSURLAuthenticationMethodServerTrust`) as defined by the security policy. If you want to handle the challenge yourself, you have four options:
 
 1. Return `nil` from the authentication challenge handler. You **MUST** call the completion handler with a disposition and credentials yourself. Use this if you need to present a user interface to let the user enter their credentials.
 2. Return an `NSError` object from the authentication challenge handler. You **MUST NOT** call the completion handler when returning an `NSError `. The returned error will be reported in the completion handler of the task. Use this if you need to abort an authentication challenge with a specific error.
 3. Return an `NSURLCredential` object from the authentication challenge handler. You **MUST NOT** call the completion handler when returning an `NSURLCredential`. The returned credentials will be used to fulfil the challenge. Use this when you can get credentials without presenting a user interface.
 4. Return an `NSNumber` object wrapping an `NSURLSessionAuthChallengeDisposition`. Supported values are `@(NSURLSessionAuthChallengePerformDefaultHandling)`, `@(NSURLSessionAuthChallengeCancelAuthenticationChallenge)` and `@(NSURLSessionAuthChallengeRejectProtectionSpace)`. You **MUST NOT** call the completion handler when returning an `NSNumber`.
 
 If you return anything else from the authentication challenge handler, an exception will be thrown.
 
 For more information about how URL sessions handle the different types of authentication challenges, see [NSURLSession](https://developer.apple.com/reference/foundation/nsurlsession?language=objc) and [URL Session Programming Guide](https://developer.apple.com/library/content/documentation/Cocoa/Conceptual/URLLoadingSystem/URLLoadingSystem.html).
 
 @see -securityPolicy
 */
- (void)setAuthenticationChallengeHandler:(id (^)(NSURLSession *session, NSURLSessionTask *task, NSURLAuthenticationChallenge *challenge, void (^completionHandler)(NSURLSessionAuthChallengeDisposition , NSURLCredential * _Nullable)))authenticationChallengeHandler;

/**
 Sets a block to be executed periodically to track upload progress, as handled by the `NSURLSessionTaskDelegate` method `URLSession:task:didSendBodyData:totalBytesSent:totalBytesExpectedToSend:`.

 @param block A block object to be called when an undetermined number of bytes have been uploaded to the server. This block has no return value and takes five arguments: the session, the task, the number of bytes written since the last time the upload progress block was called, the total bytes written, and the total bytes expected to be written during the request, as initially determined by the length of the HTTP body. This block may be called multiple times, and will execute on the main thread.
 */
- (void)setTaskDidSendBodyDataBlock:(nullable void (^)(NSURLSession *session, NSURLSessionTask *task, int64_t bytesSent, int64_t totalBytesSent, int64_t totalBytesExpectedToSend))block;

/**
 Sets a block to be executed as the last message related to a specific task, as handled by the `NSURLSessionTaskDelegate` method `URLSession:task:didCompleteWithError:`.

 @param block A block object to be executed when a session task is completed. The block has no return value, and takes three arguments: the session, the task, and any error that occurred in the process of executing the task.
 */
- (void)setTaskDidCompleteBlock:(nullable void (^)(NSURLSession *session, NSURLSessionTask *task, NSError * _Nullable error))block;

/**
 Sets a block to be executed when metrics are finalized related to a specific task, as handled by the `NSURLSessionTaskDelegate` method `URLSession:task:didFinishCollectingMetrics:`.

 @param block A block object to be executed when a session task is completed. The block has no return value, and takes three arguments: the session, the task, and any metrics that were collected in the process of executing the task.
 */
#if AF_CAN_INCLUDE_SESSION_TASK_METRICS
- (void)setTaskDidFinishCollectingMetricsBlock:(nullable void (^)(NSURLSession *session, NSURLSessionTask *task, NSURLSessionTaskMetrics * _Nullable metrics))block AF_API_AVAILABLE(ios(10), macosx(10.12), watchos(3), tvos(10));
#endif
///-------------------------------------------
/// @name Setting Data Task Delegate Callbacks
///-------------------------------------------

/**
 Sets a block to be executed when a data task has received a response, as handled by the `NSURLSessionDataDelegate` method `URLSession:dataTask:didReceiveResponse:completionHandler:`.

 @param block A block object to be executed when a data task has received a response. The block returns the disposition of the session response, and takes three arguments: the session, the data task, and the received response.
 */
- (void)setDataTaskDidReceiveResponseBlock:(nullable NSURLSessionResponseDisposition (^)(NSURLSession *session, NSURLSessionDataTask *dataTask, NSURLResponse *response))block;

/**
 Sets a block to be executed when a data task has become a download task, as handled by the `NSURLSessionDataDelegate` method `URLSession:dataTask:didBecomeDownloadTask:`.

 @param block A block object to be executed when a data task has become a download task. The block has no return value, and takes three arguments: the session, the data task, and the download task it has become.
 */
- (void)setDataTaskDidBecomeDownloadTaskBlock:(nullable void (^)(NSURLSession *session, NSURLSessionDataTask *dataTask, NSURLSessionDownloadTask *downloadTask))block;

/**
 Sets a block to be executed when a data task receives data, as handled by the `NSURLSessionDataDelegate` method `URLSession:dataTask:didReceiveData:`.

 @param block A block object to be called when an undetermined number of bytes have been downloaded from the server. This block has no return value and takes three arguments: the session, the data task, and the data received. This block may be called multiple times, and will execute on the session manager operation queue.
 */
- (void)setDataTaskDidReceiveDataBlock:(nullable void (^)(NSURLSession *session, NSURLSessionDataTask *dataTask, NSData *data))block;

/**
 Sets a block to be executed to determine the caching behavior of a data task, as handled by the `NSURLSessionDataDelegate` method `URLSession:dataTask:willCacheResponse:completionHandler:`.

 @param block A block object to be executed to determine the caching behavior of a data task. The block returns the response to cache, and takes three arguments: the session, the data task, and the proposed cached URL response.
 */
- (void)setDataTaskWillCacheResponseBlock:(nullable NSCachedURLResponse * (^)(NSURLSession *session, NSURLSessionDataTask *dataTask, NSCachedURLResponse *proposedResponse))block;

/**
 Sets a block to be executed once all messages enqueued for a session have been delivered, as handled by the `NSURLSessionDataDelegate` method `URLSessionDidFinishEventsForBackgroundURLSession:`.

 @param block A block object to be executed once all messages enqueued for a session have been delivered. The block has no return value and takes a single argument: the session.
 */
- (void)setDidFinishEventsForBackgroundURLSessionBlock:(nullable void (^)(NSURLSession *session))block AF_API_UNAVAILABLE(macos);

///-----------------------------------------------
/// @name Setting Download Task Delegate Callbacks
///-----------------------------------------------

/**
 Sets a block to be executed when a download task has completed a download, as handled by the `NSURLSessionDownloadDelegate` method `URLSession:downloadTask:didFinishDownloadingToURL:`.

 @param block A block object to be executed when a download task has completed. The block returns the URL the download should be moved to, and takes three arguments: the session, the download task, and the temporary location of the downloaded file. If the file manager encounters an error while attempting to move the temporary file to the destination, an `AFURLSessionDownloadTaskDidFailToMoveFileNotification` will be posted, with the download task as its object, and the user info of the error.
 */
- (void)setDownloadTaskDidFinishDownloadingBlock:(nullable NSURL * _Nullable  (^)(NSURLSession *session, NSURLSessionDownloadTask *downloadTask, NSURL *location))block;

/**
 Sets a block to be executed periodically to track download progress, as handled by the `NSURLSessionDownloadDelegate` method `URLSession:downloadTask:didWriteData:totalBytesWritten:totalBytesExpectedToWrite:`.

 @param block A block object to be called when an undetermined number of bytes have been downloaded from the server. This block has no return value and takes five arguments: the session, the download task, the number of bytes read since the last time the download progress block was called, the total bytes read, and the total bytes expected to be read during the request, as initially determined by the expected content size of the `NSHTTPURLResponse` object. This block may be called multiple times, and will execute on the session manager operation queue.
 */
- (void)setDownloadTaskDidWriteDataBlock:(nullable void (^)(NSURLSession *session, NSURLSessionDownloadTask *downloadTask, int64_t bytesWritten, int64_t totalBytesWritten, int64_t totalBytesExpectedToWrite))block;

/**
 Sets a block to be executed when a download task has been resumed, as handled by the `NSURLSessionDownloadDelegate` method `URLSession:downloadTask:didResumeAtOffset:expectedTotalBytes:`.

 @param block A block object to be executed when a download task has been resumed. The block has no return value and takes four arguments: the session, the download task, the file offset of the resumed download, and the total number of bytes expected to be downloaded.
 */
- (void)setDownloadTaskDidResumeBlock:(nullable void (^)(NSURLSession *session, NSURLSessionDownloadTask *downloadTask, int64_t fileOffset, int64_t expectedTotalBytes))block;

@end

///--------------------
/// @name Notifications
///--------------------

/**
 Posted when a task resumes.
 */
FOUNDATION_EXPORT NSString * const AFNetworkingTaskDidResumeNotification;

/**
 Posted when a task finishes executing. Includes a userInfo dictionary with additional information about the task.
 */
FOUNDATION_EXPORT NSString * const AFNetworkingTaskDidCompleteNotification;

/**
 Posted when a task suspends its execution.
 */
FOUNDATION_EXPORT NSString * const AFNetworkingTaskDidSuspendNotification;

/**
 Posted when a session is invalidated.
 */
FOUNDATION_EXPORT NSString * const AFURLSessionDidInvalidateNotification;

/**
 Posted when a session download task finished moving the temporary download file to a specified destination successfully.
 */
FOUNDATION_EXPORT NSString * const AFURLSessionDownloadTaskDidMoveFileSuccessfullyNotification;

/**
 Posted when a session download task encountered an error when moving the temporary download file to a specified destination.
 */
FOUNDATION_EXPORT NSString * const AFURLSessionDownloadTaskDidFailToMoveFileNotification;

/**
 The raw response data of the task. Included in the userInfo dictionary of the `AFNetworkingTaskDidCompleteNotification` if response data exists for the task.
 */
FOUNDATION_EXPORT NSString * const AFNetworkingTaskDidCompleteResponseDataKey;

/**
 The serialized response object of the task. Included in the userInfo dictionary of the `AFNetworkingTaskDidCompleteNotification` if the response was serialized.
 */
FOUNDATION_EXPORT NSString * const AFNetworkingTaskDidCompleteSerializedResponseKey;

/**
 The response serializer used to serialize the response. Included in the userInfo dictionary of the `AFNetworkingTaskDidCompleteNotification` if the task has an associated response serializer.
 */
FOUNDATION_EXPORT NSString * const AFNetworkingTaskDidCompleteResponseSerializerKey;

/**
 The file path associated with the download task. Included in the userInfo dictionary of the `AFNetworkingTaskDidCompleteNotification` if an the response data has been stored directly to disk.
 */
FOUNDATION_EXPORT NSString * const AFNetworkingTaskDidCompleteAssetPathKey;

/**
 Any error associated with the task, or the serialization of the response. Included in the userInfo dictionary of the `AFNetworkingTaskDidCompleteNotification` if an error exists.
 */
FOUNDATION_EXPORT NSString * const AFNetworkingTaskDidCompleteErrorKey;

/**
 The session task metrics taken from the download task. Included in the userInfo dictionary of the `AFNetworkingTaskDidCompleteSessionTaskMetrics`
 */
FOUNDATION_EXPORT NSString * const AFNetworkingTaskDidCompleteSessionTaskMetrics;

NS_ASSUME_NONNULL_END
