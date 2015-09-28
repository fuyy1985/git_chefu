//
//  QVIPCardChong.m
//  HRClient
//
//  Created by ekoo on 14/12/17.
//  Copyright (c) 2014年 panyj. All rights reserved.
//

#import "QVIPCardChong.h"
#import "QVIPRechargeCell.h"
#import "QViewController.h"
#import "QCardDetailModel.h"

#import "QHttpMessageManager.h"
#import "QCardDetailModel.h"

//pay
#import "Order.h"
#import "APAuthV2Info.h"
#import <AlipaySDK/AlipaySDK.h>
#import "QAppDelegate.h"
#import "DataSigner.h"

@interface QVIPCardChong ()
{
    payType _chongPayType;
}

@property (nonatomic)UITableView *VIPTableView;
@property (nonatomic,strong)NSString *strAmout; //普通账户充值金额
@property (nonatomic,assign)NSInteger buyType; //付款类型
@property (nonatomic,strong)QCardDetailModel *vipModel; //会员卡模型

@property (nonatomic,strong) NSString *strBillID;
@property (nonatomic,strong) NSString *strAccBillID;

@property (nonatomic,strong) NSString *mbrTypeId;
@property (nonatomic,strong) NSString *titleInfo;

@end

@implementation QVIPCardChong

- (NSString *)title{
    return @"账户充值";
}

- (void)setActiveWithParams:(NSDictionary*)params //NOTE:方便页面激活时接收参数
{
    _buyType = [[params objectForKey:@"buy_type"] integerValue];
    
    if (_buyType == BuyType_normalCharge) //普通账户充值
    {
        _strAmout = [params objectForKey:@"noramlAccAmount"];
    }
    else if (_buyType == BuyType_vipCard) //购买会员卡
    {
        _vipModel = [params objectForKey:@"cardModel"];
    }
    else if (_buyType == BuyType_vipCardCharge) //充值会员卡
    {
        _strAmout = [params objectForKey:@"vipChargeAmount"];
        _mbrTypeId = ((NSNumber*)[params objectForKey:@"mbrTypeId"]).stringValue;
        _titleInfo = [params objectForKey:@"titleInfo"];
    }
}

- (void)pageEvent:(QPageEventType)eventType
{
    if (eventType == kPageEventWillShow)
    {
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(createVipOrderPrepaidBillId:)
                                                     name:kCreatVipPrePayID
                                                   object:nil];
        
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(createAccOrderPrepaidBillId:)
                                                     name:kCreatAccPrePayID
                                                   object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(getWXPayResult:) name:kWXPayResult object:nil];
    }
    else if (eventType == kPageEventWillHide)
    {
        [[NSNotificationCenter defaultCenter] removeObserver:self name:kCreatVipPrePayID object:nil];
        [[NSNotificationCenter defaultCenter] removeObserver:self name:kCreatAccPrePayID object:nil];
        [[NSNotificationCenter defaultCenter] removeObserver:self name:kWXPayResult object:nil];
    }
    else if (eventType == kPageEventViewCreate)
    {
        /*默认支付宝*/
        _chongPayType = payType_aliPay;
        
        NSString *regionID = [[ASUserDefaults objectForKey:CurrentRegionID] stringValue];
        if (_buyType == BuyType_normalCharge) //普通账户充值
        {
            NSString *accountID = [[QUser sharedQUser].normalAccount.accountId stringValue];
            [[QHttpMessageManager sharedHttpMessageManager] createAccPrePayBillIDByregionId:regionID
                                                                                    amount:_strAmout
                                                                               prepaidType:@"2"
                                                                                   payMode:@"1"
                                                                                 accountId:accountID];
        }
        else if (_buyType == BuyType_vipCard) //购买会员卡
        {
            [[QHttpMessageManager sharedHttpMessageManager] createPrePayBillIDByregionId:regionID
                                                                                  amount:_vipModel.amount.stringValue
                                                                            memberTypeId:_vipModel.memberTypeId.stringValue
                                                                                 payMode:@"1"]; //生成购买会员卡订单号
        }
        else if (_buyType == BuyType_vipCardCharge) //充值会员
        {
            [[QHttpMessageManager sharedHttpMessageManager] createPrePayBillIDByregionId:regionID
                                                                                  amount:_strAmout
                                                                            memberTypeId:_mbrTypeId
                                                                                 payMode:@"1"]; //生成购买会员卡订单号
        }

        [ASRequestHUD show];
    }
}

- (UIView *)viewWithFrame:(CGRect)frame{
    if ([super viewWithFrame:frame])
    {
        _view.backgroundColor = [QTools colorWithRGB:240 :239 :237];
        UIView *headerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, frame.size.width, 117)];
        headerView.backgroundColor = [QTools colorWithRGB:240 :239 :237];
        [_view addSubview:headerView];
        CGFloat moneyBeforeW = 15;
        CGFloat moneyTopH = 10;
        CGFloat moneyW = 200;
        CGFloat moneyH = 20;
        UILabel *moneyLabel = [[UILabel alloc] initWithFrame:CGRectMake(moneyBeforeW, moneyTopH, moneyW, moneyH)];
        moneyLabel.backgroundColor = [UIColor clearColor];
        if (_buyType == BuyType_normalCharge) //普通账户充值
        {
             moneyLabel.text = @"充值金额";
        }
        else if (_buyType == BuyType_vipCard) //购买会员卡
        {
             moneyLabel.text = _vipModel.memberTypeName;
        }
        else if (_buyType == BuyType_vipCardCharge) //充值会员卡
        {
             moneyLabel.text = _titleInfo;
        }
        
        moneyLabel.textColor = [QTools colorWithRGB:85 :85 :85];
        [headerView addSubview:moneyLabel];
        
        UIView *view2 = [[UIView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_SIZE_WIDTH, 80)];
        UIButton *sureBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        sureBtn.frame = CGRectMake(10, 10, view2.frame.size.width - 2 * 10, 40);
        [sureBtn setTitle:@"确认支付" forState:UIControlStateNormal];
        [sureBtn setBackgroundImage:[QTools createImageWithColor:UIColorFromRGB(0xc40000)] forState:UIControlStateNormal];
        [sureBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        sureBtn.titleLabel.font = [UIFont boldSystemFontOfSize:16];
        sureBtn.layer.masksToBounds = YES;
        sureBtn.layer.cornerRadius = 2.5;
        [sureBtn addTarget:self action:@selector(sureToRecharge) forControlEvents:UIControlEventTouchUpInside];
        [view2 addSubview:sureBtn];
        
        CGFloat cardBeforeW = 0;
        CGFloat cardTopH = moneyLabel.deFrameBottom + 10;
        CGFloat cardW = frame.size.width;
        CGFloat cardH = 35;
        UILabel *cardLabel = [[UILabel alloc] initWithFrame:CGRectMake(cardBeforeW, cardTopH, cardW, cardH)];
        
        if (_buyType == BuyType_normalCharge) //普通账户充值
        {
            cardLabel.text = [NSString stringWithFormat:@"%@元",_strAmout];
        }
        else if (_buyType == BuyType_vipCard) //购买会员卡
        {
            cardLabel.text = [NSString stringWithFormat:@"%@元",[_vipModel.amount stringValue]];
        }
        else if (_buyType == BuyType_vipCardCharge) //充值会员卡
        {
            cardLabel.text = [NSString stringWithFormat:@"%@元",_strAmout];
        }
    
        cardLabel.textColor = [QTools colorWithRGB:86 :86 :86];
        cardLabel.backgroundColor = [QTools colorWithRGB:255 :255 :255];
        cardLabel.textAlignment = NSTextAlignmentCenter;
        cardLabel.layer.masksToBounds = YES;
        cardLabel.layer.cornerRadius = 2.0;
        [headerView addSubview:cardLabel];
        
        CGFloat styleBeforeW = moneyBeforeW;
        CGFloat styleTopH = cardLabel.deFrameBottom + 10;
        CGFloat styleW = 250;
        CGFloat styleH = 20;
        UILabel *styleLabel = [[UILabel alloc] initWithFrame:CGRectMake(styleBeforeW, styleTopH, styleW, styleH)];
        styleLabel.backgroundColor = [UIColor clearColor];
        styleLabel.adjustsFontSizeToFitWidth = YES;
        styleLabel.text = @"选择支付方式";
        styleLabel.textColor = [QTools colorWithRGB:86 :86 :86];
        [headerView addSubview:styleLabel];
        
        _VIPTableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, frame.size.width, frame.size.height)
                                                     style:UITableViewStylePlain];
        _VIPTableView.backgroundColor = [QTools colorWithRGB:240 :239 :237];
        _VIPTableView.dataSource = self;
        _VIPTableView.delegate = self;
        _VIPTableView.tableHeaderView = headerView;
        _VIPTableView.tableFooterView = view2;
        _VIPTableView.backgroundColor = [QTools colorWithRGB:249 :249 :249];
        [_view addSubview:_VIPTableView];
        
    }
    return _view;
}

#pragma mark - Private

- (void)sureToRecharge
{
    [self chargeVipCard];
}

- (void)chargeVipCard
{
    //生成订单号
    //accountId+"_"+prepaidBillId+"_"+amount 例如 1_33_22222
    
    NSString *strOrderNO = @"";
    NSString *strProductName = @"";
    NSString *strProductDescription = @"";
    
    double payMoney = 0;
    
    if (_buyType == BuyType_normalCharge) //普通账户充值
    {
        strProductName = @"普通账户余额充值";
        strProductDescription = @"普通账户余额充值";
        strOrderNO = self.strAccBillID;//[self.strAccBillID stringByAppendingString:_strAmout];
        
        payMoney = [_strAmout doubleValue];
    }
    else if (_buyType == BuyType_vipCard) //购买会员卡
    {
        strProductName = @"购买洗车卡";
        strProductDescription = @"购买洗车卡";
        strOrderNO = self.strBillID;//[self.strBillID stringByAppendingString:_vipModel.amount.stringValue];
        
        payMoney = [_vipModel.amount doubleValue];
    }
    else if (_buyType == BuyType_vipCardCharge) //充值会员卡
    {
        strProductName = @"会员卡充值";
        strProductDescription = @"会员卡充值";
        strOrderNO = self.strBillID;//[self.strBillID stringByAppendingString:_vipModel.amount.stringValue];
        
        payMoney = [_strAmout doubleValue];
    }
    
    if (strOrderNO.length > 0)
    {
        QAppDelegate *appDelegate = [QAppDelegate appDelegate];
        if (_chongPayType == payType_wxPay) //微信
        {
            [appDelegate sendWXPay:strOrderNO name:strProductName price:payMoney];
        }
        else if (_chongPayType == payType_aliPay) //支付宝
        {
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
            order.tradeNO = strOrderNO;//订单号
            order.productName = strProductName;
            order.productDescription = strProductDescription;
            order.amount = [NSString stringWithFormat:@"%.2f",payMoney]; //商品价格
            NSLog(@"付款金额：%.2f",payMoney);
            order.notifyURL = @"http://121.41.116.252/appapi/prepaidBill/addBalance"; //回调URL
            order.service = @"mobile.securitypay.pay";
            order.paymentType = @"1";
            order.inputCharset = @"utf-8";
            order.itBPay = @"30m";
            order.showUrl = @"m.alipay.com";
            
            //应用注册scheme,在AlixPayDemo-Info.plist定义URL types
            NSString *appScheme = @"HRClient";
            
            //将商品信息拼接成字符串
            NSString *orderSpec = [order description];
            NSLog(@"orderSpec = %@",orderSpec);
            
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
                    if ([resultStatus isEqualToString:@"9000"]) {
                        if (_buyType == BuyType_normalCharge) //普通账户充值
                        {
                            UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"提示"
                                                                                message:@"恭喜您已充值成功！"
                                                                               delegate:self
                                                                      cancelButtonTitle:nil
                                                                      otherButtonTitles:@"查看我的账户余额", nil];
                            alertView.tag = 1;
                            [alertView show];
                        }
                    }
                }];
            }
            
            [self successDeal];
        }
    }
}

- (void)successDeal
{
    if (_buyType == BuyType_normalCharge) //普通账户充值
    {
    }
    else if (_buyType == BuyType_vipCard) //购买会员卡
    {
        [QViewController backPageWithParam:nil];
    }
    else if (_buyType == BuyType_vipCardCharge) //充值会员卡
    {
        [QViewController backPageWithParam:nil];
    }
    
    [[QUser sharedQUser] updateUserInfo];
}

#pragma mark - Notification

- (void)createVipOrderPrepaidBillId:(NSNotification*)notify
{
    debug_NSLog(@"prepaidBillId = %@",notify.object);
    
    [ASRequestHUD dismiss];
    self.strBillID = notify.object;
}

- (void)createAccOrderPrepaidBillId:(NSNotification*)notify
{
    debug_NSLog(@"acc_prepaidBillId = %@",notify.object);
    
    [ASRequestHUD dismiss];
    self.strAccBillID = notify.object;
}

- (void)getWXPayResult:(NSNotification*)notify
{
    if (WXSuccess == [notify.object intValue])
    {
        if (_buyType == BuyType_normalCharge) //普通账户充值
        {
            UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"提示"
                                                                message:@"恭喜您已充值成功！"
                                                               delegate:self
                                                      cancelButtonTitle:nil
                                                      otherButtonTitles:@"查看我的账户余额", nil];
            alertView.tag = 1;
            [alertView show];
        }
        [self successDeal];
    }
}

#pragma mark - UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return 2; /*2 支付宝、微信支付*/
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 50;
}
- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    return 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    static NSString *cellID = @"cellID";
    QVIPRechargeCell *VIPRechargeCell = [tableView dequeueReusableCellWithIdentifier:cellID];
    if (VIPRechargeCell==nil) {
        VIPRechargeCell = [[QVIPRechargeCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:cellID];
    }
    if (indexPath.row == 0)
    {
        if (_chongPayType == payType_aliPay)
            VIPRechargeCell.selectImageView.image = [UIImage imageNamed:@"yuan01.gif"];
        else
            VIPRechargeCell.selectImageView.image = [UIImage imageNamed:@"yuan02.gif"];;
    }
    else if (indexPath.row == 1)
    {
        if (_chongPayType == payType_wxPay)
            VIPRechargeCell.selectImageView.image = [UIImage imageNamed:@"yuan01.gif"];
        else
            VIPRechargeCell.selectImageView.image = [UIImage imageNamed:@"yuan02.gif"];;
    }

    NSArray *arr = @[/*@{@"icon":@"pic01.png",@"title":@"银行卡支付",@"detail":@"支持储蓄卡信用卡，无需开通网银",@"select":@"yuan01.gif"},*/
                     @{@"icon":@"pic02.png",@"title":@"支付宝支付",@"detail":@"推荐安装支付宝客户端的用户",@"select":@"yuan02.gif"},
                     @{@"icon":@"pic03.png",@"title":@"微信支付",@"detail":@"推荐安装微信5.0及以上版本的用户",@"select":@"yuan02.gif"}];
    [VIPRechargeCell cofigureModelToCell:arr andIndexPath:indexPath];
    
    return VIPRechargeCell;
}

#pragma mark - UITableViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    _chongPayType = (0 == indexPath.row) ? payType_aliPay : payType_wxPay;
    [tableView deselectRowAtIndexPath:indexPath animated:NO];
    
    [tableView reloadData];
}

#pragma mark - UIAlertViewDelegate

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (buttonIndex == 0)
    {
        [QViewController backPageWithParam:nil];
        [[QUser sharedQUser] updateUserInfo];
    }
}

@end
