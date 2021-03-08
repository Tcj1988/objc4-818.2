//
//  ViewController.m
//  ③ - TraceDemo
//
//  Created by tangchangjiang on 2021/2/5.
//

#import "ViewController.h"
#include <stdint.h>
#include <stdio.h>
#include <sanitizer/coverage_interface.h>
#import <libkern/OSAtomic.h>
#import <dlfcn.h>
#import "③ - TraceDemo-Swift.h"//$(SWIFT_MODULE_NAME)

@interface ViewController ()

@end

@implementation ViewController

//定义原子队列: 特点 1.先进后出 2.线程安全 3.只能保存结构体
static OSQueueHead symbolList = OS_ATOMIC_QUEUE_INIT;

//定义符号结构体链表
typedef struct{
    void *pc;
    void *next;
} SymbolNode;

+ (void)load{
    [SwiftTest swiftTest];
}

void test()
{
    block();
}

void(^block)(void) = ^(void){
    
};

- (void)viewDidLoad {
    [super viewDidLoad];
    
    test();
}

/*
 - start：起始位置
 - stop：并不是最后一个符号的地址，而是整个符号表的最后一个地址，最后一个符号的地址=stop-4（因为是从高地址往低地址读取的，且stop是一个无符号int类型，占4个字节）。stop存储的值是符号的
 */
void __sanitizer_cov_trace_pc_guard_init(uint32_t *start, uint32_t *stop) {
  static uint64_t N;  // Counter for the guards.
  if (start == stop || *start) return;  // Initialize only once.
  printf("INIT: %p %p\n", start, stop);
  for (uint32_t *x = start; x < stop; x++)
    *x = ++N;  // Guards should start from 1.
}

/*
 可以全面hook方法、函数、以及block调用，用于捕捉符号，是在多线程进行的，这个方法中只存储pc，以链表的形式
 
 - guard 是一个哨兵，告诉我们是第几个被调用的
 */
void __sanitizer_cov_trace_pc_guard(uint32_t *guard) {
//  if (!*guard) return;  // Duplicate the guard check. //将load方法过滤掉了，所以需要注释掉
    
    //获取PC
    /*
     - PC 当前函数返回上一个调用的地址
     - 0 当前这个函数地址，即当前函数的返回地址
     - 1 当前函数调用者的地址，即上一个函数的返回地址
    */
  void *PC = __builtin_return_address(0);
    
    //创建结构体!
  SymbolNode * node = malloc(sizeof(SymbolNode));
    *node = (SymbolNode){PC, NULL};
    
    
    //加入队列
    //符号的访问不是通过下标访问，是通过链表的next指针，所以需要借用offsetof（结构体类型，下一个的地址即next）
    OSAtomicEnqueue(&symbolList, node, offsetof(SymbolNode, next));
    
    Dl_info info;// 声明对象
    dladdr(PC, &info);// 读取PC地址，赋值给info
    
    /*
     dli_fname - 函数的路径
     dli_fname - 函数的地址
     dli_sname - 函数符号
     dli_saddr - 函数起始地址
     */
//    printf("fnam:%s \n fbase:%p \n sname:%s \n saddr:%p \n",
//           info.dli_fname,
//           info.dli_fname,
//           info.dli_sname,
//           info.dli_saddr);

}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event{
    
    NSMutableArray <NSString *>* symbolNames = [NSMutableArray array];
    
    // 每次while循环，都会加入一次hook (__sanitizer_cov_trace_pc_guard)   只要是跳转，就会被block
    // 直接修改[other c clang]: -fsanitize-coverage=func,trace-pc-guard 指定只有func才加Hook
    while (YES) {
        // 去除链表
        SymbolNode * node = OSAtomicDequeue(&symbolList, offsetof(SymbolNode, next));
        
        if (node == NULL) {
            break;
        }
        
        Dl_info info = {0};
        // 取出节点的pc,赋值给info
        dladdr(node->pc, &info);
        // 释放节点
        free(node);
        // 存名字
        NSString * name = @(info.dli_sname);
        
        BOOL isObjc = [name hasPrefix:@"+["] || [name hasPrefix:@"-["]; //OC方法不处理
        NSString * symbolName = isObjc ? name : [@"_" stringByAppendingString:name]; //c函数、swift方法前面带下划线
        [symbolNames addObject:symbolName];
        printf("%s \n",info.dli_sname);

    }
    
    //取反（队列的存储是反序的）
    NSEnumerator * emt = [symbolNames reverseObjectEnumerator];
    //创建数组
    NSMutableArray<NSString*>* funcs = [NSMutableArray arrayWithCapacity:symbolNames.count];
    // 临时变量
    NSString * name;
    // 遍历集合，去重，添加到funcs中
    while (name = [emt nextObject]) {
        // 数组中去重添加
        if (![funcs containsObject:name]) {
            [funcs addObject:name];
        }
    }
    // 删掉当前方法，因为这个点击方法不是启动需要的
    [funcs removeObject:[NSString stringWithFormat:@"%s",__FUNCTION__]];
    // 文件路径
    NSString * filePath = [NSTemporaryDirectory() stringByAppendingPathComponent:@"tcj.order"];
    // 数组转字符串
    NSString *funcStr = [funcs componentsJoinedByString:@"\n"];
    // 文件内容
    NSData * fileContents = [funcStr dataUsingEncoding:NSUTF8StringEncoding];
    // 在路径上创建文件
    [[NSFileManager defaultManager] createFileAtPath:filePath contents:fileContents attributes:nil];
    
    NSLog(@"%@",filePath);

}

@end
