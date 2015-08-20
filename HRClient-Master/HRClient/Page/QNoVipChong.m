//
//  QNoVipChong.m
//  HRClient
//
//  Created by ekoo on 14/12/18.
//  Copyright (c) 2014年 panyj. All rights reserved.
//

#import "QNoVipChong.h"
#import "QVIPCardRechargeCell.h"
#import "QViewController.h"
#import "QCardDetailModel.h"
#import "QHttpMessageManager.h"
#import "QMyAccountMoel.h"
#import "QRegularHelp.h"
#import "QCountDown.h"

@interface QNoVipChong ()
{
    BOOL _isMember;
    
    UIButton *selectBtn;
    UIButton *rechargeBtn;
    UIScrollView *scrollView1;
    UIImageView *temImageView;
    NSArray *_cardDetails;
    
    UITextField *_phoneTextField;
    UITextField *_codeTextField;
    
    QCardDetailModel *_selectCardDetailModel;
}
@property (nonatomic, strong) UIView *accountView;
@property (nonatomic, strong) UITableView *VIPTableView;
@property (nonatomic, strong) UIView *displayView;

@end

@implementation QNoVipChong

- (NSString *)title
{
    return @"购买洗车会员卡";
}

- (QCacheType)pageCacheType
{
    return kCacheTypeNone;
}

- (UIView *)viewWithFrame:(CGRect)frame{
    if ([super viewWithFrame:frame]) {
        
        _view.backgroundColor = [QTools colorWithRGB:240 :239 :237];
        
        //是否为会员
        _isMember = [[QUser sharedQUser] isVIP];

        scrollView1 = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 0, frame.size.width, frame.size.height)];
        scrollView1.backgroundColor = [QTools colorWithRGB:240 :239 :237];
        [_view addSubview:scrollView1];
 
        CGFloat instructBeforeW = 15.f;
        CGFloat instructTopH = 15.f;
        CGFloat instructW = SCREEN_SIZE_WIDTH - 2*instructBeforeW;
        CGFloat instructH = 20.f;
        UILabel *instructLabel = [[UILabel alloc] initWithFrame:CGRectMake(instructBeforeW, instructTopH, instructW, instructH)];
        instructLabel.backgroundColor = [UIColor clearColor];
        instructLabel.text = @"您目前还没有会员洗车卡";
        instructLabel.textColor = ColorTheme;
        instructLabel.font = [UIFont systemFontOfSize:15];
        instructLabel.textAlignment = NSTextAlignmentCenter;
        [scrollView1 addSubview:instructLabel];
        
        //表
        CGFloat disBeforeW = 15.f;
        CGFloat disTopH = instructLabel.deFrameBottom + 15;
        CGFloat disW = frame.size.width - 2 * disBeforeW;
        CGFloat disH = 35;
        UITableView *listTableView = [[UITableView alloc] initWithFrame:CGRectMake(disBeforeW, disTopH, disW, disH) style:UITableViewStylePlain];
        listTableView.dataSource = self;
        listTableView.delegate = self;
        listTableView.scrollEnabled = NO;
        [scrollView1 addSubview:listTableView];
        _VIPTableView = listTableView;
        
        _displayView = [[UIView alloc] initWithFrame:CGRectMake(0, _VIPTableView.deFrameBottom + 15, scrollView1.deFrameWidth, 80)];
        [scrollView1 addSubview:_displayView];
    }
    return _view;
    
}

- (void)pageEvent:(QPageEventType)eventType
{
    if (eventType == kPageEventViewCreate)
    {
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(successGetCardDetails:) name:kCardDetails object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(successQuickLogin:) name:kFindLoginPwd object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(successGetMyAccount:) name:kGetMyAccountInfro object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(successGetVerifyCode:) name:kAcquireCode object:nil];
        
        _cardDetails = [QCardDetailModel defaultCardDetailsModel];
        if (_cardDetails && _cardDetails.count)
        {
            [self reloadTableView];
        }
        else
        {
            [[QHttpMessageManager sharedHttpMessageManager] accessCardDetails];
            [ASRequestHUD showWithMaskType:ASRequestHUDMaskTypeClear];
        }
        //是否为会员
        if (_isMember) {
            [[QHttpMessageManager sharedHttpMessageManager] accessMyAccount];
        }
        
    }
    else if (eventType == kPageEventWillShow)
    {
        [self updateDisplayView:[QUser sharedQUser].isLogin];
    }
    else if (eventType == kPageEventWillHide)
    {
        [ASRequestHUD dismiss];
    }
    else if (eventType == kPageEventViewDispose)
    {
        [[NSNotificationCenter defaultCenter] removeObserver:self];
    }
}

#pragma mark - Private

- (void)reloadTableView
{
    _selectCardDetailModel = [_cardDetails objectAtIndex:0];
    
    _VIPTableView.deFrameHeight = (_cardDetails.count + 1) * QVIPCardRechargeCellHeight;
    
    _displayView.deFrameTop = _VIPTableView.deFrameBottom + 15;
    scrollView1.contentSize = CGSizeMake(scrollView1.deFrameWidth, _displayView.deFrameBottom);
    
    [_VIPTableView reloadData];
}

- (void)updateDisplayView:(BOOL)isLogin
{
    [_displayView.subviews makeObjectsPerformSelector:@selector(removeFromSuperview)];
    
    //对号的一行往下
    CGFloat agreeBeforeW = 15;
    CGFloat agreeTopH = 0;
    CGFloat agreeW = 35;
    CGFloat agreeH = 35;
    
    selectBtn = [[UIButton alloc] initWithFrame:CGRectMake(agreeBeforeW, agreeTopH, agreeW, agreeH)];
    [selectBtn setImage:[UIImage imageNamed:@"icon_agree_unselected"] forState:UIControlStateNormal];
    [selectBtn setImage:[UIImage imageNamed:@"icon_agree_selected"] forState:UIControlStateSelected];
    [selectBtn addTarget:self action:@selector(sureToAgree:) forControlEvents:UIControlEventTouchUpInside];
    selectBtn.selected = YES;
    [_displayView addSubview:selectBtn];
    
    CGFloat explainBeforeW = selectBtn.deFrameRight;
    CGFloat explainTopH = agreeTopH;
    CGFloat explainW = scrollView1.deFrameWidth - 2*explainBeforeW;
    CGFloat explainH = agreeH;
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(explainBeforeW, explainTopH, explainW+20, explainH)];
    label.textColor = [QTools colorWithRGB:80 :80 :80];
    label.backgroundColor = [UIColor clearColor];
    label.font = [UIFont systemFontOfSize:12];
    
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
    
    if (!isLogin) {
        CGFloat h = 35.f;
        
        UIButton *sendCodeButton = [[UIButton alloc] init];
        sendCodeButton.deFrameSize = CGSizeMake(113, h - 2);
        sendCodeButton.deFrameTop = selectBtn.deFrameBottom + 10;
        sendCodeButton.deFrameRight = _displayView.deFrameWidth - 18;
        [sendCodeButton setBackgroundImage:[QTools createImageWithColor:ColorTheme] forState:UIControlStateNormal];
        sendCodeButton.titleLabel.font = [UIFont systemFontOfSize:15];
        [sendCodeButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [sendCodeButton setTitle:@"发送验证码" forState:UIControlStateNormal];
        sendCodeButton.layer.cornerRadius = 2.5f;
        sendCodeButton.layer.masksToBounds = YES;
        [sendCodeButton addTarget:self action:@selector(onSendCodeButton:) forControlEvents:UIControlEventTouchUpInside];
        [_displayView addSubview:sendCodeButton];
        
        UITextField *phoneTextField = [[UITextField alloc] init];
        phoneTextField.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
        phoneTextField.deFrameSize = CGSizeMake(_view.deFrameWidth - 18 - sendCodeButton.deFrameWidth - 10 - 15, h);
        phoneTextField.deFrameOrigin = CGPointMake(15, sendCodeButton.deFrameTop);
        phoneTextField.placeholder = @"输入手机号码";
        phoneTextField.borderStyle = UITextBorderStyleRoundedRect;
        phoneTextField.font = [UIFont systemFontOfSize:14];
        phoneTextField.clearButtonMode = UITextFieldViewModeWhileEditing;
        [_displayView addSubview:phoneTextField];
        _phoneTextField = phoneTextField;
        
        UITextField *codeTextField = [[UITextField alloc] init];
        codeTextField.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
        codeTextField.deFrameSize = CGSizeMake(_view.deFrameWidth - 18 - 15, h);
        codeTextField.deFrameOrigin = CGPointMake(15, phoneTextField.deFrameBottom + 10);
        codeTextField.placeholder = @"输入手机验证码";
        codeTextField.borderStyle = UITextBorderStyleRoundedRect;
        codeTextField.font = [UIFont systemFontOfSize:14];
        codeTextField.clearButtonMode = UITextFieldViewModeWhileEditing;
        [_displayView addSubview:codeTextField];
        _codeTextField = codeTextField;
        
        rechargeBtn = [[UIButton alloc] init];
        rechargeBtn.frame = CGRectMake(15, codeTextField.deFrameBottom + 20, _displayView.deFrameWidth - 30, h);
        [rechargeBtn setBackgroundImage:[QTools createImageWithColor:ColorTheme] forState:UIControlStateNormal];
        rechargeBtn.titleLabel.font = [UIFont systemFontOfSize:16];
        [rechargeBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [rechargeBtn setTitle:@"充值成为洗车会员"forState:UIControlStateNormal];
        rechargeBtn.layer.cornerRadius = 2.f;
        rechargeBtn.layer.masksToBounds = YES;
        [rechargeBtn addTarget:self action:@selector(rechargeToMakeVip:) forControlEvents:UIControlEventTouchUpInside];
        [_displayView addSubview:rechargeBtn];
        
        UILabel *loginLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        loginLabel.backgroundColor = [UIColor clearColor];
        loginLabel.text = @"已有车夫账号，";
        loginLabel.textColor = [QTools colorWithRGB:85 :85 :85];
        loginLabel.font = [UIFont systemFontOfSize:15];
        [loginLabel sizeToFit];
        loginLabel.deFrameTop = rechargeBtn.deFrameBottom + 10;
        loginLabel.deFrameRight = _displayView.deFrameWidth - 80;
        [_displayView addSubview:loginLabel];
        
        UIButton *loginButton = [UIButton buttonWithType:UIButtonTypeCustom];
        loginButton.titleLabel.font = [UIFont systemFontOfSize:16];
        [loginButton setTitleColor:UIColorFromRGB(0xc40000) forState:UIControlStateNormal];
        [loginButton setTitle:@"请登录>" forState:UIControlStateNormal];
        [loginButton sizeToFit];
        loginButton.center = loginLabel.center;
        loginButton.deFrameLeft = loginLabel.deFrameRight ;
        [loginButton addTarget:self action:@selector(onLoginButton) forControlEvents:UIControlEventTouchUpInside];
        [_displayView addSubview:loginButton];
        
        _displayView.deFrameHeight = loginButton.deFrameBottom + 10;
    }
    else
    {
        CGFloat rechargeW = _displayView.deFrameWidth - 2*15;
        CGFloat rechargeH = 35;
        CGFloat rechargeBeforeW = 15.f;
        CGFloat rechargeTopH = selectBtn.deFrameBottom + 10;
        rechargeBtn = [[UIButton alloc] initWithFrame:CGRectMake(rechargeBeforeW, rechargeTopH, rechargeW, rechargeH)];
        [rechargeBtn setTitle:@"充值成为洗车会员" forState:UIControlStateNormal];
        [rechargeBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [rechargeBtn setBackgroundImage:[QTools createImageWithColor:ColorTheme] forState:UIControlStateNormal];
        rechargeBtn.titleLabel.font = [UIFont boldSystemFontOfSize:14];
        rechargeBtn.layer.masksToBounds = YES;
        rechargeBtn.layer.cornerRadius = 4.f;
        [rechargeBtn addTarget:self action:@selector(rechargeToMakeVip:) forControlEvents:UIControlEventTouchUpInside];
        [_displayView addSubview:rechargeBtn];
        
        _displayView.deFrameHeight = rechargeBtn.deFrameBottom + 10;
    }
    scrollView1.contentSize = CGSizeMake(scrollView1.deFrameWidth, _displayView.deFrameBottom);
}

#pragma mark - Action

- (void)sureToAgree:(UIGestureRecognizer *)sender{
    selectBtn.selected = !selectBtn.selected;
    rechargeBtn.enabled = selectBtn.selected;
}

- (void)agreeVipDelegate:(UIGestureRecognizer *)sender{
    [QViewController gotoPage:@"QAgreementPage" withParam:[[NSDictionary alloc] initWithObjectsAndKeys:[NSNumber numberWithInt:2], @"agreementType", nil]];
}

- (void)onSendCodeButton:(id)sender
{
    UIButton *button = (UIButton*)sender;
    
    if ([QRegularHelp validateUserPhone:_phoneTextField.text] == NO) {
        [ASRequestHUD showErrorWithStatus:@"电话号码输入有误"];
    }
    else {
        [QCountDown startTime:button];
        
        [[QHttpMessageManager sharedHttpMessageManager] accessAcquireCode:_phoneTextField.text andMessage:@"(提交订单验证码)"];
        [ASRequestHUD show];
    }
}

- (void)rechargeToMakeVip:(id)sender
{
    if ([QUser sharedQUser].isLogin)
    {
        [QViewController gotoPage:@"QVIPCardChong" withParam:[[NSDictionary alloc]
                                          initWithObjectsAndKeys:_selectCardDetailModel, @"cardModel",
                                            [NSNumber numberWithInteger:1],@"buy_type",nil]];
    }
    else
    {
        if ([QRegularHelp validateUserPhone:_phoneTextField.text] == NO) {
            [ASRequestHUD showErrorWithStatus:@"电话号码输入有误"];
        }
        else if ([_codeTextField.text isEqualToString:@""]){
            [ASRequestHUD showErrorWithStatus:@"验证码不能为空"];
        }
        else {
            
            //此处有两次网络交互,快速登录->下单
            [[QHttpMessageManager sharedHttpMessageManager] accessFindLoginPwd:_phoneTextField.text andVerifyCode:_codeTextField.text];
            [ASRequestHUD show];
        }
    }
}

- (void)onLoginButton
{
    [QViewController gotoPage:@"QAccountLogin" withParam:nil];
}


#pragma mark - Notification
- (void)successGetCardDetails:(NSNotification*)noti
{
    [ASRequestHUD dismiss];
    
    _cardDetails = noti.object;
    [self reloadTableView];
    
    //暂存数据
    [QCardDetailModel setCardDetailsModel:noti.object];
}

- (void)successQuickLogin:(NSNotification*)noti
{
    [ASRequestHUD dismiss];
    
    QLoginModel *loginModel = noti.object;
    if (loginModel) {
        [QUser sharedQUser].isLogin = YES;
        [loginModel savetoLocal:@""];
        
        if ([loginModel.member integerValue])
        {
            [QViewController gotoPage:@"QMyVIPCard" withParam:nil];
        }
        else
        {
            [QViewController gotoPage:@"QVIPCardChong" withParam:[[NSDictionary alloc]
                                                                  initWithObjectsAndKeys:_selectCardDetailModel, @"cardModel",
                                                                  [NSNumber numberWithInteger:1],@"buy_type",nil]];
        }
    }
}

- (void)successGetMyAccount:(NSNotification*)noti
{
    debug_NSLog(@"");
}

- (void)successGetVerifyCode:(NSNotification*)noti
{
    [ASRequestHUD dismiss];
}

#pragma mark - UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return _cardDetails ? (_cardDetails.count+1) : 1;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return QVIPCardRechargeCellHeight;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    static NSString *listID = @"list_ID";
    QVIPCardRechargeCell * cell = [tableView dequeueReusableCellWithIdentifier:listID];
    if (cell == nil) {
        cell = [[QVIPCardRechargeCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:listID];
        
    }
    cell.agreeImageView.image = [UIImage imageNamed:@"icon_collect_unselected"];
    if (indexPath.row == 0) {
        cell.userInteractionEnabled = NO;
        cell.agreeImageView.image = nil;
    }else if (indexPath.row == 1){
        cell.agreeImageView.image = [UIImage imageNamed:@"icon_collect_selected"];
        temImageView = cell.agreeImageView;
    }
    [cell configureModelForCell:_cardDetails andIndexPath:indexPath];
    return cell;
    
}

#pragma mark - UITableViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    temImageView.image = [UIImage imageNamed:@"icon_collect_unselected"];
    QVIPCardRechargeCell *newCell = (QVIPCardRechargeCell *)[tableView cellForRowAtIndexPath:indexPath];
    newCell.agreeImageView.image = [UIImage imageNamed:@"icon_collect_selected"];
    temImageView = newCell.agreeImageView;
    
    if (indexPath.row < _cardDetails.count + 1)
    {
        _selectCardDetailModel = [_cardDetails objectAtIndex:indexPath.row - 1];
    }
    
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

@end
