//
//  QVIPCard.m
//  HRClient
//
//  Created by ekoo on 14/12/9.
//  Copyright (c) 2014年 panyj. All rights reserved.
//

#import "QVIPCard.h"
#import "QVIPCardCell.h"
#import "QViewController.h"
#import "QHttpMessageManager.h"

@interface QVIPCard ()
@property (nonatomic)UITableView *VIPCardApplyTableView;

@end
@implementation QVIPCard


- (NSString *)title
{
    return @"会员卡";
}

- (void)pageEvent:(QPageEventType)eventType
{
    if (eventType == kPageEventViewCreate) {
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(successDelayExpire:) name:kDelayExpire object:nil];
    }
    else if (eventType == kPageEventViewDispose)
    {
        [[NSNotificationCenter defaultCenter] removeObserver:self];
    }
}

- (UIView *)viewWithFrame:(CGRect)frame
{
    if ([super viewWithFrame:frame]) {
        _view.backgroundColor = [QTools colorWithRGB:240 :239 :237];
        // 确认申请 tableFooterView
        UIView *footerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, frame.size.width, 44)];
        UIButton *sureButton = [UIButton buttonWithType:UIButtonTypeCustom];
        sureButton.frame = CGRectMake(10, 4, SCREEN_SIZE_WIDTH-20, 36);
        sureButton.backgroundColor = [QTools colorWithRGB:181 :0 :7];
        sureButton.layer.cornerRadius = 5.f;
        sureButton.layer.masksToBounds = YES;
        sureButton.titleLabel.font = [UIFont systemFontOfSize:15];
        [sureButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [sureButton setTitle:@"确认申请" forState:UIControlStateNormal];
        [sureButton addTarget:self action:@selector(gotoApplication) forControlEvents:UIControlEventTouchUpInside];
        [footerView addSubview:sureButton];
        
        // 会员卡
        _VIPCardApplyTableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, frame.size.width, frame.size.height) style:UITableViewStylePlain];
//        _VIPCardApplyTableView.separatorStyle = UITableViewCellSeparatorStyleNone;
        _VIPCardApplyTableView.delegate = self;
        _VIPCardApplyTableView.dataSource = self;
        _VIPCardApplyTableView.tableFooterView = footerView;
        _VIPCardApplyTableView.backgroundColor = [UIColor clearColor];
        [_view addSubview:_VIPCardApplyTableView];
    }
    
    return _view;
}

#pragma mark - Notification

- (void)successDelayExpire:(NSNotification*)noti
{
    [QViewController backPageWithParam:nil];
    [ASRequestHUD dismiss];
}

#pragma mark - Action
- (void)gotoApplication
{
    [[QHttpMessageManager sharedHttpMessageManager] accessDelayExpire];
    [ASRequestHUD show];
}

#pragma mark - UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return 2;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    if (indexPath.row == 0)
    {
        static NSString *VIPCardApply = @"VIPCardApply";
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:VIPCardApply];
        if (cell==nil)
        {
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:VIPCardApply];
            cell.textLabel.font = [UIFont systemFontOfSize:15];
            cell.textLabel.textColor = ColorDarkGray;
            cell.textLabel.textAlignment = NSTextAlignmentCenter;
            cell.textLabel.numberOfLines = 0;
            
            cell.detailTextLabel.font = [UIFont systemFontOfSize:13];
            cell.detailTextLabel.textColor = [QTools colorWithRGB:245 :74 :0];
        }
        cell.textLabel.text = @"您的会员洗车卡可申请延长90天";
        cell.detailTextLabel.text = @"申请成功后请合理安排您的使用时间";
        return cell;
    }
    else
    {
        static NSString *VIPCardApplyNew = @"VIPCardApplyNew";
        QVIPCardCell *cell = [tableView dequeueReusableCellWithIdentifier:VIPCardApplyNew];
        if (cell == nil) {
            cell = [[QVIPCardCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:VIPCardApplyNew];
        }
        return cell;
    }
    
}


#pragma mark - UITableViewDelegate
- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 10;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    switch (indexPath.row) {
        case 0:
            return 95;
            break;
        case 1:
            return 155;
            break;
        default:
            return 0;
            break;
    }
}


@end
