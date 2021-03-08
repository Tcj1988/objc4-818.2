//
//  TCJPerson+TCJ.m
//  ① - 五大区Demo
//
//  Created by tangchangjiang on 2021/2/7.
//

#import "TCJPerson+TCJ.h"

@implementation TCJPerson (TCJ)
- (void)cate_method{
    NSLog(@"TCJPerson内部:%@-%p--%d",self,&personNum,personNum);
}
@end
