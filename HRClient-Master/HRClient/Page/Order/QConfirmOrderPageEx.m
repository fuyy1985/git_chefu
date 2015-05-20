//
//  QConfirmOrderPageEx.m
//  HRClient
//
//  Created by chenyf on 14/12/22.
//  Copyright (c) 2014年 panyj. All rights reserved.
//

#import "QConfirmOrderPageEx.h"
#import "QViewController.h"
#import "QVIPRechargeCell.h"
#import "QMyListDetailModel.h"

#import "QHttpMessageManager.h"
#import "QCardDetailModel.h"

@interface QConfirmOrderPageEx ()
{
    QMyListDetailModel *_orderDetail;
    BOOL bFromChased;
}

@property (nonatomic,strong) UITableView *confirmOrderTableView;
@property (nonatomic, strong) QProductDetail *productDetail;

@end

@implementation QConfirmOrderPageEx

#pragma mark - view

- (QCacheType)pageCacheType
{
    return kCacheTypeNone;
}

- (void)setActiveWithParams:(NSDictionary*)params
{
    if ([[params objectForKey:@"fromPurChased"] isEqualToString:@"YES"])
    {
        _productDetail = [params objectForKey:@"productDetail"];
        _orderDetail = nil;
        bFromChased = YES;
    }
    else
    {
    _orderDetail = [params objectForKey:@"QMyListDetailModel"];
    _productDetail = [params objectForKey:@"productDetail"];
}
}

- (NSString *)title{
    
    if (bFromChased)
    {
        return @"确认订单";
    }
    return @"确认支付";
}

- (void)pageEvent:(QPageEventType)eventType
{
    if (eventType == kPageEventWillShow)
    {
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(successAddList:) name:kAddList object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(successGetListDetail:) name:kGetMyListDetail object:nil];
    }
    else if (eventType == kPageEventWillHide)
    {
        [[NSNotificationCenter defaultCenter] removeObserver:self name:kAddList object:nil];
        [[NSNotificationCenter defaultCenter] removeObserver:self name:kGetMyListDetail object:nil];
    }
}

//立即购买的返回
- (void)successGetListDetail:(NSNotification *)noti
{
    _orderDetail = noti.object;
    [ASRequestHUD dismiss];
    
    [QViewController gotoPage:@"QConfirmOrderPage" withParam:[[NSDictionary alloc]
                                                              initWithObjectsAndKeys:_orderDetail, @"QMyListDetailModel",nil]];
}

- (void)successAddList:(NSNotification*)noti
{
    QMyListModel *model = noti.object;
    
    if (model.status.integerValue == 1) //未付款
    {
        [[QHttpMessageManager sharedHttpMessageManager] accessMyListDetail:model.orderListId.stringValue andStatus:@"1"];
    }
}

- (UIView *)viewWithFrame:(CGRect)frame{
    if ([super viewWithFrame:frame]) {
    
        _confirmOrderTableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, frame.size.width, 380) style:UITableViewStylePlain];
        _confirmOrderTableView.delegate = self;
        _confirmOrderTableView.dataSource = self;
        _confirmOrderTableView.backgroundColor = [QTools colorWithRGB:238 :238 :238];
        [_view addSubview:_confirmOrderTableView];
    }
    return _view;
}

#pragma mark - UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 3;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (section == 0)
    {
        return 4;
    }
    else if (section == 1)
    {
        return 1;
    }
    else
    {
        return 2;
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 10;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == 0)
    {
        return 46;
    }
    else if (indexPath.section == 1)
    {
        return 76;
    }
    else
    {
            return 46;
        }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == 2 && indexPath.row == 1)
    {
        /* 商品详情页面 */
        [QViewController gotoPage:@"QGroupBuyDetailPage" withParam:[NSDictionary dictionaryWithObjectsAndKeys:_productDetail.productId, @"ProductID", nil]];
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell_Identifier_SubmitOrder";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (nil == cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:CellIdentifier];
        cell.selectionStyle = UITableViewCellAccessoryDisclosureIndicator;
    }
    
    cell.textLabel.textColor = [QTools colorWithRGB:85 :85 :85];
    cell.textLabel.adjustsFontSizeToFitWidth = YES;
    cell.textLabel.font = [UIFont systemFontOfSize:15];
    cell.detailTextLabel.textColor = UIColorFromRGB(0xc40000);
    cell.detailTextLabel.font = [UIFont systemFontOfSize:15];
    cell.textLabel.text = @"";
    cell.detailTextLabel.text = @"";
    
    [cell.contentView.subviews makeObjectsPerformSelector:@selector(removeFromSuperview)];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    cell.accessoryType = UITableViewCellAccessoryNone;
    
    //产品信息
    if (indexPath.section == 0)
    {
        if (indexPath.row == 0) {
            
            CGSize size = [_productDetail.subject sizeWithFont:[UIFont systemFontOfSize:15.f]
                                           constrainedToSize:CGSizeMake(CGFLOAT_MAX, CGFLOAT_MAX) lineBreakMode:NSLineBreakByWordWrapping];
            if (size.width > 260)
            {
                cell.textLabel.text = [[_productDetail.subject substringToIndex:14] stringByAppendingString:@"..."];
            }
            else
            {
                cell.textLabel.text = _productDetail.subject;
            }
            NSString *strPrice = [NSString stringWithFormat:@"%.2f",[[_productDetail.usrMbrPrice objectForKey:@"memberUnitPrice"] doubleValue]];
            cell.detailTextLabel.text = [strPrice stringByAppendingString:@"元"];
        }
        else if (indexPath.row == 1) {
            cell.textLabel.text = @"数量：";
            if (bFromChased)
            {
                cell.detailTextLabel.text = @"1";
            }
            else
            {
            cell.detailTextLabel.text = [NSString stringWithFormat:@"%d",[_orderDetail.quantity intValue]];
        }
        }
        else if (indexPath.row == 2) {
            cell.textLabel.text = @"总价：";
            CGFloat totalMoney = 0;
            if (bFromChased)
            {
                totalMoney = 1.0 * [[_productDetail.usrMbrPrice objectForKey:@"memberUnitPrice"] doubleValue];
            }
            else
            {
                totalMoney = [_orderDetail.quantity integerValue] * [[_productDetail.usrMbrPrice objectForKey:@"memberUnitPrice"] doubleValue];
            }
            
            cell.detailTextLabel.text = [[NSString stringWithFormat:@"%.2f",totalMoney] stringByAppendingString:@"元"];
        }
        else if (indexPath.row == 3)
        {
            cell.textLabel.text = @"洗车卡余额：";
            QMyAccountMoel *model = [QUser sharedQUser].vipAccount;
            if (model.balance)
            {
                cell.detailTextLabel.text = [NSString stringWithFormat:@"%@元",model.balance.stringValue];
            }
            else
            {
                cell.detailTextLabel.text = @"0元";
            }
        }
        
    }
    else if (indexPath.section == 1)
            {
                //tip
                UILabel *lbText = [[UILabel alloc]initWithFrame:CGRectMake(20, 10, 280, 16)];
        lbText.adjustsFontSizeToFitWidth = YES;
        lbText.backgroundColor = [UIColor clearColor];
        
        if (bFromChased)
        {
            lbText.text = @"今天您已经使用洗车卡购买过服务或者商品";
        }
        else
        {
                lbText.text = @"温馨提示，您的余额不足，请充值";
        }
                lbText.font = [UIFont systemFontOfSize:15.f];
                lbText.textColor = [UIColor darkGrayColor];
                [cell.contentView addSubview:lbText];
                
                //btn
                UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
                btn.layer.masksToBounds = YES;
                btn.layer.cornerRadius = 5.f;
                btn.frame = CGRectMake(20, 36, cell.frame.size.width - 40, 30);
                [btn setBackgroundImage:[QTools createImageWithColor:ColorTheme] forState:UIControlStateNormal];
                btn.titleLabel.font = [UIFont systemFontOfSize:14];
        if (bFromChased)
        {
            [btn setTitle:@"查看我的洗车劵" forState:UIControlStateNormal];
        }
        else
        {
                [btn setTitle:@"充值" forState:UIControlStateNormal];
        }
        [btn addTarget:self action:@selector(btnAction:) forControlEvents:UIControlEventTouchUpInside];
                [btn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
                [btn setTitleColor:[UIColor whiteColor] forState:UIControlStateHighlighted];
                [cell.contentView addSubview:btn];
            }
    else
    {
        switch (indexPath.row) {
                
            case 0:
            {
                /*tip
                UILabel *lbText = [[UILabel alloc]initWithFrame:CGRectMake(20, 10, 280, 16)];
                lbText.text = @"选择其他方式购买，将不享受会员价格";
                lbText.font = [UIFont systemFontOfSize:15.f];
                lbText.textColor = [UIColor darkGrayColor];
                [cell.contentView addSubview:lbText];*/
                
                //btn
                UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
                btn.layer.masksToBounds = YES;
                btn.layer.cornerRadius = 5.f;
                btn.frame = CGRectMake(cell.frame.size.width - 120, 8, 100, 30);
                [btn setBackgroundImage:[QTools createImageWithColor:ColorTheme] forState:UIControlStateNormal];
                btn.titleLabel.font = [UIFont systemFontOfSize:14];
                [btn setTitle:@"立即购买" forState:UIControlStateNormal];
                [btn addTarget:self action:@selector(buyNow:) forControlEvents:UIControlEventTouchUpInside];
                [btn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
                [btn setTitleColor:[UIColor whiteColor] forState:UIControlStateHighlighted];
                [cell.contentView addSubview:btn];
                
                //price
                NSString *_price = [[_productDetail.productBid objectForKey:@"bidPrice"] stringValue];
                if (_price == nil) _price = @"";
                NSString *_retailPrice = [NSString stringWithFormat:@" %@元", [_productDetail.price stringValue]];
                if (_retailPrice == nil) _retailPrice = @"";
                NSString *text = [NSString stringWithFormat:@"活动价：%@元   %@", _price, _retailPrice];
                NSMutableAttributedString *string = [[NSMutableAttributedString alloc] initWithString:text attributes:@{NSStrikethroughStyleAttributeName: @(NSUnderlineStyleNone)}];
                [string addAttributes:@{NSStrikethroughStyleAttributeName:@(NSUnderlineStyleSingle)} range:[text rangeOfString:_retailPrice]];
                [string addAttribute:NSFontAttributeName value:[UIFont systemFontOfSize:16] range:[text rangeOfString:_price]];
                [string addAttribute:NSForegroundColorAttributeName value:ColorTheme range:[text rangeOfString:_price]];
                UILabel *priceLabel = [[UILabel alloc]initWithFrame:CGRectMake(20, 20, 160, 16)];
                priceLabel.textColor = [QTools colorWithRGB:149 :149 :149];
                priceLabel.font = [UIFont systemFontOfSize:11];
                priceLabel.backgroundColor = [UIColor clearColor];
                priceLabel.attributedText = string;
                [cell.contentView addSubview:priceLabel];
            }
                break;
                
            case 1:
                cell.textLabel.text = @"商品详情 >>";
                cell.selectionStyle = UITableViewCellSelectionStyleGray;
                cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
                break;
                
            default:
                break;
        }
    }

    return cell;
}

#pragma mark - Private

- (void)btnAction:(id)sender
{
    if (bFromChased)
    {
        [QViewController gotoPage:@"QMyNoWarry" withParam:nil];
        return;
    }
    
    //充值
    [QViewController gotoPage:@"QMyVIPCard" withParam:nil];
}

- (void)buyNow:(id)sender
{
    if (bFromChased) {
        NSString *strBidType = @"";
        if (self.productDetail.productBid)
        {
            strBidType = [self.productDetail.productBid objectForKey:@"bidType"];
        }
        [[QHttpMessageManager sharedHttpMessageManager] accessAddList:[self.productDetail.productId stringValue] andQuantity:@"1" andBidType:strBidType];
        [ASRequestHUD show];
    }
    else
    {
    [QViewController gotoPage:@"QConfirmOrderPage" withParam:[[NSDictionary alloc]
                                                 initWithObjectsAndKeys:_orderDetail, @"QMyListDetailModel",nil]];
}
}

@end
