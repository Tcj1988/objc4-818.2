//
//  ViewController.m
//  ④ - RunLoop源码查看
//
//  Created by tangchangjiang on 2021/2/9.
//

#import "ViewController.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    // 主运行循环
    CFRunLoopRef mainRunloop = CFRunLoopGetMain();
    // 当前运行循环
    CFRunLoopRef currentRunloop = CFRunLoopGetCurrent();
    
}


@end
