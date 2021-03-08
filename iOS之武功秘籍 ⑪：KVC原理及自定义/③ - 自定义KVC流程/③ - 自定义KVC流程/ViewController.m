//
//  ViewController.m
//  ③ - 自定义KVC流程
//
//  Created by tangchangjiang on 2020/9/16.
//  Copyright © 2020 tangchangjiang. All rights reserved.
//

#import "ViewController.h"
#import "TCJPerson.h"
#import "NSObject+TCJKVC.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    TCJPerson *person = [[TCJPerson alloc] init];
    [person cj_setValue:nil forKey:nil];
}


@end
