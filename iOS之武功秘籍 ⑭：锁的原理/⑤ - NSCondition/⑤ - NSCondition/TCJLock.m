//
//  TCJLock.m
//  ⑤ - NSCondition
//
//  Created by tangchangjiang on 2021/1/21.
//

#import "TCJLock.h"

@interface TCJLock ()<NSLocking>
@property (nonatomic, strong) NSCondition *testCondition;
@end

@implementation TCJLock
- (instancetype)init
{
    self = [super init];
    if (self) {
        _testCondition = [NSCondition new];
        _value = 2;
    }
    return self;
}

- (void)cjlockWithCondition:(int)condition {
    [_testCondition lock];
    while (_thread != nil || _value != condition) {
        if (![_testCondition waitUntilDate:[NSDate distantPast]]) {
            [_testCondition unlock];
        }
    }
    _thread = [NSThread currentThread];
    [_testCondition unlock];
}

- (void)cjUnlockWithCondition:(int)condition {
    _value = condition;
    [_testCondition lock];
    _thread = nil;
    [_testCondition broadcast];
    [_testCondition unlock];
}
@end
