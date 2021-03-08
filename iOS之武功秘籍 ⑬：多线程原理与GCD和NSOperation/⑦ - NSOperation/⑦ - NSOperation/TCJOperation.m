//
//  TCJOperation.m
//  ⑦ - NSOperation
//
//  Created by tangchangjiang on 2021/1/27.
//
#ifdef DEBUG
#define CJNSLog(format, ...) printf("%s\n", [[NSString stringWithFormat:format, ## __VA_ARGS__] UTF8String]);
#else
#define CJNSLog(format, ...);
#endif
#import "TCJOperation.h"

@implementation TCJOperation
//告知要执行的任务是什么
//1.有利于代码隐蔽
//2.复用性
-(void)main
{
    CJNSLog(@"main---%@",[NSThread currentThread]);
}
@end
