//
//  TCJViewController.m
//  ③ - 自定义KVO
//
//  Created by tangchangjiang on 2020/9/17.
//  Copyright © 2020 tangchangjiang. All rights reserved.
//

#import "TCJViewController.h"
#import "TCJPerson.h"
#import <objc/runtime.h>
#import "NSObject+TCJKVO.h"

@interface TCJViewController ()
@property (nonatomic, strong) TCJPerson  *person;
@end

@implementation TCJViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.title = @"自定义KVO";
    
    self.person = [[TCJPerson alloc] init];
    
    [self.person cj_addObserver:self forKeyPath:@"nickName" block:^(id  _Nonnull observer, NSString * _Nonnull keyPath, id  _Nonnull oldValue, id  _Nonnull newValue) {
        NSLog(@"%@-%@",oldValue,newValue);
    }];
    
    self.person.nickName = @"nickName";
}

#pragma mark - KVO回调
//- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSKeyValueChangeKey,id> *)change context:(void *)context
//{
//    NSLog(@"TCJViewController - %@",change);
//
//}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
{
    self.person.nickName = [NSString stringWithFormat:@"%@+",self.person.nickName];
}

- (void)dealloc{
    [self.person cj_removeObserver:self forKeyPath:@"nickName"];
}

#pragma mark - 遍历方法-ivar-property
- (void)printClassAllMethod:(Class)cls{
    NSLog(@"*********************");
    unsigned int count = 0;
    Method *methodList = class_copyMethodList(cls, &count);
    for (int i = 0; i<count; i++) {
        Method method = methodList[i];
        SEL sel = method_getName(method);
        IMP imp = class_getMethodImplementation(cls, sel);
        NSLog(@"%@-%p",NSStringFromSelector(sel),imp);
    }
    free(methodList);
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
    NSLog(@"classes = %@", mArray);
}

@end
