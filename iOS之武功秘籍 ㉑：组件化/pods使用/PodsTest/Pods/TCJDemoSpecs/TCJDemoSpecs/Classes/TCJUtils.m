//
//  TCJUtils.m
//
//
//  Created by tangchangjiang on 2020/7/13.
//  Copyright © 2020 tangchangjiang. All rights reserved.
//

#import "TCJUtils.h"

@implementation TCJUtils

#pragma mark - 颜色转换

+ (UIColor *)colorFromHexRGB:(NSString *)inColorString
{
    UIColor *result = nil;
    unsigned int colorCode = 0;
    unsigned char redByte, greenByte, blueByte;
    
    if (nil != inColorString)
    {
        NSScanner *scanner = [NSScanner scannerWithString:inColorString];
        (void) [scanner scanHexInt:&colorCode]; // ignore error
    }
    redByte = (unsigned char) (colorCode >> 16);
    greenByte = (unsigned char) (colorCode >> 8);
    blueByte = (unsigned char) (colorCode); // masks off high bits
    result = [UIColor
              colorWithRed: (float)redByte / 0xff
              green: (float)greenByte/ 0xff
              blue: (float)blueByte / 0xff
              alpha:1.0];
    
    return result;
}

#pragma mark - 图片压缩
+ (NSData *)resetSizeOfImageData:(UIImage *)sourceImage maxSize:(NSInteger)maxSize {
    //先判断当前质量是否满足要求，不满足再进行压缩
    __block NSData *finallImageData = UIImageJPEGRepresentation(sourceImage,1.0);
    NSUInteger sizeOrigin   = finallImageData.length;
    NSUInteger sizeOriginKB = sizeOrigin / 1000;
    
    if (sizeOriginKB <= maxSize) {
        return finallImageData;
    }
    
    //获取原图片宽高比
    CGFloat sourceImageAspectRatio = sourceImage.size.width/sourceImage.size.height;
    //先调整分辨率
    CGSize defaultSize = CGSizeMake(1024, 1024/sourceImageAspectRatio);
    UIImage *newImage = [TCJUtils newSizeImage:defaultSize image:sourceImage];
    
    finallImageData = UIImageJPEGRepresentation(newImage,1.0);
    
    //保存压缩系数
    NSMutableArray *compressionQualityArr = [NSMutableArray array];
    CGFloat avg   = 1.0/250;
    CGFloat value = avg;
    for (int i = 250; i >= 1; i--) {
        value = i*avg;
        [compressionQualityArr addObject:@(value)];
    }
    
    /*
     调整大小
     说明：压缩系数数组compressionQualityArr是从大到小存储。
     */
    //思路：使用二分法搜索
    finallImageData = [TCJUtils halfFuntion:compressionQualityArr image:newImage sourceData:finallImageData maxSize:maxSize];
    //如果还是未能压缩到指定大小，则进行降分辨率
    while (finallImageData.length == 0) {
        //每次降100分辨率
        CGFloat reduceWidth = 100.0;
        CGFloat reduceHeight = 100.0/sourceImageAspectRatio;
        if (defaultSize.width-reduceWidth <= 0 || defaultSize.height-reduceHeight <= 0) {
            break;
        }
        defaultSize = CGSizeMake(defaultSize.width-reduceWidth, defaultSize.height-reduceHeight);
        UIImage *image = [TCJUtils newSizeImage:defaultSize
                                      image:[UIImage imageWithData:UIImageJPEGRepresentation(newImage,[[compressionQualityArr lastObject] floatValue])]];
        finallImageData = [TCJUtils halfFuntion:compressionQualityArr image:image sourceData:UIImageJPEGRepresentation(image,1.0) maxSize:maxSize];
    }
    return finallImageData;
}

#pragma mark 调整图片分辨率/尺寸（等比例缩放）
+ (UIImage *)newSizeImage:(CGSize)size image:(UIImage *)sourceImage {
    CGSize newSize = CGSizeMake(sourceImage.size.width, sourceImage.size.height);
    
    CGFloat tempHeight = newSize.height / size.height;
    CGFloat tempWidth = newSize.width / size.width;
    
    if (tempWidth > 1.0 && tempWidth > tempHeight) {
        newSize = CGSizeMake(sourceImage.size.width / tempWidth, sourceImage.size.height / tempWidth);
    } else if (tempHeight > 1.0 && tempWidth < tempHeight) {
        newSize = CGSizeMake(sourceImage.size.width / tempHeight, sourceImage.size.height / tempHeight);
    }
    
    UIGraphicsBeginImageContext(newSize);
    [sourceImage drawInRect:CGRectMake(0,0,newSize.width,newSize.height)];
    UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return newImage;
}

#pragma mark 二分法
+ (NSData *)halfFuntion:(NSArray *)arr image:(UIImage *)image sourceData:(NSData *)finallImageData maxSize:(NSInteger)maxSize {
    NSData *tempData = [NSData data];
    NSUInteger start = 0;
    NSUInteger end = arr.count - 1;
    NSUInteger index = 0;
    
    NSUInteger difference = NSIntegerMax;
    while(start <= end) {
        index = start + (end - start)/2;
        
        finallImageData = UIImageJPEGRepresentation(image,[arr[index] floatValue]);
        
        NSUInteger sizeOrigin = finallImageData.length;
        NSUInteger sizeOriginKB = sizeOrigin / 1024;
        NSLog(@"当前降到的质量：%ld", (unsigned long)sizeOriginKB);
        NSLog(@"\nstart：%zd\nend：%zd\nindex：%zd\n压缩系数：%lf", start, end, (unsigned long)index, [arr[index] floatValue]);
        
        if (sizeOriginKB > maxSize) {
            start = index + 1;
        } else if (sizeOriginKB < maxSize) {
            if (maxSize-sizeOriginKB < difference) {
                difference = maxSize-sizeOriginKB;
                tempData = finallImageData;
            }
            if (index<=0) {
                break;
            }
            end = index - 1;
        } else {
            break;
        }
    }
    return tempData;
}

#pragma mark - NSDictionary转换json
+ (NSString *)convertToJsonData:(NSDictionary *)dict
{
    NSError *error;
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:dict options:NSJSONWritingPrettyPrinted error:&error];
    NSString *jsonString;
    if (!jsonData) {
        NSLog(@"%@",error);
    }else{
        jsonString = [[NSString alloc]initWithData:jsonData encoding:NSUTF8StringEncoding];
    }
    NSMutableString *mutStr = [NSMutableString stringWithString:jsonString];
    NSRange range = {0,jsonString.length};
    //去掉字符串中的空格
    [mutStr replaceOccurrencesOfString:@" " withString:@"" options:NSLiteralSearch range:range];
    NSRange range2 = {0,mutStr.length};
    //去掉字符串中的换行符
    [mutStr replaceOccurrencesOfString:@"\n" withString:@"" options:NSLiteralSearch range:range2];
    return mutStr;
}

#pragma mark - json转换NSDictionary
+ (NSDictionary *)dictionaryWithJsonString:(NSString *)jsonString
{
    if (jsonString == nil) {
        return nil;
    }
    
    NSData *jsonData = [jsonString dataUsingEncoding:NSUTF8StringEncoding];
    NSError *err;
    NSDictionary *dic = [NSJSONSerialization JSONObjectWithData:jsonData
                                                        options:NSJSONReadingMutableContainers
                                                          error:&err];
    if(err)
    {
        NSLog(@"json解析失败：%@",err);
        return nil;
    }
    return dic;
}

#pragma mark - String格式化处理
+ (NSString *)stringIfNull:(NSString *)string {
    NSString *ps = [NSString stringWithFormat:@"%@",string];
//    return ([string isEqual:[NSNull null]] || [string isKindOfClass:[NSNull class]] || string == nil) ? @"" : ps;
    return [TCJUtils isBlankString:string] ? @"" : ps;
}

#pragma mark - 保存图片到本地
+ (BOOL)saveImage:(UIImage *)image imageName:(NSString *)name {
    NSArray *paths =NSSearchPathForDirectoriesInDomains(NSDocumentDirectory,NSUserDomainMask,YES);
    
    NSString *filePath = [[paths objectAtIndex:0]stringByAppendingPathComponent:
                          name];  // 保存文件的名称
    BOOL result =[UIImagePNGRepresentation(image)writeToFile:filePath   atomically:YES]; // 保存成功会返回YES
    if (result == YES) {
        NSLog(@"保存成功");
    }
    return result;
}

#pragma mark - 获取本地图片
+ (UIImage *)getImageWithName:(NSString *)name {
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory,NSUserDomainMask, YES);
    
    NSString *filePath = [[paths objectAtIndex:0]stringByAppendingPathComponent:name];
    // 保存文件的名称
    UIImage *img = [UIImage imageWithContentsOfFile:filePath];
    return img;
}

#pragma mark - 获取Bundle的图片
+ (UIImage *)getToolsBundleImage:(NSString *)imageName {
    
    static NSBundle *bunble;
    if (bunble == nil) {
        
        bunble = [NSBundle bundleWithPath:[[NSBundle bundleForClass:[self class]].resourcePath stringByAppendingPathComponent:@"/TCJDemoSpecs.bundle"]];
    }
    
    UIImage *image = [UIImage imageNamed:imageName inBundle:bunble compatibleWithTraitCollection:nil];
    if (image == nil) {
        image = [UIImage imageNamed:imageName];
    }
    
    return image;
}

#pragma mark - 提示信息框
+ (void)alertWith:(NSString *)message{
    UIAlertView *alert = [[UIAlertView alloc]initWithTitle:message message:nil delegate:nil cancelButtonTitle:@"确定" otherButtonTitles: nil];
    [alert show];
}

#pragma mark - 判断字符串是否为空
+ (BOOL)isBlankString:(NSString *)aStr{
    if (!aStr) {
        return YES;
    }
    if ([[aStr class] isSubclassOfClass:[NSNull class]]) {
        return YES;
    }
    if ([aStr isKindOfClass:[NSNull class]]) {
        return YES;
    }
    if (!aStr.length) {
        return YES;
    }
    if (aStr == nil || aStr == NULL || [aStr isEqualToString:@"(null)"] || [aStr isEqualToString:@"null"] || [aStr isEqualToString:@""] || [aStr isEqual:[NSNull null]]) {
        return YES;
    }
    if ([aStr isKindOfClass:[NSString class]] && [[aStr stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]] length] == 0) {
        return YES;
    }
    
    return NO;
}

#pragma mark - 判断数组是否为空
+ (BOOL)isBlankArr:(NSArray *)arr{
    if (!arr) {
        return YES;
    }
    if ([arr isKindOfClass:[NSNull class]]) {
        return YES;
    }
    if (!arr.count) {
        return YES;
    }
    if (arr == nil) {
        return YES;
    }
    if (arr == NULL) {
        return YES;
    }
    if (![arr isKindOfClass:[NSArray class]]) {
        return YES;
    }
    
    return NO;
}

#pragma mark - 判断字典是否为空
+ (BOOL)isBlankDictionary:(NSDictionary *)dic{
    if (!dic) {
        return YES;
    }
    if ([dic isKindOfClass:[NSNull class]]) {
        return YES;
    }
    if (!dic.count) {
        return YES;
    }
    if (dic == nil) {
        return YES;
    }
    if (dic == NULL) {
        return YES;
    }
    if (![dic isKindOfClass:[NSDictionary class]]) {
        return YES;
    }
    
    return NO;
}
#pragma mark - 保留两位小数
+ (NSString *)returnFormatter:(NSString *)stringNumber{
    if ([TCJUtils isBlankString:stringNumber]) {
        return @"";
    }
    
    NSString *temp = [NSString stringWithFormat:@"%f",[stringNumber floatValue]/100];
    
    return [self getTheCorrectNum:temp];
    
}

#pragma mark - 保留1位小数
+ (NSString *)returnFormatterOne:(NSString *)stringNumber{
    if ([TCJUtils isBlankString:stringNumber]) {
        return @"";
    }
    
    return [NSString stringWithFormat:@"%0.1f",[stringNumber floatValue]/100];
}

#pragma mark - 截取小数点后两位
+ (NSString*)getTheCorrectNum:(NSString*)tempString
{
    //计算截取的长度
    NSUInteger endLength = tempString.length;
    //判断字符串是否包含 .
    if ([tempString containsString:@"."]) {
        //取得 . 的位置
        NSRange pointRange = [tempString rangeOfString:@"."];
//        NSLog(@"%lu",pointRange.location);
        //判断 . 后面有几位
        NSUInteger f = tempString.length - 1 - pointRange.location;
        //如果大于2位就截取字符串保留两位,如果小于两位,直接截取
        if (f > 2) {
            endLength = pointRange.location + 3;
        }
    }
    //先将tempString转换成char型数组
    NSUInteger start = 0;
//    const char *tempChar = [tempString UTF8String];
//    //遍历,去除取得第一位不是0的位置
//    for (int i = 0; i < tempString.length; i++) {
//        if (tempChar[i] == '0') {
//            start++;
//        }else {
//            break;
//        }
//    }
    //根据最终的开始位置,计算长度,并截取
    NSRange range = {start,endLength};
    tempString = [tempString substringWithRange:range];
    return tempString;
}

#pragma mark - 中划线
+ (NSMutableAttributedString *)returnMiddleline:(NSString *)string{
    if ([TCJUtils isBlankString:string]) {
        return nil;
    }
    NSDictionary *attribtDic = @{NSStrikethroughStyleAttributeName: [NSNumber numberWithInteger:NSUnderlineStyleSingle]};

    NSMutableAttributedString *attribtStr = [[NSMutableAttributedString alloc]initWithString:string attributes:attribtDic];
    
    return attribtStr;
}

#pragma mark - 是否同意
+ (void)saveIsAgree:(BOOL)type{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setBool:type forKey:@"ISAGREE"];
    [defaults synchronize];
}
+ (BOOL)queryIsAgree{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    BOOL isAgree = [defaults boolForKey:@"ISAGREE"];
    return isAgree;
}

+ (NSString *)convertStrToTime:(NSString *)timeStr

{
    long long time=[timeStr longLongValue];

    NSDate *d = [[NSDate alloc]initWithTimeIntervalSince1970:time];

    NSDateFormatter *formatter = [[NSDateFormatter alloc]init];

    [formatter setDateFormat:@"yyyy/MM/dd HH:mm:ss"];

    NSString*timeString=[formatter stringFromDate:d];

    return timeString;
}

#pragma mark - 字典/数组转json
+ (NSString *)getCurrentJsonString:(id)dict{
    NSError *error;
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:dict options:NSJSONWritingPrettyPrinted error:&error];
    NSString *jsonString;
    if (!jsonData) {
        NSLog(@"%@",error);
    }else{
        jsonString = [[NSString alloc]initWithData:jsonData encoding:NSUTF8StringEncoding];
    }
    return jsonString;
}

#pragma mark - 将JSON串转化为字典或者数组
+ (id)toArrayOrNSDictionary:(NSString *)jsonStr{
    //string转data
    NSData * jsonData = [jsonStr dataUsingEncoding:NSUTF8StringEncoding];
    //json解析
    id obj = [NSJSONSerialization JSONObjectWithData:jsonData options:NSJSONReadingMutableContainers error:nil];
    return obj;
}

@end
