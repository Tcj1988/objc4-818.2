//
//  main.m
//  ③ - 系统内存开辟分析
//
//  Created by tangchangjiang on 2020/9/24.
//

#import <Foundation/Foundation.h>
#import "TCJPerson.h"
#import <objc/runtime.h>
#import <malloc/malloc.h>

int main(int argc, const char * argv[]) {
    @autoreleasepool {
        // insert code here...
        
        // 16字节对齐
        // class_getInstanceSize 对象需要的真正的内存 40 8字节对齐
        // 16字节对齐 苹果方向 128 512
        // malloc_size 非常简单 分享一个方法 源码阅读技巧
        
        TCJPerson *person = [TCJPerson alloc];
        person.name      = @"TCJ";
        person.nickName  = @"CJ";
        NSLog(@"%@ - %lu - %lu - %lu",person,sizeof(person),class_getInstanceSize([TCJPerson class]),malloc_size((__bridge const void *)(person)));
    }
    return 0;
}
