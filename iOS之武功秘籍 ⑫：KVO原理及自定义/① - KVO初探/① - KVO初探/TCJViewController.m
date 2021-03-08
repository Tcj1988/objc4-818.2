//
//  TCJViewController.m
//  ① - KVO初探
//
//  Created by tangchangjiang on 2020/9/16.
//  Copyright © 2020 tangchangjiang. All rights reserved.
//

#import "TCJViewController.h"
#import "TCJPerson.h"
#import "TCJStudent.h"
#import "TCJDetailViewController.h"


static void *PersonNickContext = &PersonNickContext;
static void *PersonNameContext = &PersonNameContext;
static void *StudentNameContext = &StudentNameContext;

@interface TCJViewController ()
@property (nonatomic, strong) TCJPerson  *person;
@property (nonatomic, strong) TCJStudent *student;
@end

@implementation TCJViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.title = @"初探页";
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"跳转" style:UIBarButtonItemStyleDone target:self action:@selector(pushVC)];
    
    self.person = [TCJPerson new];
    self.student = [TCJStudent shareInstance];
    
    self.person.writtenData = 0;
    self.person.totalData = 100;
    self.person.dateArray = [NSMutableArray arrayWithCapacity:1];
    
    // OC -> c 超集
    [self.person addObserver:self forKeyPath:@"name" options:(NSKeyValueObservingOptionNew) context:NULL];
    [self.person addObserver:self forKeyPath:@"nick" options:(NSKeyValueObservingOptionNew) context:NULL];
    
    // 1: context -- 多个对象 - 相同keypath
    // 更加便利 - 更加安全 - 直接
    [self.student addObserver:self forKeyPath:@"name" options:(NSKeyValueObservingOptionNew | NSKeyValueObservingOptionOld) context:StudentNameContext];
    // 2: 一定要移除观察
    // 3: 一般做法 - 往复改的需求 删掉代码
    // 4: 多个因素影响 - 下载进度 = 当前下载量 / 总量
    [self.person addObserver:self forKeyPath:@"downloadProgress" options:(NSKeyValueObservingOptionNew) context:NULL];
    // 5: 可变数组 KVO --
    [self.person addObserver:self forKeyPath:@"dateArray" options:(NSKeyValueObservingOptionNew) context:NULL];
}

- (void)pushVC{
    
    [self.navigationController pushViewController:[TCJDetailViewController new] animated:YES];
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSKeyValueChangeKey,id> *)change context:(void *)context
{
    NSLog(@"TCJViewController - %@",change);
    
//    if ([keyPath isEqualToString:@"name"]) {
//        NSLog(@"%@", change);
//    }
//    if (context == PersonNameContext) {
//        NSLog(@"%@", change);
//    } else if (context == PersonNickContext) {
//        NSLog(@"%@", change);
//    }else if (context == StudentNameContext) {
//        NSLog(@"%@", change);
//    }
//    if ([keyPath isEqualToString:@"process"]) {
//        NSLog(@"%@", change);
//    }
//    if ([keyPath isEqualToString:@"dataArray"]) {
//        NSLog(@"%@", change);
//    }
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
{
    self.person.name  = @"null";
    self.person.nick  = @"Nil";
    self.student.name = @"葵花宝典";
    
    // 展开 - 折叠 -
    self.person.writtenData += 10;
    self.person.totalData += 20;
    
    // 数组变化
    [self.person.dateArray addObject:@"1"];
    // KVO 建立在 KVC
    [[self.person mutableArrayValueForKey:@"dateArray"] addObject:@"2"];
}

- (void)dealloc{
    [self.person removeObserver:self forKeyPath:@"name"];
    [self.person removeObserver:self forKeyPath:@"nick"];
    [self.student removeObserver:self forKeyPath:@"name"];

}

@end
