//
//  StoreboardView.m
//  PassengerService
//
//  Created by tangchangjiang on 2018/11/2.
//  Copyright © 2018 tangchangjiang. All rights reserved.
//

#import "StoreboardView.h"

@implementation StoreboardView

// 边框宽度
- (void)setBorderWidth:(float)borderWidth
{
    self.layer.borderWidth = borderWidth;
}

// 边框颜色
- (void)setBorderColor:(UIColor *)borderColor
{
    self.layer.borderColor = borderColor.CGColor;
}

// 圆角
- (void)setCornerRadius:(float)cornerRadius
{
    self.layer.cornerRadius = cornerRadius;
}

@end
