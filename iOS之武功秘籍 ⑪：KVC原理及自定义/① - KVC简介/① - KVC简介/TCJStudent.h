//
//  TCJStudent.h
//  ① - KVC简介
//
//  Created by tangchangjiang on 2020/9/16.
//  Copyright © 2020 tangchangjiang. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface TCJStudent : NSObject
@property (nonatomic, copy) NSString *name;
@property (nonatomic, copy) NSString *subject;
@property (nonatomic, copy) NSString *nick;
@property (nonatomic, assign) NSInteger age;
@property (nonatomic, assign) NSInteger length;
@property (nonatomic, strong) NSMutableArray *penArr;
@end

NS_ASSUME_NONNULL_END
