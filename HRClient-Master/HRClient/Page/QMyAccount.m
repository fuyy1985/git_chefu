//
//  QMyAccount.m
//  HRClient
//
//  Created by ekoo on 14/12/11.
//  Copyright (c) 2014年 panyj. All rights reserved.
//

#import "QMyAccount.h"
#import "QViewController.h"
#import "QMyAccountCell.h"
#import "QHttpMessageManager.h"
#import "QMyAccountMoel.h"
#import "QUser.h"

@interface QMyAccount (){

}

@property (nonatomic,strong)UITableView *myAccountTableView;

@end

@implementation QMyAccount

- (NSString *)title
{
    return @"我的账户";
}

- (void)pageEvent:(QPageEventType)eventType
{
    if (eventType == kPageEventViewCreate)
    {
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(successGetMyAccountInfo:) name:kGetMyAccountInfro object:nil];
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
        
        CGFloat blank = 10;
        UIView *footerView = [[UIView alloc] initWithFrame:CGRectMake(0, blank, frame.size.width - 100, 160)];
        UIButton *accountBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        accountBtn.frame = CGRectMake(blank, blank, (frame.size.width - 30)/2, 40);
        [accountBtn setTitle:@"账户充值" forState:UIControlStateNormal];
        [accountBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [accountBtn setBackgroundImage:[QTools createImageWithColor:ColorTheme] forState:UIControlStateNormal];
        accountBtn.layer.masksToBounds = YES;
        accountBtn.layer.cornerRadius = 4.0;
        accountBtn.titleLabel.font = [UIFont boldSystemFontOfSize:15];
        [accountBtn addTarget:self action:@selector(gotoAccountRecharge) forControlEvents:UIControlEventTouchUpInside];
        [footerView addSubview:accountBtn];
        
        UIButton *VIPBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        VIPBtn.frame = CGRectMake(accountBtn.frame.origin.x + accountBtn.frame.size.width + blank,  blank, (frame.size.width - 30)/2, 40);
        
        if ([QUser sharedQUser].isVIP)
        {
            [VIPBtn setTitle:@"洗车会员卡充值" forState:UIControlStateNormal];
            NSRange range = [[QUser sharedQUser].vipAccount.accountName rangeOfString:@"钻石年卡"];
            VIPBtn.enabled = !range.length;
        }
        else
        {
            [VIPBtn setTitle:@"购买洗车会员卡" forState:UIControlStateNormal];
        }
        
        [VIPBtn setTitleColor: [UIColor whiteColor] forState:UIControlStateNormal];
        [VIPBtn setBackgroundImage:[QTools createImageWithColor:[QTools colorWithRGB:245 :74 :0]] forState:UIControlStateNormal];
        VIPBtn.layer.masksToBounds = YES;
        VIPBtn.layer.cornerRadius = 4.0;
        VIPBtn.titleLabel.font = [UIFont boldSystemFontOfSize:15];
        [VIPBtn addTarget:self action:@selector(gotoVipRecharge) forControlEvents:UIControlEventTouchUpInside];
        [footerView addSubview:VIPBtn];
        
        CGFloat reminderH = 100;
        UILabel *reminderLabel = [[UILabel alloc] initWithFrame:CGRectMake(blank, accountBtn.frame.origin.y + accountBtn.frame.size.height + 35, accountBtn.frame.size.width *2 + blank , reminderH)];
        reminderLabel.textColor = ColorDarkGray;
        reminderLabel.font = [UIFont systemFontOfSize:14];
        reminderLabel.numberOfLines = 0;
        [footerView addSubview:reminderLabel];
        
        NSString *text = @"温馨提示：（1）会员充值可以享受优惠洗车服务，账户充值支付更快捷方便! （2）已经是年卡的用户不能再次充值。";
        text = @"温馨提示：会员充值可以享受优惠洗车服务，账户充值支付更快捷方便!";
        NSRange range = [text rangeOfString:@"温馨提示："];
        NSMutableAttributedString *string = [[NSMutableAttributedString alloc] initWithString:text attributes:@{NSStrikethroughStyleAttributeName:@(NSUnderlineStyleNone)}];
        [string addAttribute:NSFontAttributeName value:[UIFont systemFontOfSize:14] range:range];
        [string addAttribute:NSForegroundColorAttributeName value:ColorTheme range:range];
        reminderLabel.attributedText = string;
        [reminderLabel sizeToFit];
        
        _myAccountTableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, frame.size.width, frame.size.height) style:UITableViewStyleGrouped];
        _myAccountTableView.dataSource = self;
        _myAccountTableView.delegate = self;
        _myAccountTableView.tableFooterView = footerView;
        _myAccountTableView.backgroundColor = [QTools colorWithRGB:240 :239 :237];
        [_view addSubview:_myAccountTableView];
    }
    return _view;
}

#pragma mark - Action
- (void)gotoVipRecharge
{
    if ([QUser sharedQUser].isVIP)
    {
        [QViewController gotoPage:@"QMyVIPCard" withParam:nil];
    }
    else
    {
        [QViewController gotoPage:@"QNoVipChong" withParam:nil];
    }
}

- (void)gotoAccountRecharge
{
    [QViewController gotoPage:@"QAccountRecharge" withParam:nil];
}

#pragma mark - Notification

- (void)successGetMyAccountInfo:(NSNotification*)noti
{
    [self.myAccountTableView reloadData];
}

#pragma mark - UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [QUser sharedQUser].isVIP ? 2 : 1;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 45;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    return 10;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *myAccount = @"MyAccount";
    QMyAccountCell *cell = [tableView dequeueReusableCellWithIdentifier:myAccount];
    if (!cell)
    {
        cell = [[QMyAccountCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:myAccount];
    }
    if ([QUser sharedQUser].isVIP)
    {
        if (indexPath.row == 0) {
            cell.accessoryType = UITableViewCellAccessoryNone;
            
            cell.nameLabel.text = @"账户余额";
            cell.moneyLabel.text = [NSString stringWithFormat:@"￥%.2f",[[QUser sharedQUser].normalAccount.balance doubleValue]];
            cell.moneyLabel.textColor = UIColorFromRGB(0xc40000);
        }
        else if (indexPath.row == 1){
            cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
            
            cell.nameLabel.text = [NSString stringWithFormat:@"洗车卡(%@)",[QUser sharedQUser].vipAccount.accountName];
            cell.moneyLabel.text = [NSString stringWithFormat:@"￥%.2f",[[QUser sharedQUser].vipAccount.balance doubleValue]];
            cell.moneyLabel.textColor = ColorTheme;
        }
        [QTools endWaittingInView:_view];
    }
    else
    {
        cell.nameLabel.text = @"账户余额";
        cell.moneyLabel.text = [NSString stringWithFormat:@"￥%.2f", [[QUser sharedQUser].normalAccount.balance doubleValue]];
        cell.moneyLabel.textColor = ColorTheme;
        [QTools endWaittingInView:_view];
    }
        return cell;
}

#pragma mark - UITableViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.row == 1)
    {
        [QViewController gotoPage:@"QMyVIPCard" withParam:nil];
    }
    [tableView deselectRowAtIndexPath:indexPath animated:NO];
}

@end
