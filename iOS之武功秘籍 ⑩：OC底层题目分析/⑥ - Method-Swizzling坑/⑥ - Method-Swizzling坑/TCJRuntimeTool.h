//
//  TCJRuntimeTool.h
//  ⑥ - Method-Swizzling坑
//
//  Created by tangchangjiang on 2021/2/24.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface TCJRuntimeTool : NSObject
/**
 交换方法
 @param cls 交换对象
 @param oriSEL 原始方法编号
 @param swizzledSEL 交换的方法编号
 */
+ (void)cj_methodSwizzlingWithClass:(Class)cls oriSEL:(SEL)oriSEL swizzledSEL:(SEL)swizzledSEL;
+ (void)cj_betterMethodSwizzlingWithClass:(Class)cls oriSEL:(SEL)oriSEL swizzledSEL:(SEL)swizzledSEL;
@end

NS_ASSUME_NONNULL_END
