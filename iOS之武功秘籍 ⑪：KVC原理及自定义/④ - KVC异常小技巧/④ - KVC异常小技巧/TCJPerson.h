//
//  TCJPerson.h
//  ④ - KVC异常小技巧
//
//  Created by tangchangjiang on 2020/9/16.
//  Copyright © 2020 tangchangjiang. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN
typedef struct {
    float x, y, z;
} ThreeFloats;

@interface TCJPerson : NSObject{
    @public
    NSString *name;
    NSString *_name;
    NSString *_isName;
    NSString *isName;
}

@property (nonatomic, copy) NSString *subject;
@property (nonatomic, assign) int  age;
@property (nonatomic, assign) BOOL sex;
@property (nonatomic) ThreeFloats  threeFloats;

@end

NS_ASSUME_NONNULL_END
