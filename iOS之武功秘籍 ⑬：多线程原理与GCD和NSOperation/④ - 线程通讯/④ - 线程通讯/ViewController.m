//
//  ViewController.m
//  ④ - 线程通讯
//
//  Created by tangchangjiang on 2021/1/26.
//

#import "ViewController.h"
#import "TCJPortViewController.h"

@interface ViewController ()<NSMachPortDelegate>

@property (nonatomic, strong) UIScrollView *scrollView;
@property (nonatomic, weak) UIImageView *imageView;

@end

@implementation ViewController

- (void)loadView {
    _scrollView = [[UIScrollView alloc] init];
    _scrollView.backgroundColor = [UIColor greenColor];
    self.view = _scrollView;
    
//
//    // 对象 --> nil
    
    

//    UIImageView *iv = [[UIImageView alloc] init];
//    [self.view addSubview:iv];
//    _imageView = iv;

}


- (void)viewDidLoad {
    [super viewDidLoad];

    _imageView = [[UIImageView alloc] init];
    
    // 1. 准备 URL
    NSString *urlString = @"https://timgsa.baidu.com/timg?image&quality=80&size=b9999_10000&sec=1529488045873&di=7c1cc40bec638406ef48717386a08094&imgtype=0&src=http%3A%2F%2Fpic2.ooopic.com%2F12%2F46%2F41%2F95bOOOPIC74_1024.jpg";
    NSURL *url = [NSURL URLWithString:urlString];

    // 2. 下载图像
    //[self downloadImageWithURL:url];
    // 异步下载图像
    [self performSelectorInBackground:@selector(downloadImageWithURL:) withObject:url];

}

/**
 * 下载 URL 指定的网络图片
 */
- (void)downloadImageWithURL:(NSURL *)url {
    
    NSLog(@"%@", [NSThread currentThread]);
    
    // 1. 所有从网络返回的都是二进制数据
    NSData *data = [NSData dataWithContentsOfURL:url];
    
    // 2. 将二进制数据转换成 image
    UIImage *image = [UIImage imageWithData:data];
    
    // 3. 在主线程更新 UI
    // waitUntilDone: 是否等待 updateImage: 执行完成
    [self performSelectorOnMainThread:@selector(updateImage:) withObject:image waitUntilDone:YES];
    
    NSLog(@"完成");
}
/**
 * 更新图像 UI
 */
- (void)updateImage:(UIImage *)image {
    
    NSLog(@"更新 UI -> %@", [NSThread currentThread]);
    
    // 3. 设置图像
    _imageView.image = image;
    
    // 4. 调整大小
    [_imageView sizeToFit];
    
    // 5. 设置 contentSize
    _scrollView.contentSize = image.size;
}


- (IBAction)didClickPortAction:(id)sender {
    
    [self.navigationController pushViewController:[TCJPortViewController new] animated:YES];

}


@end
