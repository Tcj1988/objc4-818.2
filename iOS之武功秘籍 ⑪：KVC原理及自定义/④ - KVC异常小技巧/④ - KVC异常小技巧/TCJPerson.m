//
//  TCJPerson.m
//  ④ - KVC异常小技巧
//
//  Created by tangchangjiang on 2020/9/16.
//  Copyright © 2020 tangchangjiang. All rights reserved.
//

#import "TCJPerson.h"

@implementation TCJPerson
- (void)setNilValueForKey:(NSString *)key{
    NSLog(@"你傻不傻: 设置 %@ 是空值",key);
}

- (void)setValue:(id)value forUndefinedKey:(NSString *)key{
    NSLog(@"你瞎啊: %@ 没有这个key",key);
}

- (id)valueForUndefinedKey:(NSString *)key{
    NSLog(@"你瞎啊: %@ 没有这个key - 给你一个其他的吧,别奔溃了!",key);
    return @"葵花宝典 牛逼";
}

//MARK: - 键值验证 - 容错 - 派发 - 消息转发

- (BOOL)validateValue:(inout id  _Nullable __autoreleasing *)ioValue forKey:(NSString *)inKey error:(out NSError *__autoreleasing  _Nullable *)outError{
    if([inKey isEqualToString:@"name"]){
        [self setValue:[NSString stringWithFormat:@"里面修改一下: %@",*ioValue] forKey:inKey];
        return YES;
    }
    *outError = [[NSError alloc]initWithDomain:[NSString stringWithFormat:@"%@ 不是 %@ 的属性",inKey,self] code:10088 userInfo:nil];
    return NO;
}

@end
