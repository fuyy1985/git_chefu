//
//  QListNoConsumption.m
//  HRClient
//
//  Created by ekoo on 14/12/14.
//  Copyright (c) 2014年 panyj. All rights reserved.
//

#import "QListNoConsumption.h"
#import "QViewController.h"
#import "QHttpMessageManager.h"
#import "QMyListDetailModel.h"

@interface QListNoConsumption (){
    UILabel *listTitleLabel;
    UILabel *listDetailLabel;
    UILabel *listTitleLabel1;
    UILabel *listDetailLabel1;
    UIButton *editBtn;
    NSString *orderStr;
    UILabel *intimeLabel;
    QMyListDetailModel *detailModel;
    UILabel *titleLabel;
    UILabel *priceLabel;
    UIView *couponView;
    CGFloat contentBeforeW;
    UILabel *lineLabel1;
    CGFloat contentBlank;
    UIView *infroView;
    
    UIImageView *intimeImageView;
    UIImageView *overtimeImageView;
    UIImageView *notSatImageView;
}

@end

@implementation QListNoConsumption

- (void)dealloc{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:kGetMyListDetail object:nil];
}

- (void)setActiveWithParams:(NSDictionary *)params{
    orderStr = [params objectForKey:@"listId"];
}

- (void)pageEvent:(QPageEventType)eventType
{
    if (eventType == kPageEventViewCreate)
    {
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(lookNoConsumptionInfro:) name:kGetMyListDetail object:nil];
        [[QHttpMessageManager sharedHttpMessageManager] accessMyListDetail:orderStr andStatus:@"2"];
        [QTools startShortWaittingInView:_view];
    }
}

- (NSString *)title{
    return @"订单详情";
}

- (UIBarButtonItem*)pageRightMenu{
    _view.backgroundColor = [QTools colorWithRGB:240 :239 :237];
    editBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    editBtn.frame = CGRectMake(0, 0, 40, 10);
    [editBtn setTitle:@"分享" forState:UIControlStateNormal];
    [editBtn setTitleColor:[QTools colorWithRGB:255 :255 :255] forState:UIControlStateNormal];
    editBtn.titleLabel.font = [UIFont boldSystemFontOfSize:18];
    [editBtn addTarget:self action:@selector(setEditig:animated:) forControlEvents:UIControlEventTouchUpInside];
    //    editBtn.backgroundColor = [UIColor yellowColor];
    UIBarButtonItem *editItem = [[UIBarButtonItem alloc] initWithCustomView:editBtn];
    return editItem;
}

- (UIView *)viewWithFrame:(CGRect)frame{
    if ([super viewWithFrame:frame]) {
        _view.backgroundColor = [QTools colorWithRGB:240 :239 :237];
        UIScrollView *scrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 0, frame.size.width, frame.size.height)];
        scrollView.contentSize = CGSizeMake(frame.size.width, 710);
        scrollView.backgroundColor = [QTools colorWithRGB:236 :235 :232];
        [_view addSubview:scrollView];
        //        第一块
        CGFloat beforeW = 10;
        CGFloat topH = 10;
        CGFloat blank = 10;
        CGFloat w = frame.size.width - 2*beforeW;
        CGFloat h = 105;
        UIView *iconView = [[UIView alloc] initWithFrame:CGRectMake(beforeW, topH, w, h)];
        iconView.backgroundColor = [QTools colorWithRGB:255 :255 :255];
        [scrollView addSubview:iconView];
        
        contentBeforeW = 10;
        CGFloat iconW = 80;
        CGFloat iconH = 55;
        contentBlank = 5;
        UIImageView *iconImageView = [[UIImageView alloc] initWithFrame:CGRectMake(contentBeforeW, 10, iconW, iconH)];
        iconImageView.image = [UIImage imageNamed:@"我的订单_03.png"];
        [iconView addSubview:iconImageView];
        
        CGFloat titleW = iconView.frame.size.width - iconImageView.frame.size.width - contentBeforeW - contentBlank;
        CGFloat titleH = 15;
        titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(iconImageView.frame.size.width + contentBeforeW + contentBlank, 10, titleW, titleH)];
        titleLabel.font = [UIFont systemFontOfSize:15];
        //        titleLabel.backgroundColor = [UIColor cyanColor];
        [iconView addSubview:titleLabel];
        
        CGFloat introTopH = titleLabel.frame.origin.y + titleLabel.frame.size.height + contentBlank;
        UILabel *introLabel = [[UILabel alloc] initWithFrame:CGRectMake(iconImageView.frame.size.width + contentBeforeW + contentBlank, introTopH, titleW, titleH)];
        introLabel.text = @"普通单间入住一晚，可升级";
        introLabel.font = [UIFont systemFontOfSize:11];
        introLabel.textColor = [UIColor grayColor];
        //        introLabel.backgroundColor = [UIColor cyanColor];
        [iconView addSubview:introLabel];
        
        CGFloat priceTopH = introLabel.frame.origin.y + introLabel.frame.size.height + contentBlank;
        priceLabel = [[UILabel alloc] initWithFrame:CGRectMake(iconImageView.frame.size.width + contentBeforeW + contentBlank, priceTopH, titleW, titleH)];
//        priceLabel.backgroundColor = [UIColor yellowColor];
        priceLabel.textColor = [QTools colorWithRGB:149 :149 :149];
        priceLabel.font = [UIFont systemFontOfSize:11];
        [iconView addSubview:priceLabel];
        
        UILabel *iconLineLabel = [[UILabel alloc] initWithFrame:CGRectMake(contentBeforeW, iconImageView.frame.origin.y + iconImageView.frame.size.height +blank, iconView.frame.size.width - 2*contentBeforeW, 1)];
        iconLineLabel.backgroundColor = [QTools colorWithRGB:223 :223 :223];
        [iconView addSubview:iconLineLabel];
        
        //支持随时退款
        CGFloat intimeTopH = 4;
        intimeImageView = [[UIImageView alloc] initWithFrame:CGRectMake(5, iconLineLabel.frame.origin.y + intimeTopH + 3, 15, 15)];
        intimeImageView.image = [UIImage imageNamed:@"check01.png"];
        [iconView addSubview:intimeImageView];
        
        CGFloat intimeW = 80;
        
        intimeLabel = [[UILabel alloc] initWithFrame:CGRectMake(intimeImageView.frame.origin.x + intimeImageView.frame.size.width + 3,
                                                                iconLineLabel.frame.origin.y + intimeTopH, intimeW, 20)];
        intimeLabel.font = [UIFont systemFontOfSize:12];
        intimeLabel.textColor = [UIColor blackColor];
        intimeLabel.text = @"支持随时退";
        [iconView addSubview:intimeLabel];
        
        //过期退款
        overtimeImageView = [[UIImageView alloc] initWithFrame:CGRectMake(105, iconLineLabel.frame.origin.y + intimeTopH + 3, 15, 15)];
        overtimeImageView.image = [UIImage imageNamed:@"check01.png"];
        [iconView addSubview:overtimeImageView];
        
        intimeLabel = [[UILabel alloc] initWithFrame:CGRectMake(overtimeImageView.frame.origin.x + overtimeImageView.frame.size.width + 3,
                                                                iconLineLabel.frame.origin.y + intimeTopH, intimeW, 20)];
        intimeLabel.font = [UIFont systemFontOfSize:12];
        intimeLabel.text = @"支持过期退";
        intimeLabel.textColor = [UIColor blackColor];
        [iconView addSubview:intimeLabel];
        
        //不满意退款
        notSatImageView = [[UIImageView alloc] initWithFrame:CGRectMake(205, iconLineLabel.frame.origin.y + intimeTopH + 3, 15, 15)];
        notSatImageView.image = [UIImage imageNamed:@"check01.png"];
        [iconView addSubview:notSatImageView];
        
        intimeLabel = [[UILabel alloc] initWithFrame:CGRectMake(notSatImageView.frame.origin.x + notSatImageView.frame.size.width + 3,
                                                                iconLineLabel.frame.origin.y + intimeTopH, intimeW, 20)];
        intimeLabel.font = [UIFont systemFontOfSize:12];
        intimeLabel.text = @"支持不满意退";
        intimeLabel.textColor = [UIColor blackColor];
        [iconView addSubview:intimeLabel];
        
        //        第二块
        CGFloat couponW = frame.size.width - beforeW * 2;
        CGFloat couponH = 80;
        CGFloat couponTopH = iconView.frame.origin.y + iconView.frame.size.height + topH;
        
        couponView = [[UIView alloc] initWithFrame:CGRectMake(beforeW, couponTopH, couponW, couponH)];
        couponView.backgroundColor = [UIColor whiteColor];
        [scrollView addSubview:couponView];
        
        UIButton *checkBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        checkBtn.frame = CGRectMake(contentBeforeW , couponView.deFrameBottom + blank,frame.size.width - 2*contentBeforeW, 35);
        [checkBtn setTitle:@"  查看图文详情" forState:UIControlStateNormal];
        [checkBtn setTitleColor:UIColorFromRGB(0xc40000) forState:UIControlStateNormal];
        checkBtn.titleLabel.font = [UIFont systemFontOfSize:16];
        checkBtn.backgroundColor = [UIColor whiteColor];
        [scrollView addSubview:checkBtn];
        [checkBtn setContentHorizontalAlignment:UIControlContentHorizontalAlignmentLeft];
        UIImageView *arrowImageView = [[UIImageView alloc] initWithFrame:CGRectMake(checkBtn.deFrameRight - 30, (checkBtn.frame.size.height - 20)/2.0, 11, 19)];
        [checkBtn addTarget:self action:@selector(checkDetail) forControlEvents:UIControlEventTouchUpInside];
        //  arrowImageView.backgroundColor = [UIColor yellowColor];
        arrowImageView.image = IMAGEOF(@"startto02.png");
        [checkBtn addSubview:arrowImageView];
        
        //        第四块
        CGFloat infroH = 175;
        CGFloat infroTopH = checkBtn.deFrameBottom + topH;
        infroView = [[UIView alloc] initWithFrame:CGRectMake(beforeW, infroTopH, w, infroH)];
        infroView.backgroundColor = [UIColor whiteColor];
        [scrollView addSubview:infroView];
        
        UILabel *detailTitleLabel1 = [[UILabel alloc] initWithFrame:CGRectMake(contentBeforeW, 0 + 3, infroView.frame.size.width - 2*contentBeforeW, 20)];
        detailTitleLabel1.text = @"订单信息";
        detailTitleLabel1.font = [UIFont systemFontOfSize:15];
        [infroView addSubview:detailTitleLabel1];
        
        lineLabel1 = [[UILabel alloc] initWithFrame:CGRectMake(contentBeforeW, detailTitleLabel1.frame.origin.y + detailTitleLabel1.frame.size.height + 2, infroView.frame.size.width - 2*contentBeforeW, 1)];
        lineLabel1.backgroundColor = [QTools colorWithRGB:223 :223 :223];
        [infroView addSubview:lineLabel1];
        
//        第五块
        CGFloat drawbackH = 30;
        CGFloat drawbackTopH = blank +infroView.frame.origin.y + infroView.frame.size.height;
        UIButton *drawbackBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        drawbackBtn.frame = CGRectMake(beforeW, drawbackTopH, w, drawbackH);
        [drawbackBtn setTitle:@"申请退款" forState:UIControlStateNormal];
        [drawbackBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        drawbackBtn.backgroundColor = [UIColor redColor];
        drawbackBtn.titleLabel.font = [UIFont boldSystemFontOfSize:18];
        drawbackBtn.backgroundColor  = UIColorFromRGB(0xc40000);
        [drawbackBtn addTarget:self action:@selector(gotoRecharge) forControlEvents:UIControlEventTouchUpInside];
        [scrollView addSubview:drawbackBtn];
    }
    return _view;
}

- (void)gotoRecharge{
    [QViewController gotoPage:@"QApplicationDrawback" withParam:nil];
}

- (void) setEditig:(BOOL)editig animated:(BOOL)animated{
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:nil message:@"开发中" delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
    [alert show];
}

- (void)checkDetail{
    [QViewController gotoPage:@"QComboDetail" withParam:nil];
}

- (void)lookNoConsumptionInfro:(NSNotification *)noti{
    detailModel = noti.object;
    
    if ([detailModel.returnNotSpending intValue])
    {
        [intimeImageView setImage:IMAGEOF(@"check01.png")];
    }
    else
    {
        [intimeImageView setImage:IMAGEOF(@"check002.png")];
    }
    
    if ([detailModel.returnOverdue intValue])
    {
        [overtimeImageView setImage:IMAGEOF(@"check01.png")];
    }
    else
    {
        [overtimeImageView setImage:IMAGEOF(@"check002.png")];
    }
    
    if ([detailModel.returnDissatisfied intValue])
    {
        [notSatImageView setImage:IMAGEOF(@"check01.png")];
    }
    else
    {
        [notSatImageView setImage:IMAGEOF(@"check002.png")];
    }
    
//    标题
    titleLabel.text = detailModel.subject;
//    价格
    NSString *price = [detailModel.total stringValue];
    NSString *text = [NSString stringWithFormat:@"%@元",price];
    NSMutableAttributedString *string = [[NSMutableAttributedString alloc] initWithString:text attributes:@{NSStrikethroughStyleAttributeName:@(NSUnderlineStyleNone)}];
    [string addAttribute:NSFontAttributeName value:[UIFont systemFontOfSize:18] range:[text rangeOfString:price]];
    [string addAttribute:NSForegroundColorAttributeName value:UIColorFromRGB(0xc40000) range:[text rangeOfString:price]];
    priceLabel.attributedText = string;
    
//    券
    NSString *str=[detailModel.expireDate stringValue];//时间戳
    NSTimeInterval time=[str doubleValue];//因为时差问题要加8小时 == 28800 sec
    NSDate *detaildate=[NSDate dateWithTimeIntervalSince1970:time];
    //实例化一个NSDateFormatter对象
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    //设定时间格式,这里可以设置成自己需要的格式
    [dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
    NSString *currentDateStr = [dateFormatter stringFromDate: detaildate];
    
    NSArray *titleArr = [[NSArray alloc] initWithObjects:@"万里无忧券:",@"有效期:",@"消费密码:", nil];
    NSArray *detailArr = [[NSArray alloc] initWithObjects:detailModel.payNo,currentDateStr,detailModel.verificationCode, nil];
    for (int i = 0; i < 3; i ++) {
        listTitleLabel = [[UILabel alloc] initWithFrame:CGRectMake(contentBeforeW , 25*i, 70, 25)];
        listTitleLabel.text = titleArr[i];
        listTitleLabel.textAlignment = NSTextAlignmentRight;
        listTitleLabel.font = [UIFont systemFontOfSize:13];
        listTitleLabel.textColor = [UIColor grayColor];
        [couponView addSubview:listTitleLabel];
    }
    for (int i = 0; i < 3; i ++) {
        listDetailLabel = [[UILabel alloc] initWithFrame:CGRectMake( 2 * contentBeforeW + listTitleLabel.frame.size.width, 25*i, SCREEN_SIZE_WIDTH - listTitleLabel.frame.origin.x - listTitleLabel.frame.size.width , 25)];
        listDetailLabel.text = detailArr[i];
        listDetailLabel.font = [UIFont systemFontOfSize:13];
        listDetailLabel.textColor = [UIColor grayColor];
        [couponView addSubview:listDetailLabel];
    }
//    订单
    NSString *str1=[detailModel.gmtCreate stringValue];//时间戳
    NSTimeInterval time1=[str1 doubleValue];//因为时差问题要加8小时 == 28800 sec
    NSDate *detaildate1=[NSDate dateWithTimeIntervalSince1970:time1];
    //实例化一个NSDateFormatter对象
    NSDateFormatter *dateFormatter1 = [[NSDateFormatter alloc] init];
    //设定时间格式,这里可以设置成自己需要的格式
    [dateFormatter1 setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
    NSString *currentDateStr1 = [dateFormatter1 stringFromDate: detaildate1];
    
    NSArray *titleArr1 = [[NSArray alloc] initWithObjects:@"订单号:",@"购买手机:",@"下单时间:",@"数量:",@"总价:", nil];
    NSArray *detailArr1 = [[NSArray alloc] initWithObjects:[detailModel.orderListId stringValue],detailModel.phone,currentDateStr1,[detailModel.quantity stringValue],[NSString stringWithFormat:@"%@元",detailModel.total], nil];
    for (int i = 0; i < 5; i ++) {
        listTitleLabel1 = [[UILabel alloc] initWithFrame:CGRectMake(contentBeforeW , lineLabel1.frame.origin.y+ contentBlank + 25*i, 70, 25)];
        listTitleLabel1.text = titleArr1[i];
        listTitleLabel1.textAlignment = NSTextAlignmentRight;
        listTitleLabel1.font = [UIFont systemFontOfSize:13];
        listTitleLabel1.textColor = [UIColor grayColor];
        [infroView addSubview:listTitleLabel1];
    }
    for (int i = 0; i < 5; i ++) {
        listDetailLabel1 = [[UILabel alloc] initWithFrame:CGRectMake( 2 * contentBeforeW + listTitleLabel1.frame.size.width, lineLabel1.frame.origin.y+ contentBlank + 25*i, SCREEN_SIZE_WIDTH - listTitleLabel1.frame.origin.x - listTitleLabel1.frame.size.width , 25)];
        listDetailLabel1.text = detailArr1[i];
        listDetailLabel1.font = [UIFont systemFontOfSize:13];
        listDetailLabel1.textColor = [UIColor grayColor];
        [infroView addSubview:listDetailLabel1];
        [QTools endWaittingInView:_view];
    }
}

@end
