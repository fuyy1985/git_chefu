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

@interface QListDetail ()
{
    NSString *orderStr;
    NSInteger _status;
    QMyListDetailModel *detailModel;
    UILabel *intimeLabel;
    UIImageView *productImageView;
    UILabel *priceLabel;
    CGFloat contentBeforeW;
    UILabel *lineLabel;
    CGFloat contentBlank;
    UILabel *titleLabel;
    UIButton *checkBtn;
    
    UIImageView *intimeImageView;
    UIImageView *overtimeImageView;
    UIImageView *notSatImageView;
}
@property (nonatomic, strong) UIScrollView *scrollView;
@property (nonatomic, strong) UIView *couponView;
@property (nonatomic, strong) UIView *infoView;

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
        switch (_status)
        {
            case kOrderStatusUnPayed:
                //未支付
            {
                [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(successGetListDetail:) name:kGetMyListDetail object:nil];
                [[QHttpMessageManager sharedHttpMessageManager] accessMyListDetail:orderStr andStatus:@"1"];
                [ASRequestHUD show];
            }
                break;
            case kOrderStatusUnUsed:
                //未消费
            {
                [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(successGetListDetail:) name:kGetMyListDetail object:nil];
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
                [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(successGetListDetail:) name:kGetMyListDetail object:nil];
                [[QHttpMessageManager sharedHttpMessageManager] accessMyListDetail:orderStr andStatus:@"4"];
                [ASRequestHUD show];
            }
                break;
            default:
                break;
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


- (UIView *)viewWithFrame:(CGRect)frame{
    if ([super viewWithFrame:frame]) {
        
        _view.backgroundColor = [QTools colorWithRGB:240 :239 :237];
        
        UIScrollView *scrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 0, frame.size.width, frame.size.height)];
        scrollView.contentSize = CGSizeMake(frame.size.width, 680);
        scrollView.backgroundColor = [QTools colorWithRGB:236 :235 :232];
        [_view addSubview:scrollView];
        _scrollView = scrollView;
        
//        第一块
        CGFloat beforeW = 10;
        CGFloat topH = 10;
        CGFloat w = frame.size.width - 2*beforeW;
        CGFloat h = 105;
        UIView *iconView = [[UIView alloc] initWithFrame:CGRectMake(beforeW, topH, w, h)];
        iconView.backgroundColor = [UIColor whiteColor];
        [scrollView addSubview:iconView];
        
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
        titleLabel.font = [UIFont systemFontOfSize:15];
        titleLabel.textColor = ColorDarkGray;
        titleLabel.text = detailModel.subject;
        [iconView addSubview:titleLabel];

        //价格
        CGFloat priceTopH = titleLabel.deFrameBottom + titleH + contentBlank;
        priceLabel = [[UILabel alloc] initWithFrame:CGRectMake(iconImageView.deFrameRight + contentBlank, priceTopH, titleW, titleH)];
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
        intimeLabel.textColor = ColorDarkGray;
        intimeLabel.text = @"支持随时退";
        [iconView addSubview:intimeLabel];
        
        //过期退款
        overtimeImageView = [[UIImageView alloc] initWithFrame:CGRectMake(105, iconLineLabel.frame.origin.y + intimeTopH + 3, 15, 15)];
        [iconView addSubview:overtimeImageView];
        
        intimeLabel = [[UILabel alloc] initWithFrame:CGRectMake(overtimeImageView.frame.origin.x + overtimeImageView.frame.size.width + 3,
                                                                iconLineLabel.frame.origin.y + intimeTopH, intimeW, 20)];
        intimeLabel.font = [UIFont systemFontOfSize:12];
        intimeLabel.text = @"支持过期退";
        intimeLabel.textColor = ColorDarkGray;
        [iconView addSubview:intimeLabel];
        
        //不满意退款
        notSatImageView = [[UIImageView alloc] initWithFrame:CGRectMake(205, iconLineLabel.frame.origin.y + intimeTopH + 3, 15, 15)];
        [iconView addSubview:notSatImageView];

        intimeLabel = [[UILabel alloc] initWithFrame:CGRectMake(notSatImageView.frame.origin.x + notSatImageView.frame.size.width + 3,
                                                                iconLineLabel.frame.origin.y + intimeTopH, intimeW, 20)];
        intimeLabel.font = [UIFont systemFontOfSize:12];
        intimeLabel.text = @"支持不满意退";
        intimeLabel.textColor = ColorDarkGray;
        [iconView addSubview:intimeLabel];
    }
    return _view;
}

#pragma mark - Private
/**
    消费礼券
 */
- (CGFloat)orderCouponView:(CGFloat)top
{
    if (_couponView) {
        [_couponView.subviews makeObjectsPerformSelector:@selector(removeFromSuperview)];
    }
    else {
        _couponView = [[UIView alloc] initWithFrame:CGRectMake(10, top, _scrollView.deFrameWidth - 2*10, 80)];
        _couponView.backgroundColor = [UIColor whiteColor];
        [_scrollView addSubview:_couponView];
    }
    
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
    NSString *orderTime = [dateFormatter stringFromDate: [NSDate dateWithTimeIntervalSince1970:([detailModel.expireDate unsignedLongLongValue]/1000)]];//毫秒->秒
    
    NSArray *titleArr = @[@"车夫券:", @"有效期:", @"消费密码:"];
    NSArray *detailArr = @[detailModel.payNo, orderTime, detailModel.verificationCode];
    
    CGFloat originY = 0;
    for (int i = 0; i < 3; i ++) {
        UILabel *title = [[UILabel alloc] initWithFrame:CGRectMake(contentBeforeW , originY, 70, 25)];
        title.text = titleArr[i];
        title.textAlignment = NSTextAlignmentRight;
        title.font = [UIFont systemFontOfSize:13];
        title.textColor = [QTools colorWithRGB:85 :85 :85];
        [_couponView addSubview:title];
        
        UILabel *detail = [[UILabel alloc] initWithFrame:CGRectMake(contentBeforeW + title.deFrameRight, originY, SCREEN_SIZE_WIDTH - title.deFrameRight, 25)];
        detail.text = detailArr[i];
        detail.font = [UIFont systemFontOfSize:13];
        detail.textColor = [QTools colorWithRGB:85 :85 :85];
        [_couponView addSubview:detail];
        
        originY += 25;
    }
    
    return _couponView.deFrameHeight;
}

- (CGFloat)orderPayButton:(CGFloat)top
{
    UIButton *button = [[UIButton alloc] initWithFrame:CGRectMake(10, top, _scrollView.deFrameWidth - 2*10, 30)];
    [button setTitle:@"付款" forState:UIControlStateNormal];
    button.titleLabel.font = [UIFont systemFontOfSize:14];
    [button setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    button.backgroundColor = ColorTheme;
    [button addTarget:self action:@selector(gotoPay) forControlEvents:UIControlEventTouchUpInside];
    
    [_scrollView addSubview:button];
    
    return button.deFrameHeight;
}

- (CGFloat)productDetailButton:(CGFloat)top
{
    UIButton *button = [[UIButton alloc] initWithFrame:CGRectMake(10, top, _scrollView.deFrameWidth - 2*10, 30)];
    [button setTitle:@"  查看图文详情" forState:UIControlStateNormal];
    [button setTitleColor:UIColorFromRGB(0xc40000) forState:UIControlStateNormal];
    button.titleLabel.font = [UIFont systemFontOfSize:14];
    [button addTarget:self action:@selector(checkDetail) forControlEvents:UIControlEventTouchUpInside];
    [button setContentHorizontalAlignment:UIControlContentHorizontalAlignmentLeft];
    button.backgroundColor  =[UIColor whiteColor];
    [_scrollView addSubview:button];
    checkBtn = button;
    
    UIImageView *arrowImageView = [[UIImageView alloc] initWithImage:IMAGEOF(@"icon_order_arrow")];
    arrowImageView.deFrameTop = (checkBtn.deFrameHeight - arrowImageView.deFrameHeight)/2;
    arrowImageView.deFrameLeft = checkBtn.deFrameWidth - arrowImageView.deFrameWidth - 10;
    [button addSubview:arrowImageView];
    
    return button.deFrameHeight;
}

- (CGFloat)orderDetailInfoView:(CGFloat)top
{
    if (_infoView) {
        [_infoView.subviews makeObjectsPerformSelector:@selector(removeFromSuperview)];
    }
    else {
        _infoView = [[UIView alloc] initWithFrame:CGRectMake(10, top, _scrollView.deFrameWidth - 2*10, 160)];
        _infoView.backgroundColor = [UIColor whiteColor];
        [_scrollView addSubview:_infoView];
    }
    
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(contentBeforeW, 0, _infoView.frame.size.width - 2*contentBeforeW, 30)];
    label.font = [UIFont systemFontOfSize:14];
    label.text = @"订单信息";
    label.textColor = ColorDarkGray;
    [_infoView addSubview:label];
    
    label = [[UILabel alloc] initWithFrame:CGRectMake(contentBeforeW, label.deFrameBottom, _infoView.deFrameWidth - 2*contentBeforeW, 0.5f)];
    label.backgroundColor = ColorLine;
    [_infoView addSubview:label];
    
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
        title.textAlignment = NSTextAlignmentRight;
        title.font = [UIFont systemFontOfSize:13];
        title.textColor = [QTools colorWithRGB:85 :85 :85];
        [_infoView addSubview:title];
        
        UILabel *detail = [[UILabel alloc] initWithFrame:CGRectMake(contentBeforeW + title.deFrameRight, originY, SCREEN_SIZE_WIDTH - title.deFrameRight, 25)];
        detail.text = detailArr[i];
        detail.font = [UIFont systemFontOfSize:13];
        detail.textColor = [QTools colorWithRGB:85 :85 :85];
        [_infoView addSubview:detail];
        
        originY += title.deFrameHeight;
    }

    return _infoView.deFrameHeight;
}

- (CGFloat)orderDrawbackButton:(CGFloat)top
{
    UIButton *drawbackBtn = [[UIButton alloc] initWithFrame:CGRectMake(10, top, _scrollView.deFrameWidth - 2*10, 30)];
    [drawbackBtn setTitle:@"申请退款" forState:UIControlStateNormal];
    [drawbackBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    drawbackBtn.backgroundColor = [UIColor redColor];
    drawbackBtn.titleLabel.font = [UIFont systemFontOfSize:14];
    drawbackBtn.backgroundColor  = ColorTheme;
    [drawbackBtn addTarget:self action:@selector(gotoRecharge) forControlEvents:UIControlEventTouchUpInside];
    [_scrollView addSubview:drawbackBtn];
    
    return drawbackBtn.deFrameHeight;
}

#pragma mark - Action

- (void)setShare
{
}

- (void)gotoPay
{
    [QViewController gotoPage:@"QConfirmOrderPage" withParam:[[NSDictionary alloc] initWithObjectsAndKeys:detailModel, @"QMyListDetailModel", nil]]; //TODO
}

- (void)checkDetail{
    [QViewController gotoPage:@"QGroupBuyDetailPage" withParam:[NSDictionary dictionaryWithObjectsAndKeys:detailModel.productId, @"ProductID", nil]];
}

- (void)gotoRecharge{
    [QViewController gotoPage:@"QApplicationDrawback" withParam:nil];
}

#pragma mark - Notification

- (void)successGetListDetail:(NSNotification *)noti{
    detailModel = noti.object;
    
    //
    if ([detailModel.returnNotSpending intValue])
        [intimeImageView setImage:IMAGEOF(@"icon_yellow_check")];
    else
        [intimeImageView setImage:IMAGEOF(@"icon_yellow_uncheck")];
    
    if ([detailModel.returnOverdue intValue])
        [overtimeImageView setImage:IMAGEOF(@"icon_yellow_check")];
    else
        [overtimeImageView setImage:IMAGEOF(@"icon_yellow_uncheck")];
    
    if ([detailModel.returnDissatisfied intValue])
        [notSatImageView setImage:IMAGEOF(@"icon_yellow_check")];
    else
        [notSatImageView setImage:IMAGEOF(@"icon_yellow_uncheck")];

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
    
    CGFloat originY = 115 + 10;
    
    //1.消费券信息
    if (2 == _status) {
        originY += [self orderCouponView:originY];
        originY += 10;
    }
    //2.支付
    if (1 == _status) {
        originY += [self orderPayButton:originY];
        originY += 10;
    }
    //3.查看商品详情
    originY += [self productDetailButton:originY];
    originY += 10;
    //4.订单详情
    originY += [self orderDetailInfoView:originY];
    originY += 10;
    //5.申请退单
    if (2 == _status) {
        originY += [self orderDrawbackButton:originY];
        originY += 10;
    }
    
    _scrollView.contentSize = CGSizeMake(_scrollView.deFrameWidth, originY);
    
    [ASRequestHUD dismiss];
}

@end
