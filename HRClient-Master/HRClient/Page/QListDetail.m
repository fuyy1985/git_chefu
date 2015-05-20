//
//  QListDetail.m
//  HRClient
//
//  Created by ekoo on 14/12/11.
//  Copyright (c) 2014年 panyj. All rights reserved.
//

#import "QListDetail.h"
#import "QViewController.h"
#import "QHttpMessageManager.h"
#import "QMyListDetailModel.h"
#import "UIImageView+WebCache.h"


typedef enum{
    kCellNone,
    kCellProduct = 1,//商品详情
    kCellPay,//付款按钮
    kCellConpun,//消费券信息
    kCellProductDetail,//图文详情
    kCellOrderDetail,//订单信息
    kCellRefund,//退款按钮
}OrderCellType;

@interface QListDetail ()<UITableViewDataSource,UITableViewDelegate>
{
    BOOL _isDataChanged;
    NSString *orderStr;
    NSInteger _status;
    QMyListDetailModel *detailModel;

    UIImageView *productImageView;
    UILabel *priceLabel;
    CGFloat contentBeforeW;
    UILabel *lineLabel;
    CGFloat contentBlank;
    UILabel *titleLabel;
    
    UIImageView *intimeImageView;
    UILabel *intimeLabel;
    UIImageView *overtimeImageView;
    UILabel *overtimeLabel;
}
@property (nonatomic, strong) UITableView *tableView;

@end

@implementation QListDetail

- (void)dealloc{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)setActiveWithParams:(NSDictionary *)params
{
    NSNumber *ID = [params objectForKey:@"orderListId"];
    NSNumber *status = [params objectForKey:@"status"];
    if (ID) {
        orderStr = [ID stringValue];
        _status = [status intValue];
        _isDataChanged = YES;
        detailModel = nil;
    }
}

- (QCacheType)pageCacheType
{
    return kCacheTypeNone;
}

- (void)pageEvent:(QPageEventType)eventType
{
    if (eventType == kPageEventViewCreate)
    {
        _isDataChanged = YES;
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(successGetListDetail:) name:kGetMyListDetail object:nil];
    }
    else if (eventType == kPageEventWillShow)
    {
        if (_isDataChanged)
        {
            [self tryListDetail:_status];
        }
    }
}

- (NSString *)title
{
    return @"订单详情";
}

- (NSArray*)pageRightMenus
{
    _view.backgroundColor = [QTools colorWithRGB:240 :239 :237];
    
    UIButton *editBtn2 = [UIButton buttonWithType:UIButtonTypeCustom];
    [editBtn2 setImage:[UIImage imageNamed:@"share_detail.png"] forState:UIControlStateNormal];
    [editBtn2 addTarget:self action:@selector(setShare) forControlEvents:UIControlEventTouchUpInside];
    [editBtn2 sizeToFit];
    UIBarButtonItem *editItem2 = [[UIBarButtonItem alloc] initWithCustomView:editBtn2];
    
    return [NSArray arrayWithObjects:editItem2, nil];
}


- (UIView *)viewWithFrame:(CGRect)frame
{
    if ([super viewWithFrame:frame]) {
        
        _view.backgroundColor = [QTools colorWithRGB:240 :239 :237];
        _view.clipsToBounds = YES;
    }
    return _view;
}

- (UITableView*)tableView
{
    if (!_tableView) {
        _tableView = [[UITableView alloc] initWithFrame:CGRectMake(10, 0, _view.deFrameWidth - 2*10, _view.deFrameHeight - 10) style:UITableViewStylePlain];
        _tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
        _tableView.allowsSelection = NO;
        _tableView.backgroundColor = [UIColor clearColor];
        _tableView.delegate = self;
        _tableView.dataSource = self;
        _tableView.clipsToBounds = NO;
        [_view addSubview:_tableView];
    }
    return _tableView;
}

#pragma mark - Private

- (OrderCellType)cellTypeByStatus:(NSInteger)status andIndex:(NSUInteger)index
{
    OrderCellType type = kCellNone;
    switch (index)
    {
        case 0:
            type = kCellProduct;
            break;
        case 1:
        {
            if (_status == kOrderStatusUnPayed)
                type = kCellPay;
            else if (_status == kOrderStatusUnUsed)
                type = kCellConpun;
            else if (_status == kOrderStatusNeedRemark)
                type = kCellProductDetail;
            else if (_status == kOrderStatusRefund)
                type = kCellProductDetail;
        }
            break;
        case 2:
        {
            if (_status == kOrderStatusUnPayed)
                type = kCellProductDetail;
            else if (_status == kOrderStatusUnUsed)
                type = kCellProductDetail;
            else if (_status == kOrderStatusNeedRemark)
                type = kCellOrderDetail;
            else if (_status == kOrderStatusRefund)
                type = kCellOrderDetail;
        }
            break;
        case 3:
        {
            if (_status == kOrderStatusUnPayed)
                type = kCellOrderDetail;
            else if (_status == kOrderStatusUnUsed)
                type = kCellOrderDetail;
            else if (_status == kOrderStatusRefund)
                type = kCellRefund;
        }
            break;
        case 4:
        {
            if (_status == kOrderStatusUnUsed)
                type = kCellRefund;
            
        }
            break;
        default:
            break;
    }
    return type;
}

- (CGFloat)heightofCell:(OrderCellType)type
{
    CGFloat height = 0;
    switch (type) {
        case kCellProduct:
            height = 105;
            break;
        case kCellPay:
            height = 30;
            break;
        case kCellConpun:
            height = 80;
            break;
        case kCellProductDetail:
            height = 30;
            break;
        case kCellOrderDetail:
            height = 160;
            break;
        case kCellRefund:
            height = 30;
            break;
        default:
            break;
    }
    return height;
}

#pragma mark - Action

- (void)setShare
{
}

- (void)gotoPay
{
    [QViewController gotoPage:@"QConfirmOrderPage" withParam:[[NSDictionary alloc]
                            initWithObjectsAndKeys:detailModel, @"QMyListDetailModel",nil]];
}

- (void)checkDetail
{
    [QViewController gotoPage:@"QGroupBuyDetailPage" withParam:
                            [NSDictionary dictionaryWithObjectsAndKeys:detailModel.productId, @"ProductID", nil]];
}

- (void)gotoRecharge
{
    [QViewController gotoPage:@"QApplicationDrawback" withParam:[[NSDictionary alloc]
                                                              initWithObjectsAndKeys:detailModel, @"QMyListDetailModel",nil]];
}

#pragma mark - Notification

- (void)tryListDetail:(NSInteger)status
{
    switch (status)
    {
        case kOrderStatusUnPayed:
            //未支付
        {
            [[QHttpMessageManager sharedHttpMessageManager] accessMyListDetail:orderStr andStatus:@"1"];
            [ASRequestHUD show];
        }
            break;
        case kOrderStatusUnUsed:
            //未消费
        {
            [[QHttpMessageManager sharedHttpMessageManager] accessMyListDetail:orderStr andStatus:@"2"];
            [ASRequestHUD show];
        }
            break;
        case kOrderStatusNeedRemark:
            //待评价
        {
            [[QHttpMessageManager sharedHttpMessageManager] accessMyListDetail:orderStr andStatus:@"3"];
            [ASRequestHUD show];
        }
            break;
        case kOrderStatusRefund:
            //已退款
        {
            [[QHttpMessageManager sharedHttpMessageManager] accessMyListDetail:orderStr andStatus:@"4"];
            [ASRequestHUD show];
        }
            break;
        default:
            break;
    }
}

- (void)successGetListDetail:(NSNotification *)noti
{
    detailModel = noti.object;
    [self.tableView reloadData];
    
    [ASRequestHUD dismiss];
}

#pragma mark - UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    if (!detailModel)
        return 0;
    
    NSInteger nCount = 1;
    switch (_status)
    {
        case kOrderStatusUnPayed:
            //未支付
            nCount = 4;
            break;
        case kOrderStatusUnUsed:
            //未消费
            nCount = 5;
            break;
        case kOrderStatusNeedRemark:
            //待评价
        case kOrderStatusRefund:
            //已退款
            nCount = 4;
            break;
        default:
            break;
    }

    return nCount;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *cellIdentifier = @"cellIdentifier";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    if (!cell)
    {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
    }
    
    //初始化
    [cell.contentView.subviews makeObjectsPerformSelector:@selector(removeFromSuperview)];
    cell.accessoryType = UITableViewCellAccessoryNone;
    
    OrderCellType type = [self cellTypeByStatus:_status andIndex:indexPath.section];
    switch (type) {
        case kCellProduct:
        {
            //第一块
            CGFloat beforeW = 0;
            CGFloat topH = 0;
            CGFloat w = tableView.deFrameWidth;
            CGFloat h = [self heightofCell:kCellProduct];
            UIView *iconView = [[UIView alloc] initWithFrame:CGRectMake(beforeW, topH, w, h)];
            iconView.backgroundColor = [UIColor whiteColor];
            [cell.contentView addSubview:iconView];
            
            contentBeforeW = 10;
            CGFloat iconW = 80;
            CGFloat iconH = 55;
            contentBlank = 5;
            UIImageView *iconImageView = [[UIImageView alloc] initWithFrame:CGRectMake(contentBeforeW, 10, iconW, iconH)];
            iconImageView.contentMode = UIViewContentModeScaleAspectFill;
            iconImageView.clipsToBounds = YES;
            [iconView addSubview:iconImageView];
            productImageView = iconImageView;
            
            CGFloat titleW = iconView.frame.size.width - iconImageView.frame.size.width - contentBeforeW - contentBlank;
            CGFloat titleH = 15;
            titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(iconImageView.frame.size.width + contentBeforeW + contentBlank, 10, titleW, titleH)];
            titleLabel.backgroundColor = [UIColor clearColor];
            titleLabel.font = [UIFont systemFontOfSize:15];
            titleLabel.textColor = ColorDarkGray;
            titleLabel.text = detailModel.subject;
            [iconView addSubview:titleLabel];
            
            //价格
            CGFloat priceTopH = titleLabel.deFrameBottom + titleH + contentBlank;
            priceLabel = [[UILabel alloc] initWithFrame:CGRectMake(iconImageView.deFrameRight + contentBlank, priceTopH, titleW, titleH)];
            priceLabel.backgroundColor = [UIColor clearColor];
            priceLabel.textColor = [QTools colorWithRGB:85 :85 :85];
            priceLabel.font = [UIFont systemFontOfSize:11];
            [iconView addSubview:priceLabel];
            
            UILabel *iconLineLabel = [[UILabel alloc] initWithFrame:CGRectMake(contentBeforeW,
                                                                               iconImageView.deFrameBottom + contentBlank,
                                                                               iconView.deFrameWidth - 2*contentBeforeW,
                                                                               0.5f)];
            iconLineLabel.backgroundColor = ColorLine;
            [iconView addSubview:iconLineLabel];
            
            //支持随时退款
            CGFloat intimeTopH = 4;
            intimeImageView = [[UIImageView alloc] initWithFrame:CGRectMake(5, iconLineLabel.frame.origin.y + intimeTopH + 3, 15, 15)];
            [iconView addSubview:intimeImageView];
            
            CGFloat intimeW = 80;
            
            intimeLabel = [[UILabel alloc] initWithFrame:CGRectMake(intimeImageView.frame.origin.x + intimeImageView.frame.size.width + 3,
                                                                    iconLineLabel.frame.origin.y + intimeTopH, intimeW, 20)];
            intimeLabel.font = [UIFont systemFontOfSize:12];
            intimeLabel.backgroundColor = [UIColor clearColor];
            [iconView addSubview:intimeLabel];
            
            //过期退款
            overtimeImageView = [[UIImageView alloc] initWithFrame:CGRectMake(105, iconLineLabel.frame.origin.y + intimeTopH + 3, 15, 15)];
            [iconView addSubview:overtimeImageView];
            
            overtimeLabel = [[UILabel alloc] initWithFrame:CGRectMake(overtimeImageView.frame.origin.x + overtimeImageView.frame.size.width + 3,
                                                                    iconLineLabel.frame.origin.y + intimeTopH, intimeW, 20)];
            overtimeLabel.font = [UIFont systemFontOfSize:12];
            overtimeLabel.backgroundColor = [UIColor clearColor];
            [iconView addSubview:overtimeLabel];
            
            //设置数据
            if ([detailModel.returnNotSpending intValue])
            {
                [intimeImageView setImage:IMAGEOF(@"icon_yellow_check")];
                intimeLabel.textColor = [UIColor colorWithRed:0xe9/255.0 green:0x71/255.0 blue:0x4e/255.0 alpha:1.0];
                intimeLabel.text = @"支持随时退";
            }
            else
            {
                [intimeImageView setImage:IMAGEOF(@"icon_yellow_uncheck")];
                intimeLabel.textColor = ColorDarkGray;
                intimeLabel.text = @"不支持随时退";
            }
            if ([detailModel.returnOverdue intValue])
            {
                [overtimeImageView setImage:IMAGEOF(@"icon_yellow_check")];
                overtimeLabel.textColor = [UIColor colorWithRed:0xe9/255.0 green:0x71/255.0 blue:0x4e/255.0 alpha:1.0];
                overtimeLabel.text = @"支持过期退";
            }
            else
            {
                [overtimeImageView setImage:IMAGEOF(@"icon_yellow_uncheck")];
                overtimeLabel.textColor = ColorDarkGray;
                overtimeLabel.text = @"不支持过期退";
            }
            
            //商品图片
            [productImageView sd_setImageWithURL:[NSURL URLWithString:PICTUREHTTP(NSString_No_Nil(detailModel.photo))]
                                placeholderImage:[UIImage imageNamed:@"default_image"]
                                         options:SDWebImageRefreshCached];
            //商品价格
            NSString *price = detailModel.total.stringValue;
            NSString *text = [NSString stringWithFormat:@"%@元",price];
            NSMutableAttributedString *string = [[NSMutableAttributedString alloc] initWithString:text attributes:@{NSStrikethroughStyleAttributeName:@(NSUnderlineStyleNone)}];
            [string addAttribute:NSFontAttributeName
                           value:[UIFont systemFontOfSize:18]
                           range:[text rangeOfString:price]];
            [string addAttribute:NSForegroundColorAttributeName
                           value:UIColorFromRGB(0xc40000)
                           range:[text rangeOfString:price]];
            priceLabel.attributedText = string;
            //商品名称
            titleLabel.text = detailModel.subject;
        }
            break;
        case kCellPay:
        {
            UIButton *button = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, tableView.deFrameWidth, [self heightofCell:kCellPay])];
            [button setTitle:@"付款" forState:UIControlStateNormal];
            button.titleLabel.font = [UIFont systemFontOfSize:14];
            [button setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
            button.backgroundColor = ColorTheme;
            [button addTarget:self action:@selector(gotoPay) forControlEvents:UIControlEventTouchUpInside];
            [cell.contentView addSubview:button];
        }
            break;
        case kCellConpun:
        {
            NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
            [dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
            NSString *orderTime = [dateFormatter stringFromDate: [NSDate dateWithTimeIntervalSince1970:([detailModel.expireDate unsignedLongLongValue]/1000)]];//毫秒->秒
            
            NSArray *titleArr = @[@"车夫券:", @"有效期:", @"消费密码:"];
            NSArray *detailArr = @[detailModel.payNo, orderTime, detailModel.verificationCode];
            
            CGFloat originY = 0;
            for (int i = 0; i < 3; i ++) {
                UILabel *title = [[UILabel alloc] initWithFrame:CGRectMake(contentBeforeW , originY, 70, 25)];
                title.text = titleArr[i];
                title.backgroundColor = [UIColor clearColor];
                title.textAlignment = NSTextAlignmentRight;
                title.font = [UIFont systemFontOfSize:13];
                title.textColor = [QTools colorWithRGB:85 :85 :85];
                [cell.contentView addSubview:title];
                
                UILabel *detail = [[UILabel alloc] initWithFrame:CGRectMake(contentBeforeW + title.deFrameRight, originY, SCREEN_SIZE_WIDTH - title.deFrameRight, 25)];
                detail.backgroundColor = [UIColor clearColor];
                detail.text = detailArr[i];
                detail.font = [UIFont systemFontOfSize:13];
                detail.textColor = [QTools colorWithRGB:85 :85 :85];
                [cell.contentView addSubview:detail];
                
                originY += 25;
            }
        }
            break;
        case kCellProductDetail:
        {
            UIButton *button = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, tableView.deFrameWidth, [self heightofCell:kCellProductDetail])];
            [button setTitle:@"  查看图文详情" forState:UIControlStateNormal];
            [button setTitleColor:UIColorFromRGB(0xc40000) forState:UIControlStateNormal];
            button.titleLabel.font = [UIFont systemFontOfSize:14];
            [button addTarget:self action:@selector(checkDetail) forControlEvents:UIControlEventTouchUpInside];
            [button setContentHorizontalAlignment:UIControlContentHorizontalAlignmentLeft];
            button.backgroundColor  =[UIColor whiteColor];
            [cell.contentView addSubview:button];
            
            cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        }
            break;
        case kCellOrderDetail:
        {
            UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(contentBeforeW, 0, tableView.deFrameWidth - 2*contentBeforeW, 30)];
            label.font = [UIFont systemFontOfSize:14];
            label.backgroundColor = [UIColor clearColor];
            label.text = @"订单信息";
            label.textColor = ColorDarkGray;
            [cell.contentView addSubview:label];
            
            label = [[UILabel alloc] initWithFrame:CGRectMake(contentBeforeW, label.deFrameBottom, tableView.deFrameWidth - 2*contentBeforeW, 0.5f)];
            label.backgroundColor = [UIColor clearColor];
            label.backgroundColor = ColorLine;
            [cell.contentView addSubview:label];
            
            //购买时间
            NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
            [dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
            NSString *orderTime = [dateFormatter stringFromDate: [NSDate dateWithTimeIntervalSince1970:([detailModel.gmtCreate unsignedLongLongValue]/1000)]];//毫秒->秒
            
            NSArray *titleArr = @[@"订单号:",@"购买手机:",@"下单时间:",@"数量:",@"总价:"];
            NSArray *detailArr = @[detailModel.orderListNo,detailModel.phone,orderTime,[detailModel.quantity stringValue],detailModel.total.stringValue];
            
            CGFloat originY = label.deFrameBottom;
            for (int i = 0; i < 5; i ++) {
                UILabel *title = [[UILabel alloc] initWithFrame:CGRectMake(contentBeforeW , originY, 60, 25)];
                title.text = titleArr[i];
                title.backgroundColor = [UIColor clearColor];
                title.textAlignment = NSTextAlignmentRight;
                title.font = [UIFont systemFontOfSize:13];
                title.textColor = [QTools colorWithRGB:85 :85 :85];
                [cell.contentView addSubview:title];
                
                UILabel *detail = [[UILabel alloc] initWithFrame:CGRectMake(contentBeforeW + title.deFrameRight, originY, SCREEN_SIZE_WIDTH - title.deFrameRight, 25)];
                detail.text = detailArr[i];
                detail.backgroundColor = [UIColor clearColor];
                detail.font = [UIFont systemFontOfSize:13];
                detail.textColor = [QTools colorWithRGB:85 :85 :85];
                [cell.contentView addSubview:detail];
                
                originY += title.deFrameHeight;
            }
        }
            break;
        case kCellRefund:
        {
            UIButton *drawbackBtn = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, tableView.deFrameWidth, [self heightofCell:kCellRefund])];
            [drawbackBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
            drawbackBtn.titleLabel.font = [UIFont systemFontOfSize:14];
            if (_status == kOrderStatusRefund)
            {
                drawbackBtn.backgroundColor = [UIColor grayColor];
                [drawbackBtn setTitle:@"退单" forState:UIControlStateNormal];
            }
            else
            {
                drawbackBtn.backgroundColor = ColorTheme;
                [drawbackBtn setTitle:@"申请退款" forState:UIControlStateNormal];
            [drawbackBtn addTarget:self action:@selector(gotoRecharge) forControlEvents:UIControlEventTouchUpInside];
            }
            [cell.contentView addSubview:drawbackBtn];
        }
            break;
        default:
            break;
    }
    
    return cell;
}

#pragma mark - UITableViewDelegate

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return [self heightofCell:[self cellTypeByStatus:_status andIndex:indexPath.section]];
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 10;
}

@end
