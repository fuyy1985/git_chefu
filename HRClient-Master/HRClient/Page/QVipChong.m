//
//  QVipChong.m
//  HRClient
//
//  Created by ekoo on 14/12/18.
//  Copyright (c) 2014年 panyj. All rights reserved.
//

#import "QVipChong.h"
#import "QVIPCardRechargeCell.h"
#import "QViewController.h"
#import "QCardDetailModel.h"
#import "QHttpMessageManager.h"
#import "QMyAccountMoel.h"
#import "QRegularHelp.h"
#import "QCountDown.h"

@interface QVipChong ()
{
    UIButton *selectBtn;
    UIButton *rechargeBtn;
    UIImageView *temImageView;
    NSMutableArray *_cardDetails;
    
    UITextField *_phoneTextField;
    UITextField *_codeTextField;
    
    QCardDetailModel *_selectCardDetailModel;
    QCardDetailModel *_curModel;
    
    UITextField *inputTextFiled;
    UISegmentedControl *segmentControl;
    NSNumber *mbrTypeId;
    
    NSString *strAmout; //充值金额
    NSMutableArray *listArr;
}

@property (nonatomic, strong) UIView *accountView;
@property (nonatomic, strong) UITableView *VIPTableView;
@property (nonatomic, strong) UIView *directBuy;
@property (nonatomic, strong) UIView *displayView;

@end

@implementation QVipChong

- (NSString *)title
{
    return @"会员卡充值";
}

- (QCacheType)pageCacheType
{
    return kCacheTypeNone;
}

#pragma mark - UISegmentedControl Delegate

- (void)segmentedControl:(UISegmentedControl*)segmentedControl
{
    NSInteger selectIndex = segmentedControl.selectedSegmentIndex;
    if (selectIndex == 0)
    {
        [inputTextFiled becomeFirstResponder];
        
        _directBuy.hidden = NO;
        _VIPTableView.hidden = YES;
        
        _displayView.frame = CGRectMake(0, CGRectGetMaxY(_directBuy.frame), SCREEN_SIZE_WIDTH, 80);
    }
    else
    {
        [inputTextFiled resignFirstResponder];
        
        _directBuy.hidden = YES;
        _VIPTableView.hidden = NO;
        [self reloadTableView];
        
        _displayView.frame = CGRectMake(0, CGRectGetMaxY(_VIPTableView.frame), SCREEN_SIZE_WIDTH, 80);
    }
    
    [_view bringSubviewToFront:_displayView];
}

- (UIView *)viewWithFrame:(CGRect)frame{
    if ([super viewWithFrame:frame]) {
        
        _view.backgroundColor = [QTools colorWithRGB:240 :239 :237];
        
        //选择框
        segmentControl = [[UISegmentedControl alloc] initWithItems:@[@"充值", @"更换卡类型"]];
        segmentControl.frame = CGRectMake(10, 8, (_view.frame.size.width - 20), 30);
        segmentControl.tintColor = ColorTheme;
        segmentControl.selectedSegmentIndex = 0;
        NSDictionary *attributes = [NSDictionary dictionaryWithObjectsAndKeys:[UIFont systemFontOfSize:15],NSFontAttributeName,ColorTheme, NSForegroundColorAttributeName, nil];
        [segmentControl setTitleTextAttributes:attributes forState:UIControlStateNormal];
        [segmentControl addTarget:self action:@selector(segmentedControl:) forControlEvents:UIControlEventValueChanged];
        [_view addSubview:segmentControl];

        //直接充值
        {
            _directBuy = [[UIView alloc]initWithFrame:CGRectMake(0, 48, frame.size.width, 150)];
            _directBuy.backgroundColor = [UIColor clearColor];
            [_view addSubview:_directBuy];
            
            //当前卡类型
            UILabel *otherLabel = [[UILabel alloc] initWithFrame:CGRectMake(20, 0, frame.size.width - 40, 35)];
            otherLabel.backgroundColor = [UIColor clearColor];
            otherLabel.text = [NSString stringWithFormat:@"您当前使用的会员卡：%@",[QUser sharedQUser].vipAccount.accountName];
            otherLabel.textAlignment = NSTextAlignmentCenter;
            otherLabel.textColor = ColorTheme;
            otherLabel.font = [UIFont boldSystemFontOfSize:15];
            [_directBuy addSubview:otherLabel];
            
            //当前卡余额
            otherLabel = [[UILabel alloc] initWithFrame:CGRectMake(20, 35,  frame.size.width - 40, 35)];
            otherLabel.backgroundColor = [UIColor clearColor];
            otherLabel.text = [NSString stringWithFormat:@"当前卡内剩余：%.2f元",[[QUser sharedQUser].vipAccount.balance doubleValue]];
            otherLabel.textAlignment = NSTextAlignmentCenter;
            otherLabel.textColor = ColorTheme;
            otherLabel.font = [UIFont boldSystemFontOfSize:15];
            [_directBuy addSubview:otherLabel];
            
            //label
            otherLabel = [[UILabel alloc] initWithFrame:CGRectMake(20, 100, 60, 35)];
            otherLabel.backgroundColor = [UIColor clearColor];
            otherLabel.text = @"充值金额";
            otherLabel.textAlignment = NSTextAlignmentRight;
            otherLabel.textColor = ColorTheme;
            otherLabel.font = [UIFont boldSystemFontOfSize:15];
            [_directBuy addSubview:otherLabel];
            
            //textfled
            inputTextFiled = [[UITextField alloc] initWithFrame:CGRectMake(90, 105, 200, 25)];
            inputTextFiled.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
            inputTextFiled.backgroundColor = [QTools colorWithRGB:255 :255 :255];
            inputTextFiled.layer.masksToBounds = YES;
            inputTextFiled.layer.borderColor = [QTools colorWithRGB:219 :218 :218].CGColor;
            inputTextFiled.placeholder = @"请输入充值金额";
            inputTextFiled.font = [UIFont systemFontOfSize:14.f];
            inputTextFiled.userInteractionEnabled = YES;
            [_directBuy addSubview:inputTextFiled];
        }
        
        //更换会员卡表格
        {
            UITableView *listTableView = [[UITableView alloc] initWithFrame:CGRectMake(15, 48, frame.size.width - 30, 35) style:UITableViewStylePlain];
            listTableView.dataSource = self;
            listTableView.delegate = self;
            listTableView.scrollEnabled = NO;
            [_view addSubview:listTableView];
            _VIPTableView = listTableView;
            _VIPTableView.hidden = YES;
        }
        
        //下部提示和提交按钮
        {
            _displayView = [[UIView alloc] initWithFrame:CGRectMake(0, CGRectGetMaxY(_directBuy.frame), frame.size.width, 80)];
            _displayView.hidden = NO;
            _displayView.backgroundColor = [UIColor clearColor];
            [_view addSubview:_displayView];
            
            //对号的一行往下
            CGFloat agreeBeforeW = 15;
            CGFloat agreeTopH = 0;
            CGFloat agreeW = 35;
            CGFloat agreeH = 35;
            
            //阅读勾选框
            selectBtn = [[UIButton alloc] initWithFrame:CGRectMake(agreeBeforeW, agreeTopH, agreeW, agreeH)];
            [selectBtn setImage:[UIImage imageNamed:@"icon_agree_unselected"] forState:UIControlStateNormal];
            [selectBtn setImage:[UIImage imageNamed:@"icon_agree_selected"] forState:UIControlStateSelected];
            [selectBtn addTarget:self action:@selector(sureToAgree:) forControlEvents:UIControlEventTouchUpInside];
            selectBtn.selected = YES;
            [_displayView addSubview:selectBtn];
            
            CGFloat explainBeforeW = selectBtn.deFrameRight;
            CGFloat explainTopH = agreeTopH;
            CGFloat explainW = frame.size.width - 2 * explainBeforeW;
            CGFloat explainH = agreeH;
            UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(explainBeforeW, explainTopH, explainW+20, explainH)];
            label.textColor = [QTools colorWithRGB:80 :80 :80];
            label.font = [UIFont systemFontOfSize:12];
            label.backgroundColor = [UIColor clearColor];
            
            //属性文字
            NSString *text = @"我已阅读并同意车夫会员洗车卡使用协议";
            NSRange range = [text rangeOfString:@"会员洗车卡使用协议"];
            NSMutableAttributedString *string = [[NSMutableAttributedString alloc] initWithString:text attributes:@{NSStrikethroughStyleAttributeName: @(NSUnderlineStyleNone)}];
            [string addAttributes:@{NSUnderlineStyleAttributeName:@(NSLineBreakByClipping)} range:range];
            [string addAttribute:NSForegroundColorAttributeName value:ColorTheme range:range];
            label.attributedText = string;
            
            label.userInteractionEnabled = YES;
            UITapGestureRecognizer *tap1 = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(agreeVipDelegate:)];
            [label addGestureRecognizer:tap1];
            [_displayView addSubview:label];
            
            //确认按钮
            CGFloat rechargeW = _displayView.deFrameWidth - 2*15;
            CGFloat rechargeH = 35;
            CGFloat rechargeBeforeW = 15.f;
            CGFloat rechargeTopH = selectBtn.deFrameBottom + 10;
            rechargeBtn = [[UIButton alloc] initWithFrame:CGRectMake(rechargeBeforeW, rechargeTopH, rechargeW, rechargeH)];
            [rechargeBtn setTitle:@"确认" forState:UIControlStateNormal];
            [rechargeBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
            [rechargeBtn setBackgroundImage:[QTools createImageWithColor:ColorTheme] forState:UIControlStateNormal];
            rechargeBtn.titleLabel.font = [UIFont boldSystemFontOfSize:14];
            rechargeBtn.layer.masksToBounds = YES;
            rechargeBtn.layer.cornerRadius = 4.f;
            [rechargeBtn addTarget:self action:@selector(rechargeOrAdvanced:) forControlEvents:UIControlEventTouchUpInside];
            [_displayView addSubview:rechargeBtn];
        }
    }
    
    return _view;
}

- (double)getNeedPayMony
{
    if (_cardDetails == nil) return 0.0;
    
    for (int i = 0; i < _cardDetails.count; i++)
    {
        QCardDetailModel *model = _cardDetails[i];
        if ([model.memberTypeName isEqualToString:[QUser sharedQUser].vipAccount.accountName])
        {
            _curModel = model;
            return [model.amount doubleValue] - [[QUser sharedQUser].vipAccount.balance doubleValue];
        }
    }
    
    return 0.0;
}

- (void)pageEvent:(QPageEventType)eventType
{
    if (eventType == kPageEventViewCreate)
    {
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(successGetCardDetails:) name:kCardDetails object:nil];
        
        //_cardDetails = [QCardDetailModel defaultCardDetailsModel]; //不能用缓存数据
        [[QHttpMessageManager sharedHttpMessageManager] accessCardDetails];
        [ASRequestHUD show];
    }
    else if (eventType == kPageEventViewDispose)
    {
        [inputTextFiled resignFirstResponder];
        [[NSNotificationCenter defaultCenter] removeObserver:self name:kCardDetails object:nil];
    }
}

#pragma mark - Private

- (void)reloadTableView
{
    _selectCardDetailModel = [_cardDetails objectAtIndex:0];
    _VIPTableView.deFrameHeight = (_cardDetails.count + 1) * QVIPCardRechargeCellHeight;
    [_VIPTableView reloadData];
}

#pragma mark - Action

- (void)sureToAgree:(UIGestureRecognizer *)sender{
    selectBtn.selected = !selectBtn.selected;
    rechargeBtn.enabled = selectBtn.selected;
}

- (void)agreeVipDelegate:(UIGestureRecognizer *)sender{
    [QViewController gotoPage:@"QAgreementPage" withParam:[[NSDictionary alloc]
                                initWithObjectsAndKeys:[NSNumber numberWithInt:2], @"agreementType", nil]];
}

- (void)rechargeOrAdvanced:(id)sender
{
    QCardDetailModel *model = _cardDetails[0];
    
    if ([model.memberTypeName isEqualToString:[QUser sharedQUser].vipAccount.accountName]
        && segmentControl.selectedSegmentIndex == 0) {
        
        if ([[QUser sharedQUser].vipAccount.balance integerValue] > 0)
        {
            [QViewController showMessage:@"体验卡只能使用一次"];
            return;
        }
    }
    
    NSString *titleInfo;
    
    if (segmentControl.selectedSegmentIndex == 0)
    {
        if ([inputTextFiled.text doubleValue] < [self getNeedPayMony])
        {
            [QViewController showMessage:@"充值失败，您充值的金额小于最低充值金额。"];
            return;
        }
        
        
        NSRange rang = [strAmout rangeOfString:@"元"];
        
        if (rang.location && rang.length)
        {
            strAmout = [inputTextFiled.text substringToIndex:inputTextFiled.text.length - 1];
        }
        else
        {
        strAmout = inputTextFiled.text;
        }
        mbrTypeId = _curModel.memberTypeId;
        titleInfo = [NSString stringWithFormat:@"%@充值", _curModel.memberTypeName];
    }
    else
    {
        if (_selectCardDetailModel.memberTypeId.intValue == 6 || _selectCardDetailModel.memberTypeId.intValue == 5)
        {
            strAmout = [NSString stringWithFormat:@"%.2f",_selectCardDetailModel.amount.floatValue -
                        [QUser sharedQUser].vipAccount.balance.floatValue];
            
        }
        
        strAmout = [NSString stringWithFormat:@"%.2f",_selectCardDetailModel.amount.floatValue -
                    [QUser sharedQUser].vipAccount.balance.floatValue];
        
        mbrTypeId = _selectCardDetailModel.memberTypeId;
        titleInfo = [NSString stringWithFormat:@"升级为%@", _selectCardDetailModel.memberTypeName];
    }
    
    if ([strAmout doubleValue] <= 0)
    {
        strAmout = @"0.1";
    }
    
    [QViewController gotoPage:@"QVIPCardChong" withParam:[[NSDictionary alloc]
                                                          initWithObjectsAndKeys:strAmout, @"vipChargeAmount",
                                                                                mbrTypeId, @"mbrTypeId",
                                                                                titleInfo, @"titleInfo",
                                                          [NSNumber numberWithInteger:2],@"buy_type",nil]];
}

#pragma mark - Notification
- (void)successGetCardDetails:(NSNotification*)noti
{
    [ASRequestHUD dismiss];
    
    _cardDetails = noti.object;
    QCardDetailModel *model = _cardDetails[0];
    
    listArr = [[NSMutableArray alloc]initWithArray:_cardDetails];
    [listArr removeObjectAtIndex:0];
    
    if ([model.memberTypeName isEqualToString:[QUser sharedQUser].vipAccount.accountName]) {
        
        if ([[QUser sharedQUser].vipAccount.balance integerValue] > 0)
        {
            inputTextFiled.placeholder = @"体验卡只能使用一次";
        }
        else
        {
            inputTextFiled.text = @"100";
        }
        
        inputTextFiled.enabled = NO;
    }
    else
    {
        if ([self getNeedPayMony] < 0)
        {
            inputTextFiled.placeholder = @"请输入您的充值金额";
        }
        else
        {
            if (_curModel.memberTypeId.integerValue == 5 || _curModel.memberTypeId.integerValue == 6)
            {
                inputTextFiled.text = [NSString stringWithFormat:@"%.2f元",[self getNeedPayMony]];
                inputTextFiled.enabled = NO;
            }
            else
            {
                inputTextFiled.placeholder = [NSString stringWithFormat:@"最低充值金额 %.2f元",[self getNeedPayMony]];
            }
            
        }
    }
    
    [self reloadTableView];
    
    //暂存数据
    [QCardDetailModel setCardDetailsModel:noti.object];
}

#pragma mark - UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return listArr ? listArr.count + 1 : 1; //包括表抬头
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return QVIPCardRechargeCellHeight;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *listID = @"list_ID";
    QVIPCardRechargeCell * cell = [tableView dequeueReusableCellWithIdentifier:listID];
    if (cell == nil) {
        cell = [[QVIPCardRechargeCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:listID];
    }
    
    if (indexPath.row == 0)
    {
        cell.userInteractionEnabled = NO;
        cell.agreeImageView.image = nil;
    }
    else
    {
        cell.agreeImageView.image = [UIImage imageNamed:@"icon_collect_unselected"];
        temImageView = cell.agreeImageView;
    }
    
    [cell configureModelForCell:listArr andIndexPath:indexPath];
    
    return cell;
}

#pragma mark - UITableViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    temImageView.image = [UIImage imageNamed:@"icon_collect_unselected"];
    
    QVIPCardRechargeCell *newCell = (QVIPCardRechargeCell *)[tableView cellForRowAtIndexPath:indexPath];
    newCell.agreeImageView.image = [UIImage imageNamed:@"icon_collect_selected"];
    temImageView = newCell.agreeImageView;
    
    if (indexPath.row - 1 < listArr.count)
    {
        _selectCardDetailModel = [listArr objectAtIndex:indexPath.row - 1];
    }
    
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

@end
