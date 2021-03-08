//
//  TableViewController.m
//  CTMediator
//
//  Created by casa on 2016/10/20.
//  Copyright © 2016年 casa. All rights reserved.
//

#import "TableViewController.h"
#import <HandyFrame/UIView+LayoutMethods.h>
#import "CTMediator+CTMediatorModuleAActions.h"

@interface TableViewController () <UITableViewDelegate, UITableViewDataSource>

@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, strong) UIButton *closeButton;

@end

@implementation TableViewController

#pragma mark - life cycle
- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self.view addSubview:self.tableView];
    [self.view addSubview:self.closeButton];
}

- (void)viewWillLayoutSubviews
{
    [super viewWillLayoutSubviews];
    
    [self.tableView fillWidth];
    [self.tableView topInContainer:0 shouldResize:YES];
    [self.tableView bottomInContainer:50 shouldResize:YES];
    
    [self.closeButton fillWidth];
    [self.closeButton top:0 FromView:self.tableView];
    [self.closeButton bottomInContainer:0 shouldResize:YES];
}

- (void)dealloc
{
    // 在Controller被回收的时候，把相关的target也回收掉
    [[CTMediator sharedInstance] CTMediator_cleanTableViewCellTarget];
}

#pragma mark - UITableViewDelegate
- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    // 通过Mediator来获取cell实例，由于target已经被cache了，高频调用不是问题。
    [[CTMediator sharedInstance] CTMediator_configTableViewCell:cell withTitle:@"cell title" atIndexPath:indexPath];
}

#pragma mark - UITableViewDataSource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 100;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    // 通过mediator来配置cell实例，由于target已经被cache了，高频调用不是问题。
    return [[CTMediator sharedInstance] CTMediator_tableViewCellWithIdentifier:@"cell" tableView:tableView];
}

#pragma mark - event response
- (void)didTappedCloseButton:(UIButton *)button
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - getters and setters
- (UITableView *)tableView
{
    if (_tableView == nil) {
        _tableView = [[UITableView alloc] init];
        _tableView.delegate = self;
        _tableView.dataSource = self;
    }
    return _tableView;
}

- (UIButton *)closeButton
{
    if (_closeButton == nil) {
        _closeButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [_closeButton setTitle:@"Close" forState:UIControlStateNormal];
        [_closeButton setTitleColor:[UIColor blueColor] forState:UIControlStateNormal];
        [_closeButton addTarget:self action:@selector(didTappedCloseButton:) forControlEvents:UIControlEventTouchUpInside];
        _closeButton.backgroundColor = [UIColor grayColor];
    }
    return _closeButton;
}

@end
