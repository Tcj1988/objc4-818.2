//
//  ViewController.m
//  ③ - 内存平移
//
//  Created by tangchangjiang on 2021/1/23.
//
#ifdef DEBUG
#define CJNSLog(format, ...) printf("%s\n", [[NSString stringWithFormat:format, ## __VA_ARGS__] UTF8String]);
#else
#define CJNSLog(format, ...);
#endif

#import "ViewController.h"

@interface TCJPerson : NSObject
@property (nonatomic, copy) NSString *cj_name;
- (void)saySomething;
@end

@implementation TCJPerson
- (void)saySomething{
    CJNSLog(@"当前打印内容为%s - %@", __func__,self.cj_name);
}
@end

@interface ViewController ()

@end

@implementation ViewController

// 高地址 -> 低地址
void cjFunction(id person, id cjSel, id cjSel2){
    CJNSLog(@"person = %p",&person);
    CJNSLog(@"person = %p",&cjSel);
    CJNSLog(@"person = %p",&cjSel2);
}


// 1: 参数 会从前往后一直压
// 2: 结构体的属性 是怎么一个压栈情况 self superclass

struct cj_struct{
    NSNumber *num1;
    NSNumber *num2;
} cj_struct;

- (void)viewDidLoad {
    [super viewDidLoad];
    // ViewController 当前的类
    // self cmd (id)class_getSuperclass(objc_getClass("TCJPerson")) self cls kc person
    Class cls = [TCJPerson class];
    void *obj= &cls;
    TCJPerson *person = [TCJPerson alloc];
    CJNSLog(@"%p - %p",&person,obj);
    // 隐藏参数 会压入栈帧
    void *sp  = (void *)&self;
    void *end = (void *)&person;
    long count = (sp - end) / 0x8;

    for (long i = 0; i<count; i++) {
        void *address = sp - 0x8 * i;
        if ( i == 1) {
            CJNSLog(@"%p : %s",address, *(char **)address);
        }else{
            CJNSLog(@"%p : %@",address, *(void **)address);
        }
    }
    [(__bridge id)obj saySomething];
    [person saySomething];
}

@end


