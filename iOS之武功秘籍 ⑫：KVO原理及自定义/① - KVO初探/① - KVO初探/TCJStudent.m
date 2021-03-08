//
//  TCJStudent.m
//  ① - KVO初探
//
//  Created by tangchangjiang on 2020/9/16.
//  Copyright © 2020 tangchangjiang. All rights reserved.
//

#import "TCJStudent.h"

@implementation TCJStudent

//@synthesize name = _name;

static TCJStudent* _instance = nil;
+ (instancetype)shareInstance{
    static dispatch_once_t onceToken ;
    dispatch_once(&onceToken, ^{
        _instance = [[super allocWithZone:NULL] init] ;
    }) ;
    return _instance ;
}

//+(id)allocWithZone:(struct _NSZone *)zone{
//    return [TCJStudent shareInstance] ;
//}
//
//-(id)copyWithZone:(struct _NSZone *)zone{
//    return [TCJStudent shareInstance] ;
//}

//+ (BOOL)automaticallyNotifiesObserversForKey:(NSString *)key {
//    if ([key isEqualToString:@"name"]) {
//        return YES;
//    }
//    return [super automaticallyNotifiesObserversForKey:key];
//}

//- (void)setName:(NSString *)name {
//    [self willChangeValueForKey:@"name"];
//    _name= name;
//    [self didChangeValueForKey:@"name"];
//}

@end
