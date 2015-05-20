//
//  QMyData.m
//  HRClient
//
//  Created by ekoo on 14/12/10.
//  Copyright (c) 2014年 panyj. All rights reserved.
//

#import "QMyData.h"
#import "QMyDataCell.h"
#import "QViewController.h"
#import "QLoginModel.h"
#import "QHttpMessageManager.h"


@interface QMyData () <QMyDataCellDelegate>
{
    NSDictionary *configDic;
    NSArray *titles;
    NSString *newNick;
}
@property (nonatomic,strong)UITableView *MyDataTableView;

@end

@implementation QMyData

- (NSString *)title{
    return @"我的";
}

- (void)setActiveWithParams:(NSDictionary *)params
{
    titles = @[@"账户名",@"支付密码",@"登录密码",@"已绑定手机"];
}

- (void)pageEvent:(QPageEventType)eventType
{
    if (eventType == kPageEventWillShow)
    {
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(acomendNickSucess:) name:kAcommendNick object:nil];
    }
    else if (eventType == kPageEventWillHide)
    {
        [[NSNotificationCenter defaultCenter] removeObserver:self name:kAcommendNick object:nil];
    }
}

- (UIView *)viewWithFrame:(CGRect)frame{
    if ([super viewWithFrame:frame]) {
        _view.backgroundColor = [QTools colorWithRGB:240 :239 :237];
        
        CGFloat beforeW = 10.0;
        CGFloat w = frame.size.width - 20;
        CGFloat h = 35.0;
        
        UIView *footerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, frame.size.width, h + 2*20)];
        
        UIButton *leaveBtn = [[UIButton alloc] initWithFrame:CGRectMake(beforeW, 20, w , h)];
        [leaveBtn setBackgroundImage:[QTools createImageWithColor:ColorTheme] forState:UIControlStateNormal];
        [leaveBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [leaveBtn setTitle:@"退出帐号" forState:UIControlStateNormal];
        leaveBtn.titleLabel.font = [UIFont systemFontOfSize:16];
        [leaveBtn addTarget:self action:@selector(gotoLeaveAccount) forControlEvents:UIControlEventTouchUpInside];
        leaveBtn.layer.masksToBounds = YES;
        leaveBtn.layer.cornerRadius = 4.0;
        [footerView addSubview:leaveBtn];

        _MyDataTableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, frame.size.width, frame.size.height)style:UITableViewStylePlain];
        _MyDataTableView.dataSource = self;
        _MyDataTableView.delegate = self;
        _MyDataTableView.tableFooterView = footerView;
        _MyDataTableView.backgroundColor = [QTools colorWithRGB:240 :239 :237];
        [_view addSubview:_MyDataTableView];
    }
    return _view;
}

- (void)acomendNickSucess:(NSNotification*)noti
{
    [ASRequestHUD dismissWithSuccess:@"修改成功"];
    
    [ASUserDefaults setObject:newNick forKey:AccountNick];
}

#pragma mark - Action

- (void)gotoLeaveAccount{
    [QUser sharedQUser].isLogin = NO;
    QLoginModel *model = [[QLoginModel alloc] init];
    [model savetoLocal:nil];
    [[QUser sharedQUser] clearInfo];
    [QViewController gotoPage:@"QHomePage" withParam:nil];
}

#pragma  mark - QMyDataCellDelegate
- (void)setNick:(NSString*)nick
{
    newNick = nick;
    
    [[QHttpMessageManager sharedHttpMessageManager] accessAcommendNick:nick];
    [ASRequestHUD show];
}

#pragma mark - UITableViewDataSource
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    switch (section) {
        case 0:
            return 1;
            break;
        case 1:
            return 3;
            break;
        default:
            return 0;
            break;
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 45;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    return 10.0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    static NSString *MyData = @"MyData";
    QMyDataCell *cell = [tableView dequeueReusableCellWithIdentifier:MyData];
    if (cell == nil) {
        cell = [[QMyDataCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:MyData];
        cell.delegate = self;
    }
    if (indexPath.section == 1) {
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    }

    [cell configurationCellWithModel:titles andIndexPath:indexPath andPayPwd:[ASUserDefaults objectForKey:AccountPayPasswd]];
    return cell;
}


- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section{
    return 0.5;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section{
    UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_SIZE_WIDTH, 0.5)];
    return view;
}
- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section{
    UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_SIZE_WIDTH, 0.5)];
    return view;
}

#pragma mark - UITableViewDelegate
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == 0 && indexPath.row == 0) {
        QMyDataCell *cell = (QMyDataCell*)[tableView cellForRowAtIndexPath:indexPath];
        [cell beginEditNickName];
    }
    else if (indexPath.section == 1) {
        if (indexPath.row == 0) {
//            QAmendPayKey
            if ([[ASUserDefaults objectForKey:AccountPayPasswd] isEqualToString:@"Y"]) {
                [QViewController gotoPage:@"QAmmendOrSetKey" withParam:nil];
            }else{
                [QViewController gotoPage:@"QSetPayKey" withParam:nil];
            }
            
        }else if (indexPath.row == 1){
            [QViewController gotoPage:@"QChangeLoginKey" withParam:nil];
        }else if (indexPath.row == 2){
            [QViewController gotoPage:@"QChangeTel" withParam:nil];
        }
        
        [tableView reloadRowsAtIndexPaths:[NSArray arrayWithObject:[NSIndexPath indexPathForRow:0 inSection:0]] withRowAnimation:UITableViewRowAnimationNone];
    }
    
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

@end
