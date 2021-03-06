//
//  objc_msgSend伪代码实现.c
//  ① - 运行时感受
//
//  Created by tangchangjiang on 2021/2/16.
//

#include <stdio.h>

[person sayHello]  -> imp ( cache -> bucket (sel imp))

// 获取当前的对象
id person = 0x10000
// 获取isa
isa_t isa = 0x000000
// isa -> class -> cache
cache_t cache = isa + 16字节

// arm64
// mask|buckets 在一起的
buckets = cache & 0x0000ffffffffffff
// 获取mask
mask = cache LSR #48
// 下标 = mask & sel
index = mask & p1

// bucket 从 buckets 遍历的开始 (起始查询的bucket)
bucket = buckets + index * 16 (sel imp = 16)


int count = 0
// CheckMiss $0
do{

    if ((bucket == buckets) && (count == 0)){ // 进入第二层判断
        // bucket == 第一个元素
        // bucket人为设置到最后一个元素
        bucket = buckets + mask * 16
        count++;
        
    }else if (count == 1) goto CheckMiss
        
    // {imp, sel} = *--bucket
    // 缓存的查找的顺序是: 向前查找
    bucket--;
    imp = bucket.imp;
    sel = bucket.sel;
    
}while (bucket.sel != _cmd)  //  // bucket里面的sel 是否匹配_cmd

// CacheHit $0
return imp

CheckMiss:
    CheckMiss(normal)
