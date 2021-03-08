//
//  TCJPerson.h
//  ① - KVO初探
//
//  Created by tangchangjiang on 2020/9/16.
//  Copyright © 2020 tangchangjiang. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN
@class TCJStudent;
@interface TCJPerson : NSObject
@property (nonatomic, copy) NSString *name;
@property (nonatomic, copy) NSString *nick;
@property (nonatomic, copy) NSString *downloadProgress;
@property (nonatomic, assign) double writtenData;
@property (nonatomic, assign) double totalData;
@property (nonatomic, strong) NSMutableArray *dateArray;
@property (nonatomic, strong) TCJStudent *st;
@end

NS_ASSUME_NONNULL_END
