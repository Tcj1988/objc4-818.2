//
//  main.m
//  ⑤ - instrumentObjcMessageSends辅助分析
//
//  Created by tangchangjiang on 2021/2/18.
//

#import <Foundation/Foundation.h>
#import "TCJPerson.h"

// 慢速查找
extern void instrumentObjcMessageSends(BOOL flag);

int main(int argc, const char * argv[]) {
    @autoreleasepool {
        TCJPerson *person = [TCJPerson alloc];
        instrumentObjcMessageSends(YES);
        [person sayHello];
        instrumentObjcMessageSends(NO);
    }
    return 0;
}
