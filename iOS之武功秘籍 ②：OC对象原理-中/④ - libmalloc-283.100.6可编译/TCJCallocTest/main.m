//
//  main.m
//  TCJCallocTest
//
//  Created by tangchangjiang on 2020/9/24.
//

#import <Foundation/Foundation.h>
#import <malloc/malloc.h>

int main(int argc, const char * argv[]) {
    @autoreleasepool {
        // insert code here...
		
		void *p = calloc(1, 40);
        NSLog(@"Hello, World! - %lu",malloc_size(p));
    }
    return 0;
}
