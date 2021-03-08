//
//  ViewController.m
//  ② - TaggedPointerDemo
//
//  Created by tangchangjiang on 2021/2/7.
//

#ifdef DEBUG
#define CJNSLog(format, ...) printf("%s\n", [[NSString stringWithFormat:format, ## __VA_ARGS__] UTF8String]);
#else
#define CJNSLog(format, ...);
#endif

#import "ViewController.h"
#import <objc/runtime.h>

extern uintptr_t objc_debug_taggedpointer_obfuscator;

@interface ViewController ()
@property (nonatomic, strong) dispatch_queue_t queue;
@property (nonatomic, strong) NSString *nameStr;
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.queue = dispatch_queue_create("com.tcj.cn", DISPATCH_QUEUE_CONCURRENT);

//    [self taggedPointerDemo];
//    [self testNormal];
//    [self testNSString];
    
    NSObject *objc = [NSObject alloc];
    CJNSLog(@"%ld",CFGetRetainCount((__bridge CFTypeRef)objc));
//    CJNSLog(@"%ld",CFGetRetainCount((__bridge CFTypeRef)objc)); // 2
//    CJNSLog(@"%ld",CFGetRetainCount((__bridge CFTypeRef)objc)); // 3

    // alloc 引用计数为多少 : 0
    // extrc
    // 1
    
    // taggedpointer 指针 : 指针 + 值
    // 对象 string 值 + 指针
    // 小对象: number1 date 11
    // 一个对象: 8字节 * 8位 = 64位
    // 象棋
    // @"";
    // 10000000000000000000000000000000000
//    NSString *str1 = [NSString stringWithFormat:@"a"];
//    NSString *str2 = [NSString stringWithFormat:@"b"];
//    NSString *str3 = [[NSString alloc] initWithFormat:@"c"];
//    NSString *str4 = [[NSString alloc] initWithFormat:@"cccccccccccccccccccc"];
//
//    CJNSLog(@"%p-%@",str1,str1);
//    CJNSLog(@"%p-%@",str2,str2);
//    CJNSLog(@"0x%lx",_objc_decodeTaggedPointer_(str2));
    // 0xa000000000000621
    // 地址: 包含了值
    // 0xb000000000000012
    // 0xb000000000000025
    // 特殊的含义
    // 0xb 0xa 判断条件 是否taggedpointer
    // 0xa string 1 010  2 tagtype
    // 0xb int    1 011  3
    // 小对象
    // 地址 + 值 -
    // 不进去 直接释放回收
    // 效率: 3倍 100倍

//    NSNumber *number1 = @1;
//    NSNumber *number2 = @(-1); // 0xbffffffffffffff2
//    NSNumber *number3 = @2.0;
//    NSNumber *number4 = @3.2;
//    CJNSLog(@"%@-%p-%@",object_getClass(number1),number1,number1);
//    CJNSLog(@"%@-%p-%@",object_getClass(number2),number2,number2);
//    CJNSLog(@"%@-%p-%@",object_getClass(number3),number3,number3);
//    CJNSLog(@"%@-%p-%@",object_getClass(number4),number4,number4);
//
//    CJNSLog(@"%@-%p-%@ - 0x%lx",object_getClass(number1),number1,number1,_objc_decodeTaggedPointer_(number1));
//    CJNSLog(@"0x%lx",_objc_decodeTaggedPointer_(number2)); // 0xb000000000000012
//    CJNSLog(@"0x%lx",_objc_decodeTaggedPointer_(number3));
//    CJNSLog(@"0x%lx",_objc_decodeTaggedPointer_(number4));
//
//    NSDate *date = [NSDate date];
//    CJNSLog(@"%@ - 0x%lx",object_getClass(date),_objc_decodeTaggedPointer_(date));
}

uintptr_t
_objc_decodeTaggedPointer_(id ptr)
{
    return (uintptr_t)ptr ^ objc_debug_taggedpointer_obfuscator;
}

- (void)taggedPointerDemo {
  
    for (int i = 0; i<10000; i++) {
        dispatch_async(self.queue, ^{
            self.nameStr = [NSString stringWithFormat:@"tcj"];  // alloc 堆 iOS优化 - taggedpointer
            CJNSLog(@"%@",self.nameStr);
        });
    }
}

- (void)testNormal {
    // objc_release
    // setter
    // retain release 多条线程 同时对一个对象释放 - 过渡释放
    for (int i = 0; i<10000; i++) {
        dispatch_async(self.queue, ^{
            self.nameStr = [NSString stringWithFormat:@"又一黑马诞生12345"];
            CJNSLog(@"%@",self.nameStr);
        });
    }
}

#define TCJNSLog(_c) CJNSLog(@"%@ -- %p -- %@",_c,_c,[_c class]);
- (void)testNSString{
    //初始化方式一：通过 WithString + @""方式
    NSString *s1 = @"1";
    NSString *s2 = [[NSString alloc] initWithString:@"222"];
    NSString *s3 = [NSString stringWithString:@"33"];
    
    TCJNSLog(s1);
    TCJNSLog(s2);
    TCJNSLog(s3);
    
    //初始化方式二：通过 WithFormat
    //字符串长度在9以内
    NSString *s4 = [NSString stringWithFormat:@"123456789"];
    NSString *s5 = [[NSString alloc] initWithFormat:@"123456789"];
    
    //字符串长度大于9
    NSString *s6 = [NSString stringWithFormat:@"1234567890"];
    NSString *s7 = [[NSString alloc] initWithFormat:@"1234567890"];
    
    TCJNSLog(s4);
    TCJNSLog(s5);
    TCJNSLog(s6);
    TCJNSLog(s7);
}

@end
