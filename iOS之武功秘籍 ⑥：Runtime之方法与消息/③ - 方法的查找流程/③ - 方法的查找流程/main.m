//
//  main.m
//  ③ - 方法的查找流程
//
//  Created by tangchangjiang on 2021/2/17.
//

#import <Foundation/Foundation.h>
#import "TCJStudent.h"

int main(int argc, const char * argv[]) {
    @autoreleasepool {
#pragma clang diagnostic push
// 让编译器忽略错误
#pragma clang diagnostic ignored "-Wundeclared-selector"
        TCJStudent *studend = [TCJStudent alloc];
        //对象方法
        [studend sayHello];
        [studend sayNB];
//        [studend sayMaster];
        
        // 类方法
        
        [TCJStudent sayObjc];
        [TCJStudent sayHappay];
        [TCJStudent performSelector:@selector(sayEasy)]; // +
        
#pragma clang diagnostic pop
    }
    return 0;
}
