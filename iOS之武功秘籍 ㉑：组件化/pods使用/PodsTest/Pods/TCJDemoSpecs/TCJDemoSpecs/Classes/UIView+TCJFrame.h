//
//  UIView+TCJFrame.h
//  
//
//  Created by tangchangjiang on 2018/9/12.
//  Copyright © 2018年 tangchangjiang. All rights reserved.
//

#import <UIKit/UIKit.h>
/*
 
 写分类:避免跟其他开发者产生冲突,加前缀
 
 */

//- (CGFloat)x;
//- (void)setX:(CGFloat)x;
/** 在分类中声明@property, 只会生成方法的声明, 不会生成方法的实现和带有_下划线的成员变量*/
@interface UIView (TCJFrame)
@property CGFloat tcj_width;
@property CGFloat tcj_height;
@property CGFloat tcj_x;
@property CGFloat tcj_y;
@property CGFloat tcj_centerX;
@property CGFloat tcj_centerY;
@property CGSize tcj_size;
+ (instancetype)tcj_viewFromXib;
@end
