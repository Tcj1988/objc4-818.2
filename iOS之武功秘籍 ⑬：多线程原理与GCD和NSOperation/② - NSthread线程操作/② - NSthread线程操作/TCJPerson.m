//
//  TCJPerson.m
//  ② - NSthread线程操作
//
//  Created by tangchangjiang on 2021/1/26.
//

#import "TCJPerson.h"

@implementation TCJPerson
- (void)study:(id)time{
    for (int i = 0; i<[time intValue]; i++) {
        NSLog(@"%@ 开始学习了 %d分钟",[NSThread currentThread],i);
    }
}
@end
