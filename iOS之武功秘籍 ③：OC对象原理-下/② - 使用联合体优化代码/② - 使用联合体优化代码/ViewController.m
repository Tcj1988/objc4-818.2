//
//  ViewController.m
//  ② - 使用联合体优化代码
//
//  Created by tangchangjiang on 2020/1/3.
//  Copyright © 2020 tangchangjiang. All rights reserved.
//

#import "ViewController.h"
#import "TCJCar.h"
#import <objc/runtime.h>

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    TCJCar *car = [[TCJCar alloc] init];
    car.front = YES;
    car.back = NO;
    car.left = NO;
    car.right = YES;
    NSLog(@"front:%d back:%d left:%d right:%d",car.isFront, car.isBack, car.isLeft, car.isRight);

}


@end
