//
//  StoreboardView.h
//  PassengerService
//
//  Created by tangchangjiang on 2018/11/2.
//  Copyright © 2018 tangchangjiang. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

IB_DESIGNABLE

@interface StoreboardView : UIView

/** 边框宽度 */
@property (nonatomic, assign) IBInspectable float borderWidth;

/** 边框宽度 */
@property (nonatomic, retain) IBInspectable UIColor* borderColor;

/** 圆角 */
@property (nonatomic, assign) IBInspectable float cornerRadius;

@end

NS_ASSUME_NONNULL_END
