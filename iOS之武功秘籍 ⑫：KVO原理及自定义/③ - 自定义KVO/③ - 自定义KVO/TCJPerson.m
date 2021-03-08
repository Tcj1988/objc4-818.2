//
//  TCJPerson.m
//  ③ - 自定义KVO
//
//  Created by tangchangjiang on 2020/9/17.
//  Copyright © 2020 tangchangjiang. All rights reserved.
//

#import "TCJPerson.h"

@implementation TCJPerson

static TCJPerson *_instance = nil;

+ (instancetype)shareInstance{
    static dispatch_once_t onceToken ;
    dispatch_once(&onceToken, ^{
        _instance = [[super allocWithZone:NULL] init] ;
    }) ;
    return _instance ;
}

+(id)allocWithZone:(struct _NSZone *)zone{
    return [TCJPerson shareInstance] ;
}

-(id)copyWithZone:(struct _NSZone *)zone{
    return [TCJPerson shareInstance] ;
}

- (void)setNickName:(NSString *)nickName{
    NSLog(@"来到 TCJPerson 的setter方法 :%@",nickName);
    _nickName = nickName;
}
@end
