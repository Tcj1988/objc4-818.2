//
//  ViewController.m
//  ② - KVO原理探讨
//
//  Created by tangchangjiang on 2020/9/16.
//  Copyright © 2020 tangchangjiang. All rights reserved.
//

#import "ViewController.h"
#import "TCJViewController.h"
#import <objc/runtime.h>
#import "TCJPerson.h"

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

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event{
    [self printClasses:[TCJPerson class]];
}
#pragma mark - 遍历类以及子类
- (void)printClasses:(Class)cls{
    
    // 注册类的总数
    int count = objc_getClassList(NULL, 0);
    // 创建一个数组， 其中包含给定对象
    NSMutableArray *mArray = [NSMutableArray arrayWithObject:cls];
    // 获取所有已注册的类
    Class* classes = (Class*)malloc(sizeof(Class)*count);
    objc_getClassList(classes, count);
    for (int i = 0; i<count; i++) {
        if (cls == class_getSuperclass(classes[i])) {
            [mArray addObject:classes[i]];
        }
    }
    free(classes);
    NSLog(@"ViewController:classes = %@", mArray);
}
@end
