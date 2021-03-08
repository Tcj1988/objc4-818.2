//
//  TCJPerson.h
//  ② - KVC取值&赋值过程
//
//  Created by tangchangjiang on 2020/9/16.
//  Copyright © 2020 tangchangjiang. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "TCJStudent.h"

NS_ASSUME_NONNULL_BEGIN

@interface TCJPerson : NSObject{
    @public
//     NSString *_name;
//     NSString *_isName;
//     NSString *name;
     NSString *isName;
}

@property (nonatomic, strong) NSArray *arr;
@property (nonatomic, strong) NSSet *set;

@property (nonatomic, strong) NSMutableArray *namesArrM;
@property (nonatomic, strong) NSMutableSet *namesSetM;
@property (nonatomic, strong) NSMutableOrderedSet *orderedSetM;

@end

NS_ASSUME_NONNULL_END
