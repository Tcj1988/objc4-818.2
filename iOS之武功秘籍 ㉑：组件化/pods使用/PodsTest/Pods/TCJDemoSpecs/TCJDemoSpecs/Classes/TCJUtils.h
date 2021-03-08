//
//  TCJUtils.h
//
//
//  Created by tangchangjiang on 2020/7/13.
//  Copyright © 2020 tangchangjiang. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface TCJUtils : NSObject
#pragma mark - 颜色
+ (UIColor *)colorFromHexRGB:(NSString *)inColorString;
#pragma mark - 图片压缩
+ (NSData *)resetSizeOfImageData:(UIImage *)sourceImage maxSize:(NSInteger)maxSize;
#pragma mark - NSDictionary转换json
+ (NSString *)convertToJsonData:(NSDictionary *)dict;
#pragma mark - json转换NSDictionary
+ (NSDictionary *)dictionaryWithJsonString:(NSString *)jsonString;
#pragma mark - String格式化处理
+ (NSString *)stringIfNull:(NSString *)string;
#pragma mark - 保存图片到本地
+ (BOOL)saveImage:(UIImage *)image imageName:(NSString *)name;
#pragma mark - 获取本地图片
+ (UIImage *)getImageWithName:(NSString *)name;
#pragma mark - 获取Bundle的图片
+ (UIImage *)getToolsBundleImage:(NSString *)imageName;
#pragma mark - 提示信息框
+ (void)alertWith:(NSString *)message;
#pragma mark - 判断字符串是否为空
+ (BOOL)isBlankString:(NSString *)aStr;
#pragma mark - 判断数组是否为空
+ (BOOL)isBlankArr:(NSArray *)arr;
#pragma mark - 判断字典是否为空
+ (BOOL)isBlankDictionary:(NSDictionary *)dic;
#pragma mark - 保留两位小数
+ (NSString *)returnFormatter:(NSString *)stringNumber;
#pragma mark - 保留1位小数
+ (NSString *)returnFormatterOne:(NSString *)stringNumber;
#pragma mark - 中划线
+ (NSString *)returnMiddleline:(NSString *)string;
#pragma mark - 截取小数点后两位
+ (NSString*)getTheCorrectNum:(NSString*)tempString;
#pragma mark - 是否同意
+ (void)saveIsAgree:(BOOL)type;
+ (BOOL)queryIsAgree;

#pragma mark - yyyy年MM月dd日 HH:mm:ss
+ (NSString *)convertStrToTime:(NSString *)timeStr;

#pragma mark - 将JSON串转化为字典或者数组
+ (id)toArrayOrNSDictionary:(NSString *)jsonStr;

#pragma mark - 字典/数组转json
+ (NSString *)getCurrentJsonString:(id)dict;
@end

NS_ASSUME_NONNULL_END
