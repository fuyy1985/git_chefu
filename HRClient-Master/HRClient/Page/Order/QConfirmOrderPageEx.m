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
    _orderDetail = [params objectForKey:@"QMyListDetailModel"];
    _productDetail = [params objectForKey:@"productDetail"];
}

- (NSString *)title{
    return @"确认支付";
}

- (void)pageEvent:(QPageEventType)eventType
{
}

- (UIView *)viewWithFrame:(CGRect)frame{
    if ([super viewWithFrame:frame]) {
    
        _confirmOrderTableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, frame.size.width, frame.size.height) style:UITableViewStyleGrouped];
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
    return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (section == 0)
    {
        return 4;
    }
    else
    {
        return 3;
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 12;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == 0)
    {
        return 46;
    }
    else
    {
        if (indexPath.row == 2 || indexPath.row == 1) {
            return 46;
        }
        
        return 76;
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == 1 && indexPath.row == 2)
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
            
            CGSize size = [_orderDetail.subject sizeWithFont:[UIFont systemFontOfSize:15.f]
                                           constrainedToSize:CGSizeMake(CGFLOAT_MAX, CGFLOAT_MAX) lineBreakMode:NSLineBreakByWordWrapping];
            if (size.width > 260)
            {
                cell.textLabel.text = [[_orderDetail.subject substringToIndex:14] stringByAppendingString:@"..."];
            }
            else
            {
                cell.textLabel.text = _orderDetail.subject;
            }
            NSString *strPrice = [NSString stringWithFormat:@"%.2f",[[_productDetail.usrMbrPrice objectForKey:@"memberUnitPrice"] doubleValue]];
            cell.detailTextLabel.text = [strPrice stringByAppendingString:@"元"];
        }
        else if (indexPath.row == 1) {
            cell.textLabel.text = @"数量：";
            cell.detailTextLabel.text = [NSString stringWithFormat:@"%d",[_orderDetail.quantity intValue]];
        }
        else if (indexPath.row == 2) {
            cell.textLabel.text = @"总价：";
            CGFloat totalMoney = [_orderDetail.quantity integerValue] * [[_productDetail.usrMbrPrice objectForKey:@"memberUnitPrice"] doubleValue];
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
    else
    {
        switch (indexPath.row) {
            case 0:
            {
                //tip
                UILabel *lbText = [[UILabel alloc]initWithFrame:CGRectMake(20, 10, 280, 16)];
                lbText.text = @"温馨提示，您的余额不足，请充值";
                lbText.font = [UIFont systemFontOfSize:15.f];
                lbText.textColor = [UIColor darkGrayColor];
                [cell.contentView addSubview:lbText];
                
                //btn
                UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
                btn.layer.masksToBounds = YES;
                btn.layer.cornerRadius = 5.f;
                btn.frame = CGRectMake(20, 36, cell.frame.size.width - 40, 30);
                btn.backgroundColor = UIColorFromRGB(0xc40000);
                [btn setTitle:@"充值" forState:UIControlStateNormal];
                [btn addTarget:self action:@selector(charger:) forControlEvents:UIControlEventTouchUpInside];
                [btn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
                [btn setTitleColor:[UIColor whiteColor] forState:UIControlStateHighlighted];
                [cell.contentView addSubview:btn];
            }
                break;
                
            case 1:
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
                btn.backgroundColor = UIColorFromRGB(0xc40000);
                [btn setTitle:@"立即购买" forState:UIControlStateNormal];
                [btn addTarget:self action:@selector(buyNow:) forControlEvents:UIControlEventTouchUpInside];
                [btn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
                [btn setTitleColor:[UIColor whiteColor] forState:UIControlStateHighlighted];
                [cell.contentView addSubview:btn];
                
                //price
                NSString *_price = [[_productDetail.productBid objectForKey:@"bidPrice"] stringValue];
                NSString *_retailPrice = [NSString stringWithFormat:@" %@元", [_productDetail.price stringValue]];
                NSString *text = [NSString stringWithFormat:@"活动价：%@元   %@", _price, _retailPrice];
                NSMutableAttributedString *string = [[NSMutableAttributedString alloc] initWithString:text attributes:@{NSStrikethroughStyleAttributeName: @(NSUnderlineStyleNone)}];
                [string addAttributes:@{NSStrikethroughStyleAttributeName:@(NSUnderlineStyleSingle)} range:[text rangeOfString:_retailPrice]];
                [string addAttribute:NSFontAttributeName value:[UIFont systemFontOfSize:16] range:[text rangeOfString:_price]];
                [string addAttribute:NSForegroundColorAttributeName value:ColorTheme range:[text rangeOfString:_price]];
                UILabel *priceLabel = [[UILabel alloc]initWithFrame:CGRectMake(20, 20, 160, 16)];
                priceLabel.textColor = [QTools colorWithRGB:149 :149 :149];
                priceLabel.font = [UIFont systemFontOfSize:11];
                priceLabel.attributedText = string;
                [cell.contentView addSubview:priceLabel];
            }
                break;
                
            case 2:
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

- (void)charger:(id)sender
{
    //充值
    [QViewController gotoPage:@"QMyVIPCard" withParam:nil];
}

- (void)buyNow:(id)sender
{
    [QViewController gotoPage:@"QConfirmOrderPage" withParam:[[NSDictionary alloc]
                                                 initWithObjectsAndKeys:_orderDetail, @"QMyListDetailModel",nil]];
}

@end
