//
//  TCJDog.m
//  ① - KVO初探
//
//  Created by tangchangjiang on 2020/9/16.
//  Copyright © 2020 tangchangjiang. All rights reserved.
//

#import "TCJDog.h"

@implementation TCJDog
- (NSString *)description{
    return [NSString stringWithFormat:@"%@-%d",self.name,self.age];
}
@end
