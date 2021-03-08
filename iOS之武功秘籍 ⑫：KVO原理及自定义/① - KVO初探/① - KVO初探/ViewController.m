//
//  ViewController.m
//  ① - KVO初探
//
//  Created by tangchangjiang on 2020/9/16.
//  Copyright © 2020 tangchangjiang. All rights reserved.
//

#import "ViewController.h"
#import "TCJViewController.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.title = @"过渡页";
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"跳转" style:UIBarButtonItemStyleDone target:self action:@selector(pushVC)];
}

- (void)pushVC{
    
    [self.navigationController pushViewController:[TCJViewController new] animated:YES];
}

@end
