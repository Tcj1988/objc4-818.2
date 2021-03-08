//
//  NSObject+TCJKVC.h
//  ③ - 自定义KVC流程
//
//  Created by tangchangjiang on 2020/9/16.
//  Copyright © 2020 tangchangjiang. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface NSObject (TCJKVC)
// TCJ KVC 自定义入口
- (void)cj_setValue:(nullable id)value forKey:(NSString *)key;
- (nullable id)cj_valueForKey:(NSString *)key;
@end

NS_ASSUME_NONNULL_END
