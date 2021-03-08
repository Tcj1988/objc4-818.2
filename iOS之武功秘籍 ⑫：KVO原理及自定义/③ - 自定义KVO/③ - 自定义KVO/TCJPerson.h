//
//  TCJPerson.h
//  ③ - 自定义KVO
//
//  Created by tangchangjiang on 2020/9/17.
//  Copyright © 2020 tangchangjiang. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface TCJPerson : NSObject{
    @public
    NSString *name;
}
@property (nonatomic, copy) NSString *nickName;

+ (instancetype)shareInstance;

@end

NS_ASSUME_NONNULL_END
