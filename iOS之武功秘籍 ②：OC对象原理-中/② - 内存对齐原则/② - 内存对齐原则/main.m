//
//  main.m
//  ② - 内存对齐原则
//
//  Created by tangchangjiang on 2020/9/24.
//

#import <Foundation/Foundation.h>

#ifdef DEBUG
#define CJNSLog(format, ...) printf("%s\n", [[NSString stringWithFormat:format, ## __VA_ARGS__] UTF8String]);
#else
#define CJNSLog(format, ...);
#endif

struct CJStruct1 {
    double a;   // 8 (0-7)
    char b;     // 1 [8 1] (8)
    int c;      // 4 [9 4] 9 10 11 (12 13 14 15)
    short d;    // 2 [16 2] (16 17)
}CJStruct1;

// 内部需要的大小为: 18
// 最大属性 : 8
// 结构体整数倍: 24

struct CJStruct2 {
    double a;   //8 (0-7)
    int b;      //4 (8 9 10 11)
    char c;     //1 (12)
    short d;    //2 13 (14 15) - 16
}CJStruct2;

// 内部需要的大小为: 16
// 最大属性 : 8
// 结构体整数倍: 16

struct CJStruct3 {
    int e;   //4 (0-3)
    struct CJStruct1 CJStruct1;      //4 4 5 6 7 (8 . . .31)
}CJStruct3;

struct CJStruct4 {
    double e;   //8 (0-7)
    struct CJStruct2 CJStruct2;  //(8 . . . 23)
}CJStruct4;

int main(int argc, const char * argv[]) {
    @autoreleasepool {
        // insert code here...
        
        CJNSLog(@"CJStruct1-%lu CJStruct2-%lu CJStruct3-%lu CJStruct4-%lu ",sizeof(CJStruct1),sizeof(CJStruct2),sizeof(CJStruct3),sizeof(CJStruct4));
    }
    return 0;
}
