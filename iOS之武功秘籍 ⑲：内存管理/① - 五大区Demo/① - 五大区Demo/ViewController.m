//
//  ViewController.m
//  ① - 五大区Demo
//
//  Created by tangchangjiang on 2021/2/7.
//
#ifdef DEBUG
#define CJNSLog(format, ...) printf("%s\n", [[NSString stringWithFormat:format, ## __VA_ARGS__] UTF8String]);
#else
#define CJNSLog(format, ...);
#endif

#import "ViewController.h"
#import "TCJPerson.h"
#import "TCJPerson+TCJ.h"

@interface ViewController ()

@end

@implementation ViewController

int clA;
int clB = 10;

static int bssA;
static NSString *bssStr1;

static int bssB = 10;
static NSString *bssStr2 = @"cj";
static NSString *cjname = @"TCJ";


- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    NSObject *obj = [NSObject alloc];
    
    CJNSLog(@"obj的内存地址：%p", obj);
    CJNSLog(@"&obj的内存地址：%p", &obj);
    
    [self testStack];
    [self testHeap];
    [self testConst];
}


- (void)testStack{
    NSLog(@"************栈区************");
    // 栈区
    int a = 10;
    int b = 20;
    NSObject *object = [NSObject new];
    NSLog(@"a == \t%p",&a);
    NSLog(@"b == \t%p",&b);
    NSLog(@"object == \t%p",&object);
    NSLog(@"%lu",sizeof(&object));
    NSLog(@"%lu",sizeof(a));
}

- (void)testHeap{
    NSLog(@"************堆区************");
    // 堆区
    NSObject *object1 = [NSObject new];
    NSObject *object2 = [NSObject new];
    NSObject *object3 = [NSObject new];
    NSObject *object4 = [NSObject new];
    NSObject *object5 = [NSObject new];
    NSObject *object6 = [NSObject new];
    NSObject *object7 = [NSObject new];
    NSObject *object8 = [NSObject new];
    NSObject *object9 = [NSObject new];
    NSLog(@"object1 = %@",object1);
    NSLog(@"object2 = %@",object2);
    NSLog(@"object3 = %@",object3);
    NSLog(@"object4 = %@",object4);
    NSLog(@"object5 = %@",object5);
    NSLog(@"object6 = %@",object6);
    NSLog(@"object7 = %@",object7);
    NSLog(@"object8 = %@",object8);
    NSLog(@"object9 = %@",object9);
    // 访问---通过对象->堆区地址->存在栈区的指针
}

- (void)testConst{
    
    // 面试:全局变量和局部变量在内存中是否有区别？如果有，是什么区别？
   
    
    // 面试:Block 是否可以直接修改全局变量 ?
//    [UIView animateWithDuration:1 animations:^{
//        cjname = @"TCJ";
//    }];
    
//    NSLog(@"cjname = %@",cjname);
    
    
    NSLog(@"************静态区************");
    NSLog(@"clA == \t%p",&clA);
    NSLog(@"bssA == \t%p",&bssA);
    NSLog(@"bssStr1 == \t%p",&bssStr1);
    
    NSLog(@"************常量区************");
    NSLog(@"clB == \t%p",&clB);
    NSLog(@"bssB == \t%p",&bssB);
    NSLog(@"bssStr2 == \t%p",&bssStr2);
    

    NSLog(@"************静态区安全测试************");
    // 100 可以修改
    // 只针对文件有效 -
    NSLog(@"vc:%p--%d",&personNum,personNum); // 100
    personNum = 10000;
    NSLog(@"vc:%p--%d",&personNum,personNum); // 10000
    [[TCJPerson new] run]; // 100 + 1 = 101
    NSLog(@"vc:%p--%d",&personNum,personNum); // 10000
    [TCJPerson eat]; // 102
    NSLog(@"vc:%p--%d",&personNum,personNum); // 10000
   
    [[TCJPerson alloc] cate_method];
    
}

@end
