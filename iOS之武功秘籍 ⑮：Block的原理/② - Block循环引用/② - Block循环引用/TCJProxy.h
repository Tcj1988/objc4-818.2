//
//  TCJProxy.h
//  ③ - 强引用NSTime相关
//
//  Created by tangchangjiang on 2021/2/8.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface TCJProxy : NSProxy
- (id)transformObject:(NSObject *)object;
+ (instancetype)proxyWithTransformObject:(id)object;
@end

NS_ASSUME_NONNULL_END
