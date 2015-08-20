//
//  QSubmitOrderPage.m
//  HRClient
//
//  Created by chenyf on 14/12/20.
//  Copyright (c) 2014年 panyj. All rights reserved.
//  提交订单

#import "QSubmitOrderPage.h"
#import "QViewController.h"
#import "QRegularHelp.h"
#import "QProductDetail.h"
#import "QHttpMessageManager.h"
#import "QCountDown.h"
#import "QMyListModel.h"

@interface QSubmitOrderPage ()
{
    BOOL _successAddOrderList;
    double totalPrice;
    QMyListDetailModel *detailModel;
    BOOL bMoneyIsFull;
    
    UILabel *_lbProductTitle;
}
@property (nonatomic, strong) QProductDetail *productDetail;
@property (nonatomic, strong) UIView *footerView;
@property (nonatomic, strong) UITableView *orderTableView;
@property (nonatomic, strong) UITextField *countTextField;
@property (nonatomic, strong) UITextField *phoneTextField;
@property (nonatomic, strong) UITextField *codeTextField;

@end

@implementation QSubmitOrderPage

#pragma mark - view

- (NSString *)title
{
    return @"提交订单";
}

- (QCacheType)pageCacheType
{
    return _successAddOrderList ? kCacheTypeNone : kCacheTypeCommon;
}

- (void)setActiveWithParams:(NSDictionary *)params
{
    QProductDetail *productDetail = [params objectForKey:@"ProductDetail"];
    if (productDetail) {
        _productDetail = productDetail;
    }
}

- (void)pageEvent:(QPageEventType)eventType
{
    if (eventType == kPageEventWillShow)
    {
        _orderTableView.tableFooterView = [self footerViewbyLoginStatus:[QUser sharedQUser].isLogin frame:self.view.frame];
        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(successAddList:) name:kAddList object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(successRetList:) name:kRetList object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(successAcquireCode:) name:kAcquireCode object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(successQuickLogin:) name:kFindLoginPwd object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(successGetListDetail:) name:kGetMyListDetail object:nil];
    }
    else if (eventType == kPageEventWillHide)
    {
        [[NSNotificationCenter defaultCenter] removeObserver:self];
    }
}

- (void)hideKeyBoard
{
    [self.countTextField resignFirstResponder];
    
    int count = [self.countTextField.text intValue];
    self.countTextField.text = [NSString stringWithFormat:@"%d", count];
    
    [_orderTableView reloadRowsAtIndexPaths:[NSArray arrayWithObject:[NSIndexPath indexPathForRow:2 inSection:0]] withRowAnimation:UITableViewRowAnimationNone];
}

- (UIView *)viewWithFrame:(CGRect)frame
{
    if ([super viewWithFrame:frame])
    {
        _orderTableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, frame.size.width, frame.size.height) style:UITableViewStylePlain];
        _orderTableView.delegate = self;
        _orderTableView.dataSource = self;
        _orderTableView.backgroundColor = [QTools colorWithRGB:238 :238 :238];
        
        UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, _orderTableView.deFrameWidth, 46)];
        view.backgroundColor = [UIColor clearColor];
        UILabel *label = [[UILabel alloc]initWithFrame:CGRectMake(10, 0, view.deFrameWidth - 2*10, 46)];
        label.adjustsFontSizeToFitWidth = YES;
        label.backgroundColor = [UIColor clearColor];
        label.font = [UIFont systemFontOfSize:15];
        label.textColor = [QTools colorWithRGB:85 :85 :85];
        label.text = NSString_No_Nil(_productDetail.subject);
        [view addSubview:label];
        _lbProductTitle = label;
        _orderTableView.tableHeaderView = view;
        
        totalPrice = 0.0f;
        
        bMoneyIsFull = YES; //默认会员卡余额充足
        
        //增加手势
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(hideKeyBoard)];
        [_orderTableView addGestureRecognizer:tap];
        
        [_view addSubview:_orderTableView];
    }
    
    return _view;
}

#pragma mark - Private

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (buttonIndex == 0)
    {
        //返回商品详情
        [QViewController backPageWithParam:nil];
    }
    else if (buttonIndex == 1)
    {
        //充值
        [QViewController gotoPage:@"QMyVIPCard" withParam:nil];
    }
    else if (buttonIndex == 2)
    {
        //立即购买
        NSString *strBidType = [self.productDetail.productBid objectForKey:@"bidType"];
        [[QHttpMessageManager sharedHttpMessageManager] accessAddList:[self.productDetail.productId stringValue]
                                                          andQuantity:self.countTextField.text andBidType:strBidType];
        [ASRequestHUD show];
    }
}

- (void)onSubmitButton
{
    if ([QUser sharedQUser].isLogin)
    {
        //准备下单
        NSString *strBidType;
        
        if ([QUser sharedQUser].isVIP && self.productDetail.usrMbrPrice)
        {
            if ( ([[QUser sharedQUser].vipAccount.balance doubleValue] == 0) || ([[self.productDetail.usrMbrPrice objectForKey:@"memberUnitPrice"] doubleValue] > [[QUser sharedQUser].vipAccount.balance doubleValue]))
            {
                
                /*
                UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"提示"
                                                                message:@"您的会员卡余额不足"
                                                               delegate:self
                                                      cancelButtonTitle:@"返回商品详情"
                                                      otherButtonTitles:@"充值",@"立即购买",nil];
                [alert show];*/
                
                bMoneyIsFull = NO;
                
                //立即购买
                NSString *strBidType = [self.productDetail.productBid objectForKey:@"bidType"];
                [[QHttpMessageManager sharedHttpMessageManager] accessAddList:[self.productDetail.productId stringValue]
                                                                  andQuantity:self.countTextField.text andBidType:strBidType];
                [ASRequestHUD show];
                
                return;
            }
            else
            {
                strBidType = @"2"; //写死
            }
        }
        else
        {
            if (self.productDetail.productBid)
            {
                strBidType = [self.productDetail.productBid objectForKey:@"bidType"];
            }
        }
        
        [[QHttpMessageManager sharedHttpMessageManager] accessAddList:[self.productDetail.productId stringValue] andQuantity:self.countTextField.text andBidType:strBidType];
        [ASRequestHUD show];
    }
    else {
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

- (void)onBindButton
{
    [QViewController gotoPage:@"QChangeTel" withParam:nil];
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

- (void)onPlusButton
{
    int count = [self.countTextField.text intValue];
    ++count;
    self.countTextField.text = [NSString stringWithFormat:@"%d", count];
    
    [_orderTableView reloadRowsAtIndexPaths:[NSArray arrayWithObject:[NSIndexPath indexPathForRow:2 inSection:0]] withRowAnimation:UITableViewRowAnimationNone];
}

- (void)onMinusButton
{
    int count = [self.countTextField.text intValue];
    if (count>1) --count;
    self.countTextField.text = [NSString stringWithFormat:@"%d", count];
    
    [_orderTableView reloadRowsAtIndexPaths:[NSArray arrayWithObject:[NSIndexPath indexPathForRow:2 inSection:0]] withRowAnimation:UITableViewRowAnimationNone];
}


- (UIView*)footerViewbyLoginStatus:(BOOL)isLogin frame:(CGRect)frame
{
    UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, frame.size.width, 230)];
    if (isLogin)
    {
        UILabel *infoLabel = [[UILabel alloc] init];
        infoLabel.backgroundColor = [UIColor clearColor];
        infoLabel.text = @"您绑定的手机号码";
        infoLabel.font = [UIFont systemFontOfSize:16];
        infoLabel.textColor = [QTools colorWithRGB:85 :85 :85];
        [infoLabel sizeToFit];
        infoLabel.deFrameOrigin = CGPointMake(16, 12);
        [view addSubview:infoLabel];
        
        UIView *phoneView = [[UIView alloc] initWithFrame:CGRectMake(15, 40, _view.deFrameWidth - 16 * 2, 35)];
        phoneView.backgroundColor = [UIColor whiteColor];
        phoneView.layer.borderColor = [ColorLine CGColor];
        phoneView.layer.borderWidth = 0.5;
        [view addSubview:phoneView];
        
        NSString *phone = [ASUserDefaults objectForKey:LoginUserPhone];
        UILabel *phoneLabel = [[UILabel alloc] initWithFrame:CGRectMake(10, 0, 100, 35)];
        phoneLabel.text = [QRegularHelp blurMobile:phone];
        phoneLabel.font = [UIFont systemFontOfSize:15];
        phoneLabel.textColor = [QTools colorWithRGB:136 :136 :136];
        phoneLabel.backgroundColor = [UIColor clearColor];
        [phoneView addSubview:phoneLabel];
        
        UIButton *bindButton = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 115, 35)];
        bindButton.titleLabel.font = [UIFont systemFontOfSize:15];
        [bindButton setTitleColor:ColorTheme forState:UIControlStateNormal];
        [bindButton setTitle:@"绑定新号码" forState:UIControlStateNormal];
        bindButton.center = phoneLabel.center;
        bindButton.deFrameRight = phoneView.deFrameWidth - 10;
        [bindButton addTarget:self action:@selector(onBindButton) forControlEvents:UIControlEventTouchUpInside];
        [phoneView addSubview:bindButton];
        
        UIImageView *arrowImageView = [[UIImageView alloc] initWithImage:IMAGEOF(@"icon_order_arrow")];
        [bindButton addSubview:arrowImageView];
        arrowImageView.deFrameTop = (bindButton.deFrameHeight - arrowImageView.deFrameHeight)/2;
        arrowImageView.deFrameRight = bindButton.deFrameWidth;
        
        UIButton *submitButton = [UIButton buttonWithType:UIButtonTypeCustom];
        submitButton.frame = CGRectMake(15, phoneView.deFrameBottom + 20, view.deFrameWidth - 30, 35);
        [submitButton setBackgroundImage:[QTools createImageWithColor:ColorTheme] forState:UIControlStateNormal];
        submitButton.titleLabel.font = [UIFont systemFontOfSize:18];
        [submitButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [submitButton setTitle:@"提交订单" forState:UIControlStateNormal];
        submitButton.layer.cornerRadius = 2.f;
        submitButton.layer.masksToBounds = YES;
        [submitButton addTarget:self action:@selector(onSubmitButton) forControlEvents:UIControlEventTouchUpInside];
        [view addSubview:submitButton];
    }
    else
    {
        CGFloat h = 35.f;
        
        UIButton *sendCodeButton = [[UIButton alloc] init];
        sendCodeButton.deFrameSize = CGSizeMake(113, h - 2);
        sendCodeButton.deFrameTop = 10;
        sendCodeButton.deFrameRight = view.deFrameWidth - 18;
        [sendCodeButton setBackgroundImage:[QTools createImageWithColor:ColorTheme] forState:UIControlStateNormal];
        sendCodeButton.titleLabel.font = [UIFont systemFontOfSize:15];
        [sendCodeButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [sendCodeButton setTitle:@"发送验证码" forState:UIControlStateNormal];
        sendCodeButton.layer.cornerRadius = 2.5f;
        sendCodeButton.layer.masksToBounds = YES;
        [sendCodeButton addTarget:self action:@selector(onSendCodeButton:) forControlEvents:UIControlEventTouchUpInside];
        [view addSubview:sendCodeButton];
        
        UITextField *phoneTextField = [[UITextField alloc] init];
        phoneTextField.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
        phoneTextField.deFrameSize = CGSizeMake(_view.deFrameWidth - 18 - sendCodeButton.deFrameWidth - 10 - 15, h);
        phoneTextField.deFrameOrigin = CGPointMake(15, sendCodeButton.deFrameTop);
        phoneTextField.placeholder = @"输入手机号码";
        phoneTextField.borderStyle = UITextBorderStyleRoundedRect;
        phoneTextField.font = [UIFont systemFontOfSize:14];
        phoneTextField.clearButtonMode = UITextFieldViewModeWhileEditing;
        [view addSubview:phoneTextField];
        _phoneTextField = phoneTextField;
        
        UITextField *codeTextField = [[UITextField alloc] init];
        codeTextField.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
        codeTextField.deFrameSize = CGSizeMake(_view.deFrameWidth - 18 - 15, h);
        codeTextField.deFrameOrigin = CGPointMake(15, phoneTextField.deFrameBottom + 10);
        codeTextField.placeholder = @"输入手机验证码";
        codeTextField.borderStyle = UITextBorderStyleRoundedRect;
        codeTextField.font = [UIFont systemFontOfSize:14];
        codeTextField.clearButtonMode = UITextFieldViewModeWhileEditing;
        [view addSubview:codeTextField];
        _codeTextField = codeTextField;
        
        UIButton *submitButton = [[UIButton alloc] init];
        submitButton.frame = CGRectMake(15, codeTextField.deFrameBottom + 20, view.deFrameWidth - 30, h);
        [submitButton setBackgroundImage:[QTools createImageWithColor:ColorTheme] forState:UIControlStateNormal];
        submitButton.titleLabel.font = [UIFont systemFontOfSize:16];
        [submitButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [submitButton setTitle:@"提交订单" forState:UIControlStateNormal];
        submitButton.layer.cornerRadius = 2.f;
        submitButton.layer.masksToBounds = YES;
        [submitButton addTarget:self action:@selector(onSubmitButton) forControlEvents:UIControlEventTouchUpInside];
        [view addSubview:submitButton];
        
        UILabel *loginLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        loginLabel.backgroundColor = [UIColor clearColor];
        loginLabel.text = @"已有车夫账号，";
        loginLabel.textColor = [QTools colorWithRGB:85 :85 :85];
        loginLabel.font = [UIFont systemFontOfSize:15];
        [loginLabel sizeToFit];
        loginLabel.deFrameTop = submitButton.deFrameBottom + 10;
        loginLabel.deFrameRight = view.deFrameWidth - 80;
        [view addSubview:loginLabel];
        
        UIButton *loginButton = [UIButton buttonWithType:UIButtonTypeCustom];
        loginButton.titleLabel.font = [UIFont systemFontOfSize:16];
        [loginButton setTitleColor:UIColorFromRGB(0xc40000) forState:UIControlStateNormal];
        [loginButton setTitle:@"请登录>" forState:UIControlStateNormal];
        [loginButton sizeToFit];
        loginButton.center = loginLabel.center;
        loginButton.deFrameLeft = loginLabel.deFrameRight ;
        [loginButton addTarget:self action:@selector(onLoginButton) forControlEvents:UIControlEventTouchUpInside];
        [view addSubview:loginButton];
    }
    [view sizeToFit];
    return view;
}


#pragma mark - Notification

//立即购买的返回
- (void)successGetListDetail:(NSNotification *)noti
{
    detailModel = noti.object;
    [ASRequestHUD dismiss];
    
    NSString *strPage = @"";
    
    if (bMoneyIsFull)
        strPage = @"QConfirmOrderPage";
    else
        strPage = @"QConfirmOrderPageEx";
    
    [QViewController gotoPage:strPage withParam:[[NSDictionary alloc]
            initWithObjectsAndKeys:detailModel, @"QMyListDetailModel",_productDetail, @"productDetail",nil]];
}

- (void)successRetList:(NSNotification*)noti
{
    QMyListModel *model = noti.object;
    [ASRequestHUD dismiss];
    
    //未付款 到订单详情页面付款
    if (model.status.intValue == 1)
    {
        [QViewController gotoPage:@"QMyList" withParam:nil];
    }
    //查看车夫劵
    else
    {
        //detailModel
        //_productDetail
        [QViewController gotoPage:@"QConfirmOrderPageEx" withParam:[[NSDictionary alloc]
                                                                    initWithObjectsAndKeys:@"YES", @"fromPurChased",_productDetail, @"productDetail",nil]];
    }
}

- (void)successAddList:(NSNotification*)noti
{
    //[ASRequestHUD dismiss];
    
    _successAddOrderList = YES;
    
    QMyListModel *model = noti.object;
    
    if (model.status.integerValue == 1) //未付款
    {
        [[QHttpMessageManager sharedHttpMessageManager] accessMyListDetail:model.orderListId.stringValue andStatus:@"1"];
    }
    
    //[QViewController gotoPage:@"QListDetail" withParam:[[NSDictionary alloc] initWithObjectsAndKeys:model.orderListId, @"orderListId", model.status, @"status", nil]];
}

- (void)successAcquireCode:(NSNotification*)noti
{
    [ASRequestHUD dismiss];
}

- (void)successQuickLogin:(NSNotification*)noti
{
    QLoginModel *model = noti.object;
    if (!model) {
        [QViewController showMessage:@"登录失败"];
    }
    else{
        [QUser sharedQUser].isLogin = YES;
        [model savetoLocal:@""];
        
        //准备下单
        NSString *strBidType;
        
        if (self.productDetail.productBid)
            
        {
            strBidType = [self.productDetail.productBid objectForKey:@"bidType"];
        }
        else if (self.productDetail.usrMbrPrice)
            
        {
            strBidType = [self.productDetail.usrMbrPrice objectForKey:@"bidType"];
        }

        [[QHttpMessageManager sharedHttpMessageManager] accessAddList:[self.productDetail.productId stringValue] andQuantity:self.countTextField.text andBidType:strBidType];
    }
}

#pragma mark - UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 3;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell_Identifier_SubmitOrder";
    static NSString *CellCount = @"CellCount";
    
    UITableViewCell *cell;
    if (indexPath.row == 1) {
        
        cell = [tableView dequeueReusableCellWithIdentifier:CellCount];
        
        if (nil == cell) {
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1
                                          reuseIdentifier:CellCount];
            cell.selectionStyle = UITableViewCellAccessoryDisclosureIndicator;
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
            
            cell.textLabel.textColor = [QTools colorWithRGB:85 :85 :85];
            cell.textLabel.font = [UIFont systemFontOfSize:15];
            cell.textLabel.text = @"数量：";
            
            UIButton *plusButton = [UIButton buttonWithType:UIButtonTypeCustom];
            [plusButton setImage:IMAGEOF(@"plus") forState:UIControlStateNormal];
            [plusButton sizeToFit];
            plusButton.deFrameRight = SCREEN_SIZE_WIDTH - 20;
            plusButton.deFrameTop = 8;
            [plusButton addTarget:self action:@selector(onPlusButton) forControlEvents:UIControlEventTouchUpInside];
            [cell.contentView addSubview:plusButton];
            
            UITextField *countTextField = [[UITextField alloc] init];
            countTextField.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
            countTextField.deFrameSize = CGSizeMake(60, 30);
            countTextField.deFrameTop = 8;
            countTextField.deFrameRight = plusButton.deFrameLeft - 9;
            countTextField.text = @"1";
            countTextField.textAlignment = NSTextAlignmentCenter;
            countTextField.borderStyle = UITextBorderStyleRoundedRect;
            countTextField.keyboardType = UIKeyboardTypePhonePad;
            [cell.contentView addSubview:countTextField];
            self.countTextField = countTextField;
            
            UIButton *minusButton = [UIButton buttonWithType:UIButtonTypeCustom];
            [minusButton setImage:IMAGEOF(@"minus") forState:UIControlStateNormal];
            [minusButton sizeToFit];
            minusButton.deFrameRight = countTextField.deFrameLeft - 10;
            minusButton.deFrameTop = 8;
            [minusButton addTarget:self action:@selector(onMinusButton) forControlEvents:UIControlEventTouchUpInside];
            [cell.contentView addSubview:minusButton];
            
            if ([_productDetail.or_member integerValue]) //会员产品只能购买一份*一天
            {
                plusButton.enabled = NO;
                countTextField.enabled = NO;
                minusButton.enabled = NO;
            }
        }
        //
    }
    else {
        cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
        if (nil == cell) {
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1
                                          reuseIdentifier:CellIdentifier];
            cell.selectionStyle = UITableViewCellAccessoryDisclosureIndicator;
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
            
            cell.textLabel.textColor = [QTools colorWithRGB:85 :85 :85];
            cell.textLabel.font = [UIFont systemFontOfSize:15];
            
            cell.detailTextLabel.textColor = UIColorFromRGB(0xc40000);
            cell.detailTextLabel.font = [UIFont systemFontOfSize:15];
            
        }
        cell.textLabel.font = [UIFont systemFontOfSize:15];
        if (indexPath.row == 2 || indexPath.row == 0)
        {
            cell.textLabel.text = (indexPath.row == 2) ? @"总价：" : @"单价：";
            
            NSUInteger count = [self.countTextField.text intValue];
            
            if([QUser sharedQUser].isVIP && self.productDetail.usrMbrPrice != nil)
            {
                 totalPrice = count * [[self.productDetail.usrMbrPrice objectForKey:@"memberUnitPrice"] doubleValue];
            }
            else
            {
                 totalPrice = count * [[self.productDetail.productBid objectForKey:@"bidPrice"] doubleValue];
            }
            
            NSString *priceStr = @"";
            if([QUser sharedQUser].isVIP && self.productDetail.usrMbrPrice != nil)
            {
                priceStr = [self.productDetail.usrMbrPrice objectForKey:@"memberUnitPrice"];
            }
            else
            {
                priceStr = [self.productDetail.productBid objectForKey:@"bidPrice"];
            }
            
            cell.detailTextLabel.text = (indexPath.row == 2) ?
            [NSString stringWithFormat:@"%.2f元", totalPrice]:
            [NSString stringWithFormat:@"%@元", priceStr];
        }
    }
    
    return cell;
}

#pragma mark - UITableViewDelegate
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 46;
}

@end
