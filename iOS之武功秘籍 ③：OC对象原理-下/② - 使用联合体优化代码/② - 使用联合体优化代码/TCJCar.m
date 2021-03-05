//
//  TCJCar.m
//  ② - 使用联合体优化代码
//
//  Created by tangchangjiang on 2020/1/3.
//  Copyright © 2020 tangchangjiang. All rights reserved.
//

#import "TCJCar.h"

//#define TCJDirectionFrontMask 0b00001000 //此二进制数对应十进制数为 8
//#define TCJDirectionBackMask  0b00000100 //此二进制数对应十进制数为 4
//#define TCJDirectionLeftMask  0b00000010 //此二进制数对应十进制数为 2
//#define TCJDirectionRightMask 0b00000001 //此二进制数对应十进制数为 1

#define TCJDirectionFrontMask    (1 << 3)
#define TCJDirectionBackMask     (1 << 2)
#define TCJDirectionLeftMask     (1 << 1)
#define TCJDirectionRightMask    (1 << 0)

@interface TCJCar()
{
    union{
        char bits;
        // 结构体仅仅是为了增强代码可读性
        struct {
            char front  : 1;
            char back   : 1;
            char left   : 1;
            char right  : 1;
        };
    }_frontBackLeftRight;
}
@end

@implementation TCJCar
- (instancetype)init
{
    self = [super init];
    if (self) {
        _frontBackLeftRight.bits = 0b00001000;
    }
    return self;
}

- (void)setFront:(BOOL)front
{
    if (front) {
        _frontBackLeftRight.bits |= TCJDirectionFrontMask;
    } else {
        _frontBackLeftRight.bits &= ~TCJDirectionFrontMask;
    }
}
- (BOOL)isFront
{
    return !!(_frontBackLeftRight.bits & TCJDirectionFrontMask);
}
- (void)setBack:(BOOL)back
{
    if (back) {
        _frontBackLeftRight.bits |= TCJDirectionBackMask;
    } else {
        _frontBackLeftRight.bits &= ~TCJDirectionBackMask;
    }
}
- (BOOL)isBack
{
    return !!(_frontBackLeftRight.bits & TCJDirectionBackMask);
}
- (void)setLeft:(BOOL)left
{
    if (left) {
        _frontBackLeftRight.bits |= TCJDirectionLeftMask;
    } else {
        _frontBackLeftRight.bits &= ~TCJDirectionLeftMask;
    }
}
- (BOOL)isLeft
{
    return !!(_frontBackLeftRight.bits & TCJDirectionLeftMask);
}
- (void)setRight:(BOOL)right
{
    if (right) {
        _frontBackLeftRight.bits |= TCJDirectionRightMask;
    } else {
        _frontBackLeftRight.bits &= ~TCJDirectionRightMask;
    }
}
- (BOOL)isRight
{
    return !!(_frontBackLeftRight.bits & TCJDirectionRightMask);
}
@end
