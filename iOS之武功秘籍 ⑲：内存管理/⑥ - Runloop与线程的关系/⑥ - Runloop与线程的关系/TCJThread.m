//
//  TCJThread.m
//  ⑥ - Runloop与线程的关系
//
//  Created by tangchangjiang on 2021/2/9.
//

#import "TCJThread.h"

@implementation TCJThread
- (void)dealloc{
    NSLog(@"%s---线程销毁了",__func__);
}
@end
