//
//  QMyVIPCard.m
//  HRClient
//
//  Created by ekoo on 14/12/9.
//  Copyright (c) 2014年 panyj. All rights reserved.
//

#import "QMyVIPCard.h"
#import "QViewController.h"
#import "QHttpMessageManager.h"
#import "QMyAccountMoel.h"

static BOOL isAgree;

@interface QMyVIPCard ()
{
    UIScrollView *scrollView;
    UIButton *introBtn;
    QMemberCardDetail *_cardDetail;
    
    UILabel *titleLabel1;
    UILabel *residueLabel;
    UILabel *validLabel;
    UILabel *numberLabel;
}

@property (nonatomic,strong)UITableView *MyVIPCardTableView;
@property (nonatomic,strong)UIScrollView * scrollView1;
@property (nonatomic,strong)UIView *buttonView;

@end

@implementation QMyVIPCard

- (NSString*)title
{
    return @"洗车会员卡";
}

- (QCacheType)pageCacheType
{
    return kCacheTypeCommon;
}

- (void)pageEvent:(QPageEventType)eventType
{
    if (eventType == kPageEventViewCreate)
    {
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(successGetMyMemberCard:) name:kMyMemberCard object:nil];
    }
    else if (eventType == kPageEventWillShow)
    {
        [[QHttpMessageManager sharedHttpMessageManager] accessGetMyMemberCard];
        [ASRequestHUD show];
    }
    else if (eventType == kPageEventViewDispose)
    {
        [[NSNotificationCenter defaultCenter] removeObserver:self];
    }
}

- (UIView*)viewWithFrame:(CGRect)frame
{
    if ([super viewWithFrame:frame]) {
        isAgree = YES;
        _view.backgroundColor = [QTools colorWithRGB:240 :239 :237];
        _scrollView1 = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 0, frame.size.width, frame.size.height)];
        [_view addSubview:_scrollView1];
        
        UIView *MyVIPCardView = [[UIView alloc] initWithFrame:CGRectMake(0, 15, SCREEN_SIZE_WIDTH, 50)];
        MyVIPCardView.backgroundColor = [QTools colorWithRGB:255 :255 :255];
        [_scrollView1 addSubview:MyVIPCardView];
        
        /*我的会员卡*/
        UILabel *MyVIPCardLable = [[UILabel alloc] initWithFrame:CGRectMake(10, 0, 105, MyVIPCardView.deFrameHeight)];
        MyVIPCardLable.backgroundColor = [UIColor clearColor];
        MyVIPCardLable.font = [UIFont systemFontOfSize:16];
        MyVIPCardLable.textColor = ColorDarkGray;
        MyVIPCardLable.text = @"适用范围：";
        [MyVIPCardView addSubview:MyVIPCardLable];
        [MyVIPCardLable sizeToFit];
        MyVIPCardLable.deFrameHeight = MyVIPCardView.deFrameHeight;
        
        /*卡类型*/
        UILabel *cardStyleLabel = [[UILabel alloc] initWithFrame:CGRectMake(MyVIPCardLable.deFrameRight + 3, 0, 100, MyVIPCardView.deFrameHeight)];
        cardStyleLabel.backgroundColor = [UIColor clearColor];
        cardStyleLabel.font = [UIFont systemFontOfSize:16];
        cardStyleLabel.textColor = ColorTheme;
        cardStyleLabel.text = @"全国通用";
        [MyVIPCardView addSubview:cardStyleLabel];
        
        UIView *displayView = [[UIView alloc] initWithFrame:CGRectMake(0, MyVIPCardView.deFrameBottom + 10, SCREEN_SIZE_WIDTH, 180 + 50)];
        displayView.backgroundColor = [UIColor whiteColor];
        [_scrollView1 addSubview:displayView];
        
        /*卡片展示*/
        UIView *displayCardView = [[UIView alloc] initWithFrame:CGRectMake((SCREEN_SIZE_WIDTH - 240)/2.0, (displayView.frame.size.height-160)/2.0, 240, 160)];
        displayCardView.backgroundColor = [QTools colorWithRGB:181 :0 :7];
        [displayView addSubview:displayCardView];
        
        /*卡片内容*/
        titleLabel1 = [[UILabel alloc] initWithFrame:CGRectMake(0, 30, 240, 40)];
        titleLabel1.backgroundColor = [UIColor clearColor];
        //titleLabel1.text =  [QUser sharedQUser].vipAccount.accountName;
        titleLabel1.textColor = [UIColor whiteColor];
        titleLabel1.textAlignment = NSTextAlignmentCenter;
        titleLabel1.font = [UIFont systemFontOfSize:19];
        [displayCardView addSubview:titleLabel1];
        
        /*余额*/
        residueLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, titleLabel1.frame.origin.y+titleLabel1.frame.size.height, 240, 40)];
        //residueLabel.text =  [NSString stringWithFormat:@"余额：￥%.2f", [[QUser sharedQUser].vipAccount.balance doubleValue]];
        residueLabel.backgroundColor = [UIColor clearColor];
        residueLabel.textColor = [UIColor whiteColor];
        residueLabel.textAlignment = NSTextAlignmentCenter;
        [displayCardView addSubview:residueLabel];
        
        UILabel *lineLabel = [[UILabel alloc] initWithFrame:CGRectMake(10, residueLabel.deFrameBottom + 5, displayCardView.deFrameWidth - 2*10, .5f)];
        lineLabel.backgroundColor = ColorLine;
        [displayCardView addSubview:lineLabel];
        
        validLabel = [[UILabel alloc] initWithFrame:CGRectMake(10, lineLabel.frame.origin.y+5, 220, 40)];
        //validLabel.text =  [NSString stringWithFormat:@"有效期至：%@",orderTime];//@"有效期至：2015-08-10";
        validLabel.font = [UIFont systemFontOfSize:12];
        validLabel.textColor = [UIColor whiteColor];
        validLabel.backgroundColor = [UIColor clearColor];
        [displayCardView addSubview:validLabel];
        
        /*序列号*/
        numberLabel = [[UILabel alloc] initWithFrame:CGRectMake(10, 0, displayCardView.deFrameWidth - 2*10, 40)];
        numberLabel.textAlignment = NSTextAlignmentRight;
        //numberLabel.text = [@"NO." stringByAppendingString:[QUser sharedQUser].vipAccount.accountNo.stringValue];//@"NO.888888";
        numberLabel.backgroundColor = [UIColor clearColor];
        numberLabel.font = [UIFont systemFontOfSize:12];
        numberLabel.textColor = [UIColor whiteColor];
        [displayCardView addSubview:numberLabel];
        
        /*会员说明*/
        introBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        introBtn.frame = CGRectMake(_view.deFrameWidth - 100 - 10, displayView.deFrameBottom + 10, 100, 30);
        introBtn.titleLabel.adjustsFontSizeToFitWidth = YES;
        [introBtn setTitle:@"会员洗车说明" forState:UIControlStateNormal];
        [introBtn setTitleColor:[QTools colorWithRGB:245 :74 :0] forState:UIControlStateNormal];
        [introBtn addTarget:self action:@selector(vipIntrduce) forControlEvents:UIControlEventTouchUpInside];
        [_scrollView1 addSubview:introBtn];
        
        UILabel *lineLabel1 = [[UILabel alloc] initWithFrame:CGRectMake(introBtn.deFrameLeft + 5, introBtn.deFrameBottom - 2, introBtn.frame.size.width - 2*5, .5f)];
        lineLabel1.backgroundColor = [QTools colorWithRGB:245 :74 :0];
        [_scrollView1 addSubview:lineLabel1];
        
        
        [self performSelector:@selector(refreshUI) withObject:nil afterDelay:.2f]; //TODO
        
    }
    return _view;
}

- (void)refreshUI //TODO 信息延迟
{
    titleLabel1.text =  [QUser sharedQUser].vipAccount.accountName;
    residueLabel.text =  [NSString stringWithFormat:@"余额：￥%.2f", [[QUser sharedQUser].vipAccount.balance doubleValue]];
    
    /*有效期*/
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"yyyy/MM/dd"];
    NSDate *expireDate = [NSDate dateWithTimeIntervalSince1970:(([[QUser sharedQUser].vipAccount.expireDate unsignedLongLongValue]) / 1000 )];
    NSString *orderTime = [dateFormatter stringFromDate: expireDate];//毫秒->秒
    
    validLabel.text =  [NSString stringWithFormat:@"有效期至：%@",orderTime];//@"有效期至：2015-08-10";
    numberLabel.text = [@"NO." stringByAppendingString:[QUser sharedQUser].vipAccount.accountNo.stringValue];//@"NO.888888";
}

#pragma mark - Private
- (UIView*)buttonView
{
    if (!_buttonView)
    {
        _buttonView = [[UIView alloc] initWithFrame:CGRectMake(0, introBtn.deFrameBottom + 10, _view.deFrameWidth, 40)];
        _buttonView.backgroundColor = [UIColor clearColor];
        [_scrollView1 addSubview:_buttonView];
        
        CGFloat left = 10;
        if ([_cardDetail.show boolValue])
//        if(1)
        {
            /*距离会员卡过期还有一个月*/
            /*申请延长使用时间*/
            UIButton *lengthTimeBtn = [UIButton buttonWithType:UIButtonTypeCustom];
            [lengthTimeBtn titleLabel].font = [UIFont systemFontOfSize:15.f];
            lengthTimeBtn.frame = CGRectMake(left, 0, (SCREEN_SIZE_WIDTH-30)/2.0, 40);
            [lengthTimeBtn setTitle:@"申请延长使用时间" forState:UIControlStateNormal];
            [lengthTimeBtn setBackgroundImage:[QTools createImageWithColor:ColorTheme] forState:UIControlStateNormal];
            lengthTimeBtn.layer.masksToBounds = YES;
            lengthTimeBtn.layer.cornerRadius = 5.0;
            [lengthTimeBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
            [lengthTimeBtn addTarget:self action:@selector(gotoMoreTime) forControlEvents:UIControlEventTouchUpInside];
            [_buttonView addSubview:lengthTimeBtn];
            
            left += lengthTimeBtn.deFrameWidth + 10;
        }
        
        /*会员卡充值*/
        UIButton *VIPCardRechargeBtn = [[UIButton alloc] initWithFrame:CGRectMake(left, 0, _view.deFrameWidth - left - 10, 40)];
        [VIPCardRechargeBtn titleLabel].font = [UIFont systemFontOfSize:15.f];
        [VIPCardRechargeBtn setTitle:@"洗车会员卡充值" forState:UIControlStateNormal];
        [VIPCardRechargeBtn setBackgroundImage:[QTools createImageWithColor:[QTools colorWithRGB:245 :74 :0]] forState:UIControlStateNormal];
        VIPCardRechargeBtn.layer.masksToBounds = YES;
        VIPCardRechargeBtn.layer.cornerRadius = 5.0;
        [VIPCardRechargeBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [VIPCardRechargeBtn addTarget:self action:@selector(gotoVipRecharge) forControlEvents:UIControlEventTouchUpInside];
        
        //NSRange range = [[QUser sharedQUser].vipAccount.accountName rangeOfString:@"钻石年卡"];
        //VIPCardRechargeBtn.hidden = range.length;
        
        [_buttonView addSubview:VIPCardRechargeBtn];
    }
    return _buttonView;
}

#pragma mark - Action

//延长使用时间
- (void)gotoMoreTime{
    [QViewController gotoPage:@"QVIPCard" withParam:nil];
}

//会员卡充值
- (void)gotoVipRecharge
{
    [QViewController gotoPage:@"QVipChong" withParam:nil];
}

- (void)vipIntrduce
{
    [QViewController gotoPage:@"QAgreementPage" withParam:[[NSDictionary alloc] initWithObjectsAndKeys:[NSNumber numberWithInt:3], @"agreementType", nil]];
}

#pragma mark - Notification
- (void)successGetMyMemberCard:(NSNotification*)noti
{
    _cardDetail = noti.object;
    self.buttonView.backgroundColor = [UIColor clearColor];
    
    [ASRequestHUD dismiss];
}

@end
