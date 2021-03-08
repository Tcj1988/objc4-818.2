//
//  main.m
//  TCJObjc
//
//  Created by tangchangjiang on 2021/1/6.
//


#import <Foundation/Foundation.h>

//struct TCJTest {
//    TCJTest(){
//        printf("1123 - %s\n", __func__);
//    }
//    ~TCJTest(){
//        printf("5667 - %s\n", __func__);
//    }
//};

/*
struct __AtAutoreleasePool {
    //构造函数
  __AtAutoreleasePool() {atautoreleasepoolobj = objc_autoreleasePoolPush();}
    //析构函数
  ~__AtAutoreleasePool() {objc_autoreleasePoolPop(atautoreleasepoolobj);}
  void * atautoreleasepoolobj;
};
*/

//************打印自动释放池结构************
extern void _objc_autoreleasePoolPrint(void);

int main(int argc, const char * argv[]) {
    // __AtAutoreleasePool __autoreleasepool
    // {} 作用域
    @autoreleasepool {
        //循环创建对象，并加入自动释放池
//        for (int i = 0; i < 505 + 506; i++) {
//             NSObject *objc = [[NSObject alloc] autorelease];
//        }
        NSObject *objc1 = [[NSObject alloc] autorelease];
        dispatch_async(dispatch_get_global_queue(0, 0), ^{
            @autoreleasepool {
                NSObject *objc1 = [[NSObject alloc] autorelease];
                _objc_autoreleasePoolPrint();
            }
        });
        //调用
        _objc_autoreleasePoolPrint();
    }
    return 0;
}
