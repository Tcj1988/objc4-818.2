//
//  main.m
//  ③ - 编译器优化
//
//  Created by tangchangjiang on 2020/9/20.
//

#import <UIKit/UIKit.h>
#import "AppDelegate.h"

//MARK: - 测试函数
int cjSum(int a, int b){
    return a+b;
}

int main(int argc, char * argv[]) {
    int a = 10;
    int b = 20;
    int c = a+b;
    NSLog(@"查看编译器优化情况:%d",c);
    return 0;
}
