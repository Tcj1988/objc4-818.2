// AFURLRequestSerialization.h
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
#import <TargetConditionals.h>

#if TARGET_OS_IOS || TARGET_OS_TV
#import <UIKit/UIKit.h>
#elif TARGET_OS_WATCH
#import <WatchKit/WatchKit.h>
#endif

NS_ASSUME_NONNULL_BEGIN

/**
 Returns a percent-escaped string following RFC 3986 for a query string key or value.
 RFC 3986 states that the following characters are "reserved" characters.
 - General Delimiters: ":", "#", "[", "]", "@", "?", "/"
 - Sub-Delimiters: "!", "$", "&", "'", "(", ")", "*", "+", ",", ";", "="

 In RFC 3986 - Section 3.4, it states that the "?" and "/" characters should not be escaped to allow
 query strings to include a URL. Therefore, all "reserved" characters with the exception of "?" and "/"
 should be percent-escaped in the query string.
 
 @param string The string to be percent-escaped.
 
 @return The percent-escaped string.
 */
//FOUNDATION_EXPORT:相当于宏.进行url的百分比编码转义，只有?/可以不转义，通过该方法把其余的符号进行转义后返回
FOUNDATION_EXPORT NSString * AFPercentEscapedStringFromString(NSString *string);

/**
 A helper method to generate encoded url query parameters for appending to the end of a URL.

 @param parameters A dictionary of key/values to be encoded.

 @return A url encoded query string
 */
// 将NSDictionary类型的参数转换为字符串类型  并且会调用上面的函数进行百分比转义
// 将{@"name":@"yourname",@"id":@"yourid"} 转换为 name=yourname&id=yourid
FOUNDATION_EXPORT NSString * AFQueryStringFromParameters(NSDictionary *parameters);

/**
 The `AFURLRequestSerialization` protocol is adopted by an object that encodes parameters for a specified HTTP requests. Request serializers may encode parameters as query strings, HTTP bodies, setting the appropriate HTTP header fields as necessary.

 For example, a JSON request serializer may set the HTTP body of the request to a JSON representation, and set the `Content-Type` HTTP header field value to `application/json`.
 */
// AFURLRequestSerialization协议是给一个指定的HTTP请求进行参数的序列化，请求的序列化可能将参数作为查询字符串、httpbody，并且会设置一些必要的http header属性。 例如，一个json格式的Serializer对象会设置httpbody为json格式，并且会设置httpheader中的「Content-Type」属性为「application/json」
@protocol AFURLRequestSerialization <NSObject, NSSecureCoding, NSCopying>

/**
 Returns a request with the specified parameters encoded into a copy of the original request.

 @param request The original request.
 @param parameters The parameters to be encoded.
 @param error The error that occurred while attempting to encode the request parameters.

 @return A serialized request.
 */
// AFURLRequestSerialization协议的一个方法
// 返回一个原始request的copy对象，将参数根据指定的编码格式进行处理
- (nullable NSURLRequest *)requestBySerializingRequest:(NSURLRequest *)request
                               withParameters:(nullable id)parameters
                                        error:(NSError * _Nullable __autoreleasing *)error NS_SWIFT_NOTHROW;

@end

#pragma mark -

/**

 */
typedef NS_ENUM(NSUInteger, AFHTTPRequestQueryStringSerializationStyle) {
    AFHTTPRequestQueryStringDefaultStyle = 0,
};
// 用于拼接可变data的一个协议
@protocol AFMultipartFormData;

/**
 `AFHTTPRequestSerializer` conforms to the `AFURLRequestSerialization` & `AFURLResponseSerialization` protocols, offering a concrete base implementation of query string / URL form-encoded parameter serialization and default request headers, as well as response status code and content type validation.

 Any request or response serializer dealing with HTTP is encouraged to subclass `AFHTTPRequestSerializer` in order to ensure consistent default behavior.
 */
// 一个遵守AFURLRequestSerialization协议的序列化的基类，提供了基础的参数、url序列化，和默认的请求头设置。包括返回码和content type的校验等
@interface AFHTTPRequestSerializer : NSObject <AFURLRequestSerialization>

/**
 The string encoding used to serialize parameters. `NSUTF8StringEncoding` by default.
 */
// 字符串编码格式 默认是NSUTF8StringEncoding，例如将转义后的参数字符串设置到httpbody中是，就要指定编码格式
@property (nonatomic, assign) NSStringEncoding stringEncoding;

/**
 Whether created requests can use the device’s cellular radio (if present). `YES` by default.

 @see NSMutableURLRequest -setAllowsCellularAccess:
 */
/**
 是否允许使用设备的蜂窝移动网络来创建request，默认为允许:
 */
@property (nonatomic, assign) BOOL allowsCellularAccess;

/**
 The cache policy of created requests. `NSURLRequestUseProtocolCachePolicy` by default.

 @see NSMutableURLRequest -setCachePolicy:
 */
/**
 创建的request所使用的缓存策略，默认使用`NSURLRequestUseProtocolCachePolicy`，该策略表示
 如果缓存不存在，直接从服务端获取。如果缓存存在，会根据response中的Cache-Control字段判断
 下一步操作，如: Cache-Control字段为must-revalidata, 则 询问服务端该数据是否有更新，无更新话
 直接返回给用户缓存数据，若已更新，则请求服务端.
 */
@property (nonatomic, assign) NSURLRequestCachePolicy cachePolicy;

/**
 Whether created requests should use the default cookie handling. `YES` by default.

 @see NSMutableURLRequest -setHTTPShouldHandleCookies:
 */
/**
 如果设置HTTPShouldHandleCookies为YES，就处理存储在NSHTTPCookieStore中的cookies
 HTTPShouldHandleCookies表示是否应该给request设置cookie并随request一起发送出去
 */
@property (nonatomic, assign) BOOL HTTPShouldHandleCookies;

/**
 Whether created requests can continue transmitting data before receiving a response from an earlier transmission. `NO` by default

 @see NSMutableURLRequest -setHTTPShouldUsePipelining:
 */
/**
 HTTPShouldUsePipelining表示receiver(理解为iOS客户端)的下一个信息是否必须等到上一个请求回复才能发送。
 如果为YES表示可以，NO表示必须等receiver收到先前的回复才能发送下个信息。
 */
@property (nonatomic, assign) BOOL HTTPShouldUsePipelining;

/**
 The network service type for created requests. `NSURLNetworkServiceTypeDefault` by default.

 @see NSMutableURLRequest -setNetworkServiceType:
 */
/**
 设定request的network service类型. 默认是`NSURLNetworkServiceTypeDefault`.
 这个network service是为了告诉系统网络层这个request使用的目的
 比如NSURLNetworkServiceTypeVoIP表示的就这个request是用来请求网际协议通话技术(Voice over IP)。
 系统能根据提供的信息来优化网络处理，从而优化电池寿命，网络性能等等
 区分标准网络流量，VOIP，语音，视频和后台进程使用的流量。大多数应用程序不需要设置它
 */
@property (nonatomic, assign) NSURLRequestNetworkServiceType networkServiceType;

/**
 The timeout interval, in seconds, for created requests. The default timeout interval is 60 seconds.

 @see NSMutableURLRequest -setTimeoutInterval:
 */
/**
 超时机制，默认60秒
 */
@property (nonatomic, assign) NSTimeInterval timeoutInterval;

///---------------------------------------
/// @name Configuring HTTP Request Headers
///---------------------------------------

/**
 Default HTTP header field values to be applied to serialized requests. By default, these include the following:

 - `Accept-Language` with the contents of `NSLocale +preferredLanguages`
 - `User-Agent` with the contents of various bundle identifiers and OS designations

 @discussion To add or remove default request headers, use `setValue:forHTTPHeaderField:`.
 */
// 默认的http header设置，将会应用于序列化的request对象
// `Accept-Language`会设置为设备当前语言 会设置为项目bundleid和系统平台名称
// 其实在实现时，使用了mutableHTTPRequestHeaders 一个可变的字典来设置HTTPRequestHeaders
@property (readonly, nonatomic, strong) NSDictionary <NSString *, NSString *> *HTTPRequestHeaders;

/**
 Creates and returns a serializer with default configuration.
 */
+ (instancetype)serializer;

/**
 Sets the value for the HTTP headers set in request objects made by the HTTP client. If `nil`, removes the existing value for that header.

 @param field The HTTP header to set a default value for
 @param value The value set as default for the specified header, or `nil`
 */
// 其实使用了一个mutableHTTPRequestHeaders属性来进行HTTPRequestHeaders的设置，因为除了设置的HTTPRequestHeaders的属性，还有一些默认的header属性需要设置，所以采用了一个NSMutableDictionary来设置
- (void)setValue:(nullable NSString *)value
forHTTPHeaderField:(NSString *)field;

/**
 Returns the value for the HTTP headers set in the request serializer.

 @param field The HTTP header to retrieve the default value for

 @return The value set as default for the specified header, or `nil`
 */
- (nullable NSString *)valueForHTTPHeaderField:(NSString *)field;

/**
 Sets the "Authorization" HTTP header set in request objects made by the HTTP client to a basic authentication value with Base64-encoded username and password. This overwrites any existing value for this header.

 这是干嘛的？
 @param username The HTTP basic auth username
 @param password The HTTP basic auth password
 */
// 根据username 和 password设置http header中的「Authorization」字段
- (void)setAuthorizationHeaderFieldWithUsername:(NSString *)username
                                       password:(NSString *)password;

/**
 Clears any existing value for the "Authorization" HTTP header.
 */
- (void)clearAuthorizationHeader;

///-------------------------------------------------------
/// @name Configuring Query String Parameter Serialization
///-------------------------------------------------------

/**
 HTTP methods for which serialized requests will encode parameters as a query string. `GET`, `HEAD`, and `DELETE` by default.
 */
// 将参数编码为query string的HTTP方法，默认为`GET`, `HEAD`, and `DELETE`
// 这些HTTP方法 会进行参数字符串的百分号编码，然后拼接到url之后
@property (nonatomic, strong) NSSet <NSString *> *HTTPMethodsEncodingParametersInURI;

/**
 Set the method of query string serialization according to one of the pre-defined styles.

 @param style The serialization style.

 @see AFHTTPRequestQueryStringSerializationStyle
 */
// 根据预定的样式序列化 目前只有一个默认的
- (void)setQueryStringSerializationWithStyle:(AFHTTPRequestQueryStringSerializationStyle)style;

/**
 Set the a custom method of query string serialization according to the specified block.

 @param block A block that defines a process of encoding parameters into a query string. This block returns the query string and takes three arguments: the request, the parameters to encode, and the error that occurred when attempting to encode parameters for the given request.
 */
// 设置一个自定义的序列化block
- (void)setQueryStringSerializationWithBlock:(nullable NSString * _Nullable (^)(NSURLRequest *request, id parameters, NSError * __autoreleasing *error))block;

///-------------------------------
/// @name Creating Request Objects
///-------------------------------

/**
 Creates an `NSMutableURLRequest` object with the specified HTTP method and URL string.

 If the HTTP method is `GET`, `HEAD`, or `DELETE`, the parameters will be used to construct a url-encoded query string that is appended to the request's URL. Otherwise, the parameters will be encoded according to the value of the `parameterEncoding` property, and set as the request body.

 @param method The HTTP method for the request, such as `GET`, `POST`, `PUT`, or `DELETE`. This parameter must not be `nil`.
 @param URLString The URL string used to create the request URL.
 @param parameters The parameters to be either set as a query string for `GET` requests, or the request HTTP body.
 @param error The error that occurred while constructing the request.

 @return An `NSMutableURLRequest` object.
 */
// 根据指定的url和http方法创建一个request对象
// 如果方法是`GET`, `HEAD`, or `DELETE`，那么会将参数经过编码后构造为查询字符串添加到url后。不然，参数会根据「stringEncoding」进行编码后设置为body
- (nullable NSMutableURLRequest *)requestWithMethod:(NSString *)method
                                          URLString:(NSString *)URLString
                                         parameters:(nullable id)parameters
                                              error:(NSError * _Nullable __autoreleasing *)error;

/**
 Creates an `NSMutableURLRequest` object with the specified HTTP method and URLString, and constructs a `multipart/form-data` HTTP body, using the specified parameters and multipart form data block. See http://www.w3.org/TR/html4/interact/forms.html#h-17.13.4.2

 Multipart form requests are automatically streamed, reading files directly from disk along with in-memory data in a single HTTP body. The resulting `NSMutableURLRequest` object has an `HTTPBodyStream` property, so refrain from setting `HTTPBodyStream` or `HTTPBody` on this request object, as it will clear out the multipart form body stream.

 @param method The HTTP method for the request. This parameter must not be `GET` or `HEAD`, or `nil`.
 @param URLString The URL string used to create the request URL.
 @param parameters The parameters to be encoded and set in the request HTTP body.
 @param block A block that takes a single argument and appends data to the HTTP body. The block argument is an object adopting the `AFMultipartFormData` protocol.
 @param error The error that occurred while constructing the request.

 @return An `NSMutableURLRequest` object
 */
// 根据指定的url和http方法创建一个NSMutableURLRequest，并且会构建一个「multipart/form-data」的http body，通过block设置指定的参数
// 这个方法会自动设置流数据，直接读取磁盘的文件到内存中，返回的NSMutableURLRequest有一个HTTPBodyStream对象，但是不要再次设置他的HTTPBodyStream和HTTPBody。
- (NSMutableURLRequest *)multipartFormRequestWithMethod:(NSString *)method
                                              URLString:(NSString *)URLString
                                             parameters:(nullable NSDictionary <NSString *, id> *)parameters
                              constructingBodyWithBlock:(nullable void (^)(id <AFMultipartFormData> formData))block
                                                  error:(NSError * _Nullable __autoreleasing *)error;

/**
 Creates an `NSMutableURLRequest` by removing the `HTTPBodyStream` from a request, and asynchronously writing its contents into the specified file, invoking the completion handler when finished.

 @param request The multipart form request. The `HTTPBodyStream` property of `request` must not be `nil`.
 @param fileURL The file URL to write multipart form contents to.
 @param handler A handler block to execute.

 @discussion There is a bug in `NSURLSessionTask` that causes requests to not send a `Content-Length` header when streaming contents from an HTTP body, which is notably problematic when interacting with the Amazon S3 webservice. As a workaround, this method takes a request constructed with `multipartFormRequestWithMethod:URLString:parameters:constructingBodyWithBlock:error:`, or any other request with an `HTTPBodyStream`, writes the contents to the specified file and returns a copy of the original request with the `HTTPBodyStream` property set to `nil`. From here, the file can either be passed to `AFURLSessionManager -uploadTaskWithRequest:fromFile:progress:completionHandler:`, or have its contents read into an `NSData` that's assigned to the `HTTPBody` property of the request.

 @see https://github.com/AFNetworking/AFNetworking/issues/1398
 */
/**
 将原来request中的HTTPBodyStream内容异步写入到指定文件中，随后调用completionHandler处理。最后返回新的request。
 @param request multipart形式的request，其中HTTPBodyStream属性不能为nil
 @param fileURL multipart request中的HTTPBodyStream内容写入的文件位置
 @param handler 用于处理的block
 @discussion NSURLSessionTask中有一个bug，当HTTP body的内容是来自NSStream的时候，request无法发送Content-Length到服务器端，此问题在Amazon S3的Web服务中尤为显著。作为一个解决方案，该函数的request参数使用的是multipartFormRequestWithMethod:URLString:parameters:constructingBodyWithBlock:error:构建出的request，或者其他HTTPBodyStream属性不为空的request。接着将HTTPBodyStream的内容先写到指定的文件中，再返回一个原来那个request的拷贝，其中该拷贝的HTTPBodyStream属性值要置为空。至此，可以使用AFURLSessionManager -uploadTaskWithRequest:fromFile:progress:completionHandler:函数构建一个上传任务，或者将文件内容转变为NSData类型，并且指定给新request的HTTPBody属性。
 */
- (NSMutableURLRequest *)requestWithMultipartFormRequest:(NSURLRequest *)request
                             writingStreamContentsToFile:(NSURL *)fileURL
                                       completionHandler:(nullable void (^)(NSError * _Nullable error))handler;

@end

#pragma mark -

/**
 The `AFMultipartFormData` protocol defines the methods supported by the parameter in the block argument of `AFHTTPRequestSerializer -multipartFormRequestWithMethod:URLString:parameters:constructingBodyWithBlock:`.
 */
// AFMultipartFormData协议定义了在「`AFHTTPRequestSerializer -multipartFormRequestWithMethod:URLString:parameters:constructingBodyWithBlock:`」接口中block的formData参数需要支持的方法
@protocol AFMultipartFormData

/**
 Appends the HTTP header `Content-Disposition: file; filename=#{generated filename}; name=#{name}"` and `Content-Type: #{generated mimeType}`, followed by the encoded file data and the multipart form boundary.

 The filename and MIME type for this data in the form will be automatically generated, using the last path component of the `fileURL` and system associated MIME type for the `fileURL` extension, respectively.

 @param fileURL The URL corresponding to the file whose content will be appended to the form. This parameter must not be `nil`.
 @param name The name to be associated with the specified data. This parameter must not be `nil`.
 @param error If an error occurs, upon return contains an `NSError` object that describes the problem.

 @return `YES` if the file data was successfully appended, otherwise `NO`.
 */
// 根据文件位置和name拼接httpbody数据。会设置好「Disposition」「Content-Type」「boundary」等格式
// filename和MIME type会根据文件名自动设置
- (BOOL)appendPartWithFileURL:(NSURL *)fileURL
                         name:(NSString *)name
                        error:(NSError * _Nullable __autoreleasing *)error;

/**
 Appends the HTTP header `Content-Disposition: file; filename=#{filename}; name=#{name}"` and `Content-Type: #{mimeType}`, followed by the encoded file data and the multipart form boundary.

 @param fileURL The URL corresponding to the file whose content will be appended to the form. This parameter must not be `nil`.
 @param name The name to be associated with the specified data. This parameter must not be `nil`.
 @param fileName The file name to be used in the `Content-Disposition` header. This parameter must not be `nil`.
 @param mimeType The declared MIME type of the file data. This parameter must not be `nil`.
 @param error If an error occurs, upon return contains an `NSError` object that describes the problem.

 @return `YES` if the file data was successfully appended otherwise `NO`.
 */
- (BOOL)appendPartWithFileURL:(NSURL *)fileURL
                         name:(NSString *)name
                     fileName:(NSString *)fileName
                     mimeType:(NSString *)mimeType
                        error:(NSError * _Nullable __autoreleasing *)error;

/**
 Appends the HTTP header `Content-Disposition: file; filename=#{filename}; name=#{name}"` and `Content-Type: #{mimeType}`, followed by the data from the input stream and the multipart form boundary.

 @param inputStream The input stream to be appended to the form data
 @param name The name to be associated with the specified input stream. This parameter must not be `nil`.
 @param fileName The filename to be associated with the specified input stream. This parameter must not be `nil`.
 @param length The length of the specified input stream in bytes.
 @param mimeType The MIME type of the specified data. (For example, the MIME type for a JPEG image is image/jpeg.) For a list of valid MIME types, see http://www.iana.org/assignments/media-types/. This parameter must not be `nil`.
 */
// 根据inputStream拼接httpbody数据
- (void)appendPartWithInputStream:(nullable NSInputStream *)inputStream
                             name:(NSString *)name
                         fileName:(NSString *)fileName
                           length:(int64_t)length
                         mimeType:(NSString *)mimeType;

/**
 Appends the HTTP header `Content-Disposition: file; filename=#{filename}; name=#{name}"` and `Content-Type: #{mimeType}`, followed by the encoded file data and the multipart form boundary.

 @param data The data to be encoded and appended to the form data.
 @param name The name to be associated with the specified data. This parameter must not be `nil`.
 @param fileName The filename to be associated with the specified data. This parameter must not be `nil`.
 @param mimeType The MIME type of the specified data. (For example, the MIME type for a JPEG image is image/jpeg.) For a list of valid MIME types, see http://www.iana.org/assignments/media-types/. This parameter must not be `nil`.
 */
// 根据文件data拼接httpbody数据
- (void)appendPartWithFileData:(NSData *)data
                          name:(NSString *)name
                      fileName:(NSString *)fileName
                      mimeType:(NSString *)mimeType;

/**
 Appends the HTTP headers `Content-Disposition: form-data; name=#{name}"`, followed by the encoded data and the multipart form boundary.

 @param data The data to be encoded and appended to the form data.
 @param name The name to be associated with the specified data. This parameter must not be `nil`.
 */
// 拼接data并且设置name到HTTP headers `Content-Disposition: form-data; name=#{name}中
- (void)appendPartWithFormData:(NSData *)data
                          name:(NSString *)name;


/**
 Appends HTTP headers, followed by the encoded data and the multipart form boundary.

 @param headers The HTTP headers to be appended to the form data.
 @param body The data to be encoded and appended to the form data. This parameter must not be `nil`.
 */
// 由上一个方法继续调用设置data到body中，设置拼接好name的Content-Disposition到HTTP headers中
- (void)appendPartWithHeaders:(nullable NSDictionary <NSString *, NSString *> *)headers
                         body:(NSData *)body;

/**
 Throttles request bandwidth by limiting the packet size and adding a delay for each chunk read from the upload stream.

 When uploading over a 3G or EDGE connection, requests may fail with "request body stream exhausted". Setting a maximum packet size and delay according to the recommended values (`kAFUploadStream3GSuggestedPacketSize` and `kAFUploadStream3GSuggestedDelay`) lowers the risk of the input stream exceeding its allocated bandwidth. Unfortunately, there is no definite way to distinguish between a 3G, EDGE, or LTE connection over `NSURLConnection`. As such, it is not recommended that you throttle bandwidth based solely on network reachability. Instead, you should consider checking for the "request body stream exhausted" in a failure block, and then retrying the request with throttled bandwidth.

 @param numberOfBytes Maximum packet size, in number of bytes. The default packet size for an input stream is 16kb.
 @param delay Duration of delay each time a packet is read. By default, no delay is set.
 */
// 设置bodyStream的属性
// 通过控制包的大小和延迟来限制请求中带宽。当使用3g或者E网络时，请求可能会因为弱网环境等因素而失败。通过这是包大小限制和延迟来降低这种风险。建议我们在失败的block中再次尝试请求和控制请求带宽
- (void)throttleBandwidthWithPacketSize:(NSUInteger)numberOfBytes
                                  delay:(NSTimeInterval)delay;

@end

#pragma mark -

/**
 `AFJSONRequestSerializer` is a subclass of `AFHTTPRequestSerializer` that encodes parameters as JSON using `NSJSONSerialization`, setting the `Content-Type` of the encoded request to `application/json`.
 */
// request的json序列化的子类。参数会使用NSJSONSerialization进行编码，并且会设置「Content-Type」为「application/json」
@interface AFJSONRequestSerializer : AFHTTPRequestSerializer

/**
 Options for writing the request JSON data from Foundation objects. For possible values, see the `NSJSONSerialization` documentation section "NSJSONWritingOptions". `0` by default.
 */
// json序列化选项 默认使用NSJSONWritingPrettyPrinted
@property (nonatomic, assign) NSJSONWritingOptions writingOptions;

/**
 Creates and returns a JSON serializer with specified reading and writing options.

 @param writingOptions The specified JSON writing options.
 */
// 通过指定的NSJSONWritingOptions创建序列化对象
+ (instancetype)serializerWithWritingOptions:(NSJSONWritingOptions)writingOptions;

@end

#pragma mark -

/**
 `AFPropertyListRequestSerializer` is a subclass of `AFHTTPRequestSerializer` that encodes parameters as JSON using `NSPropertyListSerializer`, setting the `Content-Type` of the encoded request to `application/x-plist`.
 */
// request的plist序列化的子类。参数会使用NSPropertyListSerializer进行编码，并且会设置「Content-Type」为「pplication/x-plist」
@interface AFPropertyListRequestSerializer : AFHTTPRequestSerializer

/**
 The property list format. Possible values are described in "NSPropertyListFormat".
 */
// 设置NSPropertyListFormat 默认NSPropertyListXMLFormat_v1_0
@property (nonatomic, assign) NSPropertyListFormat format;

/**
 @warning The `writeOptions` property is currently unused.
 */
// 暂时没有用到
@property (nonatomic, assign) NSPropertyListWriteOptions writeOptions;

/**
 Creates and returns a property list serializer with a specified format, read options, and write options.

 @param format The property list format.
 @param writeOptions The property list write options.

 @warning The `writeOptions` property is currently unused.
 */
// 通过指定的NSPropertyListFormat 和 NSPropertyListWriteOptions创建对象
+ (instancetype)serializerWithFormat:(NSPropertyListFormat)format
                        writeOptions:(NSPropertyListWriteOptions)writeOptions;

@end

#pragma mark -

///----------------
/// @name Constants
///----------------

/**
 ## Error Domains

 The following error domain is predefined.

 - `NSString * const AFURLRequestSerializationErrorDomain`

 ### Constants

 `AFURLRequestSerializationErrorDomain`
 AFURLRequestSerializer errors. Error codes for `AFURLRequestSerializationErrorDomain` correspond to codes in `NSURLErrorDomain`.
 */
FOUNDATION_EXPORT NSString * const AFURLRequestSerializationErrorDomain;

/**
 ## User info dictionary keys

 These keys may exist in the user info dictionary, in addition to those defined for NSError.

 - `NSString * const AFNetworkingOperationFailingURLRequestErrorKey`

 ### Constants

 `AFNetworkingOperationFailingURLRequestErrorKey`
 The corresponding value is an `NSURLRequest` containing the request of the operation associated with an error. This key is only present in the `AFURLRequestSerializationErrorDomain`.
 */
FOUNDATION_EXPORT NSString * const AFNetworkingOperationFailingURLRequestErrorKey;

/**
 ## Throttling Bandwidth for HTTP Request Input Streams

 @see -throttleBandwidthWithPacketSize:delay:

 ### Constants

 `kAFUploadStream3GSuggestedPacketSize`
 Maximum packet size, in number of bytes. Equal to 16kb.

 `kAFUploadStream3GSuggestedDelay`
 Duration of delay each time a packet is read. Equal to 0.2 seconds.
 */
FOUNDATION_EXPORT NSUInteger const kAFUploadStream3GSuggestedPacketSize;
FOUNDATION_EXPORT NSTimeInterval const kAFUploadStream3GSuggestedDelay;

NS_ASSUME_NONNULL_END
