//
//  QConfirmOrderPage.m
//  HRClient
//
//  Created by chenyf on 14/12/22.
//  Copyright (c) 2014年 panyj. All rights reserved.
//

#import "QConfirmOrderPage.h"
#import "QViewController.h"
#import "QVIPRechargeCell.h"
#import "QMyListDetailModel.h"

//pay
#import "Order.h"
#import "APAuthV2Info.h"
#import <AlipaySDK/AlipaySDK.h>
#import "QAppDelegate.h"
#import "DataSigner.h"
#import "QProductDetail.h"
#import "QMyListModel.h"

#import "QHttpMessageManager.h"
#import "QCardDetailModel.h"

@interface QConfirmOrderPage ()
{
    QMyListDetailModel *_orderDetail;
    UITextField *txtPwd;
    QCardDetailModel *cardModel;
    BOOL bPayMode;
    UIButton *confirmPayButton;
}

@property (nonatomic,strong) UITableView *confirmOrderTableView;
@property (nonatomic,strong) UIButton *selectBtn;
@property (nonatomic,strong) UIButton *selAliPayBtn;
@property (nonatomic,strong) UIButton *selWXPayBtn;
@property (nonatomic,assign) payType pType;
//@property (nonatomic,assign) payWhat pComeWhat;
//@property (nonatomic,strong) NSString *strBillID;

@end

@implementation QConfirmOrderPage

#pragma mark - view

- (QCacheType)pageCacheType
{
    return kCacheTypeNone;
}

- (void)setActiveWithParams:(NSDictionary*)params
{
    _orderDetail = [params objectForKey:@"QMyListDetailModel"];
}

- (NSString *)title
{
    return @"确认支付";
}

- (void)pageEvent:(QPageEventType)eventType
{
    if (eventType == kPageEventWillShow)
    {
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(getPayResult:) name:kPayResult object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(getWXPayResult:) name:kWXPayResult object:nil];
    }
    else if (eventType == kPageEventWillHide)
    {
        [[NSNotificationCenter defaultCenter] removeObserver:self name:kPayResult object:nil];
        [[NSNotificationCenter defaultCenter] removeObserver:self name:kWXPayResult object:nil];
    }
    else if (eventType == kPageEventViewCreate)
    {
    }
}

- (UIView *)viewWithFrame:(CGRect)frame{
    if ([super viewWithFrame:frame]) {
        
        _pType = payType_none;
    
        _confirmOrderTableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, frame.size.width, frame.size.height) style:UITableViewStylePlain];
        _confirmOrderTableView.delegate = self;
        _confirmOrderTableView.dataSource = self;
        _confirmOrderTableView.backgroundColor = [QTools colorWithRGB:238 :238 :238];
        _confirmOrderTableView.tableFooterView = [UIView new];
        [_view addSubview:_confirmOrderTableView];
    }
    return _view;
}

#pragma mark - Private

- (UIButton*)payButton
{
    UIButton *button = [[UIButton alloc] initWithFrame:CGRectZero];
    [button setImage:[UIImage imageNamed:@"icon_agree_unselected"] forState:UIControlStateNormal];
    [button setImage:[UIImage imageNamed:@"icon_agree_selected"] forState:UIControlStateSelected];
    [button addTarget:self action:@selector(sureToAgree:) forControlEvents:UIControlEventTouchUpInside];
    return button;
}

- (void)successBuyWarry
{
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"提示"
                                                    message:@"恭喜您，已购买成功"
                                                   delegate:self
                                          cancelButtonTitle:@"返回商品详情"
                                          otherButtonTitles:@"查看我的消费券",nil];
    [alert show];
}

#pragma mark - UIAlertViewDelegate
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (buttonIndex == 0)
    {
        [QViewController gotoPage:@"QGroupBuyDetailPage" withParam:
         [NSDictionary dictionaryWithObjectsAndKeys:_orderDetail.productId, @"ProductID", nil]];
    }
    else if (buttonIndex == 1)
    {
        [QViewController gotoPage:@"QMyNoWarry" withParam:nil];
    }
}

#pragma mark - Action

- (void)sureToAgree:(id)sender
{
    _selectBtn.selected = NO;
    _selAliPayBtn.selected = NO;
    _selWXPayBtn.selected = NO;
    
    _pType = payType_none;
    
    UIButton *btn = (UIButton*)sender;
    btn.selected = !btn.selected;
    
    switch (btn.tag) {
        case 100000:
            _pType = payType_aliPay;
            break;
            
        case 100001:
            _pType = payType_balance;
            break;
        case 100002:
            _pType = payType_wxPay;
            break;
        default:
            break;
    }
    
    if (_selectBtn.enabled)
    {
        [_confirmOrderTableView reloadData];
    }
}

- (void)gotoForeget
{
    if([[ASUserDefaults objectForKey:AccountPayPasswd] isEqualToString:@"Y"])
        [QViewController gotoPage:@"QFindPayKey" withParam:nil];
    else
        [QViewController gotoPage:@"QSetPayKey" withParam:nil];
}

#pragma mark - Notification

- (void)getPayResult:(NSNotification*)notify
{
    if (self.selectBtn.selected)
    {
        if ([notify.object integerValue]  == 1)
        {
            //更新账户余额
            [[QUser sharedQUser] updateUserInfo];
            
            [self successBuyWarry];
        }
    }
    else if (self.selAliPayBtn.selected)
    {
        [self productPaybyAliPay];
    }
    
    [ASRequestHUD dismiss];
}

- (void)getWXPayResult:(NSNotification*)noti
{
    //微信支付结果返回
    if (WXSuccess == [noti.object intValue])
    {
        [self successBuyWarry];
    }
}

#pragma mark - UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    if ([_orderDetail.or_member integerValue])
        return 3;
    
    return 4;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if ([_orderDetail.or_member integerValue])
    {
        switch (section) {
            case 0:
                return 3;
            case 1:
                return 2;
            case 2:
                return 1;
            default:
                return 0;
        }
    }
    else
    {
        switch (section) {
            case 0:
                return 3;
            case 1:
                return _selectBtn.selected ? 2 : 1;
            case 2:
                return 2;//支付宝、微信支付
            case 3:
                return 1;
            default:
                return 0;
        }
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    if ([_orderDetail.or_member integerValue])
        return 12;
        
    if (section == 2) {
        return 45;
    } else {
        return 12;
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if ([_orderDetail.or_member integerValue])
    {
        return 46;
    }
    
    if (indexPath.section == 2) {
        return 50;
    }
    
    return 46;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    if (section == 2 && ![_orderDetail.or_member integerValue]) {
        // 支付方式
        UIView *headerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, tableView.deFrameWidth, 45)];
        UILabel *styleLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        styleLabel.backgroundColor = [UIColor clearColor];
        styleLabel.text = @"选择支付方式";
        styleLabel.font = [UIFont systemFontOfSize:15];
        [styleLabel sizeToFit];
        styleLabel.textColor = [QTools colorWithRGB:0 :0 :0];
        styleLabel.center = headerView.center;
        styleLabel.deFrameLeft = 16;
        [headerView addSubview:styleLabel];
        return headerView;
    }
    
    return nil;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    //支付宝支付
    if (indexPath.section == 2 && ![_orderDetail.or_member integerValue])
    {
        NSArray *arr = @[@{@"icon":@"pic02.png",@"title":@"支付宝支付",@"detail":@"推荐安装支付宝客户端的用户",@"select":@"yuan02.gif"},
                         /*@{@"icon":@"pic01.png",@"title":@"银行卡支付",@"detail":@"支持储蓄卡信用卡，无需开通网银",@"select":@"yuan01.gif"},*/
                         @{@"icon":@"pic03.png",@"title":@"微信支付",@"detail":@"推荐安装微信5.0及以上版本的用户",@"select":@"yuan02.gif"}];
        //
        static NSString *cellAlipayID = @"cellAlipayID";
        static NSString *cellWXPayID = @"cellWXPayID";
        QVIPRechargeCell *VIPRechargeCell;
        
        if (0 == indexPath.row) /*支付宝*/
        {
            VIPRechargeCell = [tableView dequeueReusableCellWithIdentifier:cellAlipayID];
            if (!VIPRechargeCell)
            {
                VIPRechargeCell = [[QVIPRechargeCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:cellAlipayID];
            }
            [VIPRechargeCell cofigureModelToCell:arr andIndexPath:indexPath];
            
            _selAliPayBtn = (UIButton*)[VIPRechargeCell.contentView viewWithTag:100000];
            if (_selAliPayBtn == nil)
            {
                _selAliPayBtn = [self payButton];
                _selAliPayBtn.frame = CGRectMake(VIPRechargeCell.frame.size.width - 62, 0, 62, 46);
                _selAliPayBtn.tag = 100000;
                [VIPRechargeCell.contentView addSubview:_selAliPayBtn];
            }
            _selAliPayBtn.selected = (_pType == payType_aliPay);
        }
        else /*微信*/
        {
            VIPRechargeCell = [tableView dequeueReusableCellWithIdentifier:cellWXPayID];
            if (!VIPRechargeCell)
            {
                VIPRechargeCell = [[QVIPRechargeCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:cellWXPayID];
            }
            [VIPRechargeCell cofigureModelToCell:arr andIndexPath:indexPath];
            
            _selWXPayBtn = (UIButton*)[VIPRechargeCell.contentView viewWithTag:100002];
            if (!_selWXPayBtn)
            {
                _selWXPayBtn = [self payButton];
                _selWXPayBtn.frame = CGRectMake(VIPRechargeCell.frame.size.width - 62, 0, 62, 46);
                _selWXPayBtn.tag = 100002;
                [VIPRechargeCell.contentView addSubview:_selWXPayBtn];
            }
            
            _selWXPayBtn.selected = (_pType == payType_wxPay);
        }

        return VIPRechargeCell;
    }
    else
    {
        static NSString *CellIdentifier = @"Cell_Identifier_SubmitOrder";
        
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
        if (nil == cell)
        {
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:CellIdentifier];
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
        }
        
        [cell.contentView.subviews makeObjectsPerformSelector:@selector(removeFromSuperview)];
        
        UILabel *titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(10, 0, tableView.deFrameWidth - 2*10, 46)];
        titleLabel.backgroundColor = [UIColor clearColor];
        titleLabel.textColor = [QTools colorWithRGB:85 :85 :85];
        titleLabel.font = [UIFont systemFontOfSize:15];
        [cell.contentView addSubview:titleLabel];
        
        UILabel *detailLabel = [[UILabel alloc] initWithFrame:CGRectMake(10, 0, tableView.deFrameWidth - 2*10, 46)];
        detailLabel.backgroundColor = [UIColor clearColor];
        detailLabel.textColor = UIColorFromRGB(0xc40000);
        detailLabel.font = [UIFont systemFontOfSize:15];
        detailLabel.textAlignment = NSTextAlignmentRight;
        [cell.contentView addSubview:detailLabel];
        
        //产品信息
        if (indexPath.section == 0)
        {
            if (indexPath.row == 0)
            {
                titleLabel.text = _orderDetail.subject;
                
                NSString *strPrice = [NSString stringWithFormat:@"%.2f",[_orderDetail.total doubleValue] / [_orderDetail.quantity integerValue]];
                detailLabel.text = [strPrice stringByAppendingString:@"元"];
                [detailLabel sizeToFit];
                detailLabel.deFrameRight = tableView.deFrameWidth - 10;
                detailLabel.deFrameHeight = 46;
                
                titleLabel.deFrameWidth = detailLabel.deFrameLeft - titleLabel.deFrameLeft;
            }
            else if (indexPath.row == 1)
            {
                titleLabel.text = @"数量：";
                detailLabel.text = [NSString stringWithFormat:@"%d", [_orderDetail.quantity intValue]];
            }
            else if (indexPath.row == 2)
            {
                titleLabel.text = @"总价：";
                detailLabel.text = [[NSString stringWithFormat:@"%.2f",[_orderDetail.total doubleValue]] stringByAppendingString:@"元"];
            }

        }
        //余额
        else if (indexPath.section == 1 /*&& _pComeWhat == payWhat_product*/)
        {
            if (indexPath.row == 0)
            {
                if ([_orderDetail.or_member integerValue] == 1) {
                    
                    QMyAccountMoel *model = [QUser sharedQUser].vipAccount;
                    if (model.balance)
                        titleLabel.text = [@"洗车卡余额：" stringByAppendingString:[NSString stringWithFormat:@"%.2f元",[model.balance doubleValue]]];
                    else
                        titleLabel.text = @"洗车卡余额：0元";
                    
                }
                else
                {
                    QMyAccountMoel *model = [QUser sharedQUser].normalAccount;
                    if (model.balance)
                        titleLabel.text = [@" 账户余额：" stringByAppendingString:[NSString stringWithFormat:@"%.2f元",[model.balance doubleValue]]];
                    else
                        titleLabel.text = @"洗车卡余额：0元";
                }

                self.selectBtn = [[UIButton alloc] initWithFrame:CGRectMake(cell.frame.size.width - 62, 0, 62, 46)];
                self.selectBtn.tag = 100001;
                [self.selectBtn setImage:[UIImage imageNamed:@"icon_agree_unselected"] forState:UIControlStateNormal];
                [self.selectBtn setImage:[UIImage imageNamed:@"icon_agree_selected"] forState:UIControlStateSelected];
                [self.selectBtn addTarget:self action:@selector(sureToAgree:) forControlEvents:UIControlEventTouchUpInside];
                
                self.selectBtn.enabled = !([[QUser sharedQUser].normalAccount.balance doubleValue] < [_orderDetail.total doubleValue]);
                self.selectBtn.selected = (_pType == payType_balance);
                
                if ([_orderDetail.or_member integerValue])
                {
                    self.selectBtn.enabled = YES;
                    self.selectBtn.selected = YES;
                }
                [cell.contentView addSubview:self.selectBtn];
            }
            else
            {
                titleLabel.text = @"支付密码：";
                txtPwd = [[UITextField alloc]initWithFrame:CGRectMake(90, 8, 100, 30)];
                txtPwd.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
                txtPwd.font = [UIFont systemFontOfSize:12.f];
                txtPwd.textColor = [QTools colorWithRGB:85 :85 :85];
                txtPwd.textAlignment = NSTextAlignmentRight;
                txtPwd.borderStyle = UITextBorderStyleBezel;
                txtPwd.placeholder = @"请输入支付密码";
                txtPwd.secureTextEntry = YES;
                [cell.contentView addSubview:txtPwd];
                
                UIButton *forgetBtn = [UIButton buttonWithType:UIButtonTypeCustom];
                forgetBtn.titleLabel.font = [UIFont systemFontOfSize:13.f];
                forgetBtn.frame = CGRectMake(cell.frame.size.width - 100, 15, 100, 30);
                
                NSString *strTipInfo;
                if([[ASUserDefaults objectForKey:AccountPayPasswd] isEqualToString:@"Y"])
                    strTipInfo = @"忘记密码";
                else
                    strTipInfo = @"请设置支付密码";
                
                NSMutableAttributedString *content = [[NSMutableAttributedString alloc] initWithString:strTipInfo];
                NSRange contentRange = {0, [content length]};
                [content addAttribute:NSUnderlineStyleAttributeName value:[NSNumber numberWithInteger:NSUnderlineStyleSingle] range:contentRange];
                [forgetBtn setTitle:strTipInfo forState:UIControlStateNormal];
                [forgetBtn titleLabel].attributedText = content;
                [forgetBtn setTitleColor:ColorTheme forState:UIControlStateNormal];
                [forgetBtn addTarget:self action:@selector(gotoForeget) forControlEvents:UIControlEventTouchUpInside];
                [cell.contentView addSubview:forgetBtn];
            
            }
        }
        else if(indexPath.section == 3 || ([_orderDetail.or_member integerValue] && indexPath.section == 2))
        {
            confirmPayButton = [UIButton buttonWithType:UIButtonTypeCustom];
            confirmPayButton.layer.cornerRadius = 4.f;
            confirmPayButton.layer.masksToBounds = YES;
            confirmPayButton.frame = CGRectMake(16, 5, cell.contentView.deFrameWidth - 16 * 2, 36);
            confirmPayButton.backgroundColor = UIColorFromRGB(0xc40000);
            confirmPayButton.titleLabel.font = [UIFont systemFontOfSize:15];
            [confirmPayButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
            [confirmPayButton setTitle:@"确认支付" forState:UIControlStateNormal];
            [confirmPayButton addTarget:self action:@selector(confirmPayButtonTapped) forControlEvents:UIControlEventTouchUpInside];
            [cell.contentView addSubview:confirmPayButton];
        }
        
        return cell;
    }
}

#pragma mark - Private

- (void)productPaybyAliPay
{
    QAppDelegate *appDelegate = [UIApplication sharedApplication].delegate;
    
    //partner和seller获取失败,提示
    if ([appDelegate.partner length] == 0 ||
        [appDelegate.seller length] == 0 ||
        [appDelegate.privateKey length] == 0)
    {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"提示"
                                                        message:@"缺少partner或者seller或者私钥。"
                                                       delegate:self
                                              cancelButtonTitle:@"确定"
                                              otherButtonTitles:nil];
        [alert show];
        return;
    }
    
    Order *order = [[Order alloc] init];
    order.partner = appDelegate.partner;
    order.seller = appDelegate.seller;
    order.tradeNO = _orderDetail.orderListNo;
    order.productName = _orderDetail.subject;
//        order.productDescription = _orderDetail.serviceDesc;
    order.amount = [_orderDetail.total stringValue]; //商品价格
    NSLog(@"%.2f",[_orderDetail.total doubleValue]);
    order.notifyURL = @"http://121.41.116.252/appapi/pay/payAlipay"; //回调URL
    order.service = @"mobile.securitypay.pay";
    order.paymentType = @"1";
    order.inputCharset = @"utf-8";
    order.itBPay = @"30m";
    order.showUrl = @"m.alipay.com";
    
    //应用注册scheme,在AlixPayDemo-Info.plist定义URL types
    NSString *appScheme = @"HRClient";
    
    //将商品信息拼接成字符串
    NSString *orderSpec = [order description];
    debug_NSLog(@"orderSpec = %@",orderSpec);
    
    //获取私钥并将商户信息签名,外部商户可以根据情况存放私钥和签名,只需要遵循 RSA 签名规范, 并将签名字符串 base64 编码和 UrlEncode
    id<DataSigner> signer = CreateRSADataSigner(appDelegate.privateKey);
    NSString *signedString = [signer signString:orderSpec];
    
    //将签名成功字符串格式化为订单字符串,请严格按照该格式
    NSString *orderString = nil;
    if (signedString != nil) {
        orderString = [NSString stringWithFormat:@"%@&sign=\"%@\"&sign_type=\"%@\"", orderSpec, signedString, @"RSA"];
        [[AlipaySDK defaultService] payOrder:orderString fromScheme:appScheme callback:^(NSDictionary *resultDic) {
            debug_NSLog(@"reslut = %@",resultDic);
            
            NSString *resultStatus = [resultDic objectForKey:@"resultStatus"];
            if ([resultStatus isEqualToString:@"9000"])
            {
                [self performSelectorOnMainThread:@selector(successBuyWarry) withObject:nil waitUntilDone:NO];
            }
        }];
    }
}

- (void)backToEnable
{
    confirmPayButton.enabled = YES;
}

- (void)confirmPayButtonTapped
{
    confirmPayButton.enabled = NO;
    [self performSelector:@selector(backToEnable) withObject:nil afterDelay:2.f];
    
    if (_pType != payType_none || [_orderDetail.or_member integerValue])
    {
        [self productPay];
    }
    else
    {
        [QViewController showMessage:@"请选择您的支付方式."];
    }
}

- (void)productPay
{
    BOOL isAliPay = NO;
    NSString *pwd = txtPwd.text;
    
    if (self.selectBtn.selected)    //余额支付
    {
        if ([pwd isEqualToString:@""])
        {
            [ASRequestHUD showErrorWithStatus:@"支付密码输入不能为空！"];
            return;
        }
    }
    else if (self.selAliPayBtn.selected)//支付宝支付
    {
        isAliPay = YES;
        pwd = nil;
    }
    
    if (_orderDetail.orderListNo.length > 0)
    {
        if ([[ASUserDefaults objectForKey:AccountPayPasswd] isEqualToString:@"Y"])
        {
            if (self.selWXPayBtn.selected) //微信支付
            {
                [[QAppDelegate appDelegate] sendWXPay:_orderDetail.orderListNo name:_orderDetail.subject price:[_orderDetail.total doubleValue]];
            }
            else if (self.selAliPayBtn.selected)
            {
                [[QHttpMessageManager sharedHttpMessageManager] payAction:pwd andOrderListId:_orderDetail.orderListId.stringValue andPayType:isAliPay];
                [ASRequestHUD show];
            }
        }
        else
        {
            [QViewController gotoPage:@"QSetPayKey" withParam:nil];
        }
    }
    else
    {
        [QViewController showMessage:@"无效的订单号！"];
    }
}


@end
