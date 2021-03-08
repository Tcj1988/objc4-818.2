//
//  TCJPerson.h
//  ② - KVO原理探讨
//
//  Created by tangchangjiang on 2020/9/16.
//  Copyright © 2020 tangchangjiang. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface TCJPerson : NSObject{
    @public
    NSString *name;
}
@property (nonatomic, copy) NSString *nickName;

- (void)sayHello;
- (void)sayLove;

@end

NS_ASSUME_NONNULL_END
