//
//  NSObject+TCJKVO.h
//  ③ - 自定义KVO
//
//  Created by tangchangjiang on 2020/9/17.
//  Copyright © 2020 tangchangjiang. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

typedef void(^TCJKVOBlock)(id observer,NSString *keyPath,id oldValue,id newValue);

@interface NSObject (TCJKVO)
- (void)cj_addObserver:(NSObject *)observer forKeyPath:(NSString *)keyPath block:(TCJKVOBlock)block;

- (void)cj_removeObserver:(NSObject *)observer forKeyPath:(NSString *)keyPath;
@end

NS_ASSUME_NONNULL_END
