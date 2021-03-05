//
//  TCJCar.h
//  ② - 使用联合体优化代码
//
//  Created by tangchangjiang on 2020/1/3.
//  Copyright © 2020 tangchangjiang. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface TCJCar : NSObject

@property (nonatomic, assign, getter = isFront) BOOL front;
@property (nonatomic, assign, getter = isBack) BOOL back;
@property (nonatomic, assign, getter = isLeft) BOOL left;
@property (nonatomic, assign, getter = isRight) BOOL right;

//- (void)setFront:(BOOL)isFront;
//- (BOOL)isFront;
//
//- (void)setBack:(BOOL)isBack;
//- (BOOL)isBack;
@end

NS_ASSUME_NONNULL_END
