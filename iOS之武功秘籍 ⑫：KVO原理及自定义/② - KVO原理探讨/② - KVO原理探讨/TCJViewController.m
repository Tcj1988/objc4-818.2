//
//  TCJViewController.m
//  ② - KVO原理探讨
//
//  Created by tangchangjiang on 2020/9/16.
//  Copyright © 2020 tangchangjiang. All rights reserved.
//

#import "TCJViewController.h"
#import "TCJPerson.h"
#import "TCJStudent.h"
#import <objc/runtime.h>

@interface TCJViewController ()
@property (nonatomic, strong) TCJPerson  *person;
@end

@implementation TCJViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.title = @"原理探讨";
    
    self.person = [[TCJPerson alloc] init];
    // 1: TCJPerson => NSKVONotifying_xxx(TCJPerson) 是什么关系 == 继承
    // 中间生成的是一个动态类
    // 但是修改的是 原对象的isa
    // 对象 还是 类
    //
    // 2: 实例变量 - 属性 -> setter
    // 3: 研究动态子类: isa superclass cache_t  bit - 方法 - 变量
    // 重写 setNickName (setter) class dealloc _isKVOA
    // class 还是返回的是 TCJPerson ()
    // dealloc
    // 4: 移除观察 isa 是否回来 ? YES
    // 5: 中间动态子类 是否销毁了 不销毁
    
    /**
     KVO 的原理
     1: 动态生成子类 : NSKVONotifying_xxx
     2: 观察的是 setter
     3: 动态子类重写了很多方法 setNickName (setter) class dealloc _isKVOA
     4: 移除观察的时候 isa 指向回来
     5: 动态子类不会销毁
     */
    
    [self printClasses:[TCJPerson class]];
    [self printClassAllMethod:[TCJPerson class]];
//    [self printClassAllMethod:[TCJStudent class]];
//    [[TCJStudent alloc] sayLove];

    [self.person addObserver:self forKeyPath:@"nickName" options:(NSKeyValueObservingOptionNew) context:NULL];

    [self printClasses:[TCJPerson class]];
    [self printClassAllMethod:NSClassFromString(@"NSKVONotifying_TCJPerson")];


    [self.person addObserver:self forKeyPath:@"name" options:(NSKeyValueObservingOptionNew) context:NULL];
}

#pragma mark - KVO回调
- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSKeyValueChangeKey,id> *)change context:(void *)context
{
    NSLog(@"TCJViewController - %@---%@",keyPath,change);

}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
{
    NSLog(@"实际情况:%@-%@",self.person.nickName,self.person->name);
    self.person.nickName = @"nickName";
    self.person->name    = @"name";
}

- (void)dealloc{
    [self.person removeObserver:self forKeyPath:@"name"];
    [self.person removeObserver:self forKeyPath:@"nickName"];
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
