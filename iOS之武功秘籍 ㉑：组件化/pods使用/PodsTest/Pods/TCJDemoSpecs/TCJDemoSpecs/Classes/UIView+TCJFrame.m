//
//  UIView+TCJFrame.m
//  
//
//  Created by tangchangjiang on 2018/9/12.
//  Copyright © 2018年 tangchangjiang. All rights reserved.
//

#import "UIView+TCJFrame.h"

@implementation UIView (TCJFrame)
+ (instancetype)tcj_viewFromXib
{
    return [[NSBundle mainBundle] loadNibNamed:NSStringFromClass(self) owner:nil options:nil].firstObject;
}
- (void)setTcj_height:(CGFloat)tcj_height
{
    CGRect rect = self.frame;
    rect.size.height = tcj_height;
    self.frame = rect;
}

- (CGFloat)tcj_height
{
    return self.frame.size.height;
}

- (CGFloat)tcj_width
{
    return self.frame.size.width;
}
- (void)setTcj_width:(CGFloat)tcj_width
{
    CGRect rect = self.frame;
    rect.size.width = tcj_width;
    self.frame = rect;
}

- (CGFloat)tcj_x
{
    return self.frame.origin.x;
    
}

- (void)setTcj_x:(CGFloat)tcj_x
{
    CGRect rect = self.frame;
    rect.origin.x = tcj_x;
    self.frame = rect;
}

- (void)setTcj_y:(CGFloat)tcj_y
{
    CGRect rect = self.frame;
    rect.origin.y = tcj_y;
    self.frame = rect;
}

- (CGFloat)tcj_y
{
    
    return self.frame.origin.y;
}

- (void)setTcj_centerX:(CGFloat)tcj_centerX
{
    CGPoint center = self.center;
    center.x = tcj_centerX;
    self.center = center;
}

- (CGFloat)tcj_centerX
{
    return self.center.x;
}

- (void)setTcj_centerY:(CGFloat)tcj_centerY
{
    CGPoint center = self.center;
    center.y = tcj_centerY;
    self.center = center;
}

- (CGFloat)tcj_centerY
{
    return self.center.y;
}

- (void)setTcj_size:(CGSize)tcj_size
{
    CGRect rect = self.frame;
    rect.size = tcj_size;
    self.frame = rect;
}

- (CGSize)tcj_size
{
    return self.frame.size;
}
@end
