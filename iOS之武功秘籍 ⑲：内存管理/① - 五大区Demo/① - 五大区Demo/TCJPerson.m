//
//  TCJPerson.m
//  ① - 五大区Demo
//
//  Created by tangchangjiang on 2021/2/7.
//

#import "TCJPerson.h"

@implementation TCJPerson
- (void)run{
    personNum ++;
    NSLog(@"TCJPerson内部:%@-%p--%d",self,&personNum,personNum);
}

+ (void)eat{
    personNum ++;
    NSLog(@"TCJPerson内部:%@-%p--%d",self,&personNum,personNum);
}

- (NSString *)description{
    return @"";
}
@end
