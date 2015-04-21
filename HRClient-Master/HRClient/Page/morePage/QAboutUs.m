//
//  QAboutUs.m
//  HRClient
//
//  Created by amy.fu on 15/3/29.
//  Copyright (c) 2015年 panyj. All rights reserved.
//

#import "QAboutUs.h"
#import "QViewController.h"


@interface QAboutUs ()<UITableViewDataSource,UITableViewDelegate>{
    UIWebView *phoneCallWebView;
}
@property (nonatomic,strong)UITableView *myTableView;
@property (nonatomic,strong)NSArray *arr;

@end

@implementation QAboutUs



- (void)pageEvent:(QPageEventType)eventType
{
    if (eventType == kPageEventViewCreate)
    {
        //NOTE:页面的消息接口 同普通controller的 隐藏消失回调
    }
}

- (UITableView*)myTableView
{
    if (!_myTableView) {
        _myTableView = [[UITableView alloc] initWithFrame:_view.bounds style:UITableViewStylePlain];
        _myTableView.dataSource  = self;
        _myTableView.delegate = self;
        [_view addSubview:_myTableView];
    }
    return _myTableView;
}

- (UIView *)viewWithFrame:(CGRect)frame
{
    if ([super viewWithFrame:frame])
    {
        self.arr = @[@" 支付帮助",@" 用户协议",@" 会员说明"];
        self.myTableView.backgroundColor = [UIColor clearColor];
        self.myTableView.tableFooterView = [UIView new];
        /*
        CGFloat h = 80;
        CGFloat w = 200;
        UIButton *telBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        telBtn.frame = CGRectMake((SCREEN_SIZE_WIDTH - w)/2.0, SCREEN_SIZE_HEIGHT - h - 70, w, h);
        [telBtn setTitleColor:ColorTheme forState:UIControlStateNormal];
        [telBtn setTitle:@"电话:12334566876" forState:UIControlStateNormal];
        [telBtn addTarget:self action:@selector(clickToPhone) forControlEvents:UIControlEventTouchUpInside];
        [_view addSubview:telBtn];
        */
    }
    return _view;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 45;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return self.arr.count;

}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *cellID = @"cellID";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellID];
    if (cell == nil)
    {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:cellID];
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        cell.textLabel.textColor  = ColorDarkGray;
        cell.textLabel.font = [UIFont systemFontOfSize:14];
    }
    cell.textLabel.text = self.arr[indexPath.row];

    return cell;

}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    switch (indexPath.row) {
        case 0:
        {
            [QViewController gotoPage:@"QAgreementPage" withParam:[[NSDictionary alloc] initWithObjectsAndKeys:[NSNumber numberWithInt:6], @"agreementType", nil]];
        }
            break;
        case 1:
        {
            [QViewController gotoPage:@"QAgreementPage" withParam:[[NSDictionary alloc] initWithObjectsAndKeys:[NSNumber numberWithInt:1], @"agreementType", nil]];
        }
            break;
        case 2:
        {
            [QViewController gotoPage:@"QAgreementPage" withParam:[[NSDictionary alloc] initWithObjectsAndKeys:[NSNumber numberWithInt:2], @"agreementType", nil]];
        }
            break;
        default:
            break;
    }
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}


- (void)clickToPhone{
    NSString *phoneNum = @"12345676345";
    NSURL *phoneURL =[NSURL URLWithString:[NSString stringWithFormat:@"tel:%@",phoneNum]];
    if (!phoneCallWebView) {
        phoneCallWebView = [[UIWebView alloc] initWithFrame:CGRectZero];
    }
    [phoneCallWebView loadRequest:[NSURLRequest requestWithURL:phoneURL]];
}



- (NSString*)title //NOTE:页面标题
{
    return _T(@"关于我们");
}

- (QNavigationType)navigationType //NOTE:导航栏是否存在
{
    return kNavigationTypeNormal;
}


@end
