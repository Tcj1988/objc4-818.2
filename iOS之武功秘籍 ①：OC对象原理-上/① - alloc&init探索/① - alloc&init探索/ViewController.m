//
//  ViewController.m
//  ① - alloc&init探索
//
//  Created by tangchangjiang on 2020/9/18.
//

#ifdef DEBUG
#define CJNSLog(format, ...) printf("%s\n", [[NSString stringWithFormat:format, ## __VA_ARGS__] UTF8String]);
#else
#define CJNSLog(format, ...);
#endif

#import "ViewController.h"
#import "TCJPerson.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    // 熟悉的入手 - 对象
    // alloc 做了什么
    // init 做了什么
    
    // alloc 是怎么开辟内存的?
    // 栈内存 是连续的?
    // 8 指针
    
    TCJPerson *p1 = [TCJPerson alloc];
    TCJPerson *p2 = [p1 init];
    TCJPerson *p3 = [p1 init];
    TCJPerson *p4 = [TCJPerson new];
    CJNSLog(@"%@ - %p - %p",p1,p1,&p1);
    CJNSLog(@"%@ - %p - %p",p2,p2,&p2);
    CJNSLog(@"%@ - %p - %p",p3,p3,&p3);
    CJNSLog(@"%@ - %p - %p",p4,p4,&p4);
}


@end
