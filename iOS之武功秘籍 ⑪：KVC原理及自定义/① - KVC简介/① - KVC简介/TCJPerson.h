//
//  TCJPerson.h
//  ① - KVC简介
//
//  Created by tangchangjiang on 2020/9/16.
//  Copyright © 2020 tangchangjiang. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "TCJStudent.h"

NS_ASSUME_NONNULL_BEGIN

typedef struct {
    float x, y, z;
} ThreeFloats;

@interface TCJPerson : NSObject{
    @public
    NSString *myName;
}
@property (nonatomic, copy) NSString *name;
@property (nonatomic, strong) NSArray *array;
@property (nonatomic, strong) NSMutableArray *mArray;
@property (nonatomic, assign) NSInteger  age;
@property (nonatomic) ThreeFloats threeFloats;
@property (nonatomic, strong) TCJStudent *student;
@end

NS_ASSUME_NONNULL_END
