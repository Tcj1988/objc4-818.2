//
//  ViewController.m
//  PodsTest
//
//  Created by tangchangjiang on 2021/2/12.
//

#import "ViewController.h"
#import "TCJUtils.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    UIImage *img = [TCJUtils getToolsBundleImage:@"share_wechat"];
    UIImageView *imageV = [[UIImageView alloc] initWithFrame:CGRectMake(100, 100, 100, 100)];
    imageV.image = img;
    [self.view addSubview:imageV];
    
}


@end
