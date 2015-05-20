//
//  QRemark.m
//  HRClient
//
//  Created by ekoo on 14/12/9.
//  Copyright (c) 2014年 panyj. All rights reserved.
//

#import "QRemark.h"
#import "QRemarkTextView.h"
#import "QHttpMessageManager.h"
#import "QViewController.h"
#import "QMyListDetailModel.h"
#import "ASStarRating.h"
#import "ASStarRating.h"

#define TagRateViewOffset       (787)

static BOOL isAnonymous;
@interface QRemark () <StarRatingViewDelegate>
{
    UILabel *placerLabel;
    QRemarkTextView *messageTextView;
    UIImageView *annoymousImageView;
    QMyListDetailModel *orderModel;
    
    NSString *service;
    NSString *quanlity;
    NSString *enviorment;
    NSString *description;
}

@end

@implementation QRemark

- (void)dealloc{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:kListRemark object:nil];
}

- (void)setActiveWithParams:(NSDictionary*)params //NOTE:方便页面激活时接收参数
{
    orderModel = [params objectForKey:@"model"];
}

- (void)pageEvent:(QPageEventType)eventType
{
    if (eventType == kPageEventViewCreate)
    {
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(acquireRemarkSuccessInro:) name:kListRemark object:nil];
    }
}

- (NSString*)title{
    return @"评价";
}

- (UIBarButtonItem*)pageRightMenu {
    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    button.frame = CGRectMake(0, 0, 40, 10);
    [button setTitle:@"完成" forState:UIControlStateNormal];
    [button setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    button.titleLabel.font = [UIFont boldSystemFontOfSize:16];
    [button addTarget:self action:@selector(onSubmitRemark:) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem *editItem = [[UIBarButtonItem alloc] initWithCustomView:button];
    
    return editItem;
}

- (UIView*)viewWithFrame:(CGRect)frame{
    
    if ([super viewWithFrame:frame]) {
        
        _view.backgroundColor = [QTools colorWithRGB:240 :239 :237];
        //名字
        UIView *gradeView = [[UIView alloc] initWithFrame:CGRectMake(0, 15, SCREEN_SIZE_WIDTH, 160.0/415*(SCREEN_SIZE_HEIGHT - 65))];
        gradeView.backgroundColor = [UIColor whiteColor];
        [_view addSubview:gradeView];
        
        UILabel *companyName = [[UILabel alloc] initWithFrame:CGRectMake(10, 0, gradeView.deFrameWidth - 2*20, 45)];
        companyName.text = orderModel.subject;
        companyName.font = [UIFont boldSystemFontOfSize:15];
        companyName.textColor = ColorDarkGray;
        companyName.backgroundColor = [UIColor clearColor];
        [gradeView addSubview:companyName];
        
        UILabel *priceLabel = [[UILabel alloc] initWithFrame:companyName.frame];
        priceLabel.backgroundColor = [UIColor clearColor];
        priceLabel.text = [NSString stringWithFormat:@"%@元", orderModel.total];
        priceLabel.font = [UIFont systemFontOfSize:13];
        priceLabel.textAlignment = NSTextAlignmentRight;
        priceLabel.textColor = ColorTheme;
        [priceLabel sizeToFit];
        [gradeView addSubview:priceLabel];
        priceLabel.deFrameHeight = 45;
        //位置调整
        priceLabel.deFrameRight = gradeView.deFrameWidth - 10;
        companyName.deFrameWidth = priceLabel.deFrameRight - companyName.deFrameLeft - 5;
        
        UIView *lineView = [[UIView alloc] initWithFrame:CGRectMake(10, priceLabel.deFrameBottom, SCREEN_SIZE_WIDTH - 2*10, 0.5f)];
        lineView.backgroundColor = ColorLine;
        [gradeView addSubview:lineView];
        
        NSArray *titleArr = @[@"服务态度", @"质量", @"环境", @"描述"];
        //评分
        CGFloat originY = priceLabel.deFrameBottom + 10;
        for (int i = 0; i < titleArr.count; i ++) {
            UILabel *title = [[UILabel alloc] initWithFrame:CGRectMake(20 , originY, 60, 25)];
            title.backgroundColor = [UIColor clearColor];
            title.text = titleArr[i];
            title.textAlignment = NSTextAlignmentLeft;
            title.font = [UIFont systemFontOfSize:13];
            title.textColor = [QTools colorWithRGB:85 :85 :85];
            [gradeView addSubview:title];
            
            ASStarRating *rateView = [[ASStarRating alloc] initWithFrame:CGRectMake(100, originY + 6, 80, 13)];
            rateView.delegate = self;
            rateView.enableRate = YES;
            rateView.tag = TagRateViewOffset + i;
            [rateView setScore:5];
            [gradeView addSubview:rateView];
            
            originY += 25;
        }
        
        //评价
        UIView *remarkView = [[UIView alloc] initWithFrame:CGRectMake(0, gradeView.frame.origin.y+gradeView.frame.size.height+10, SCREEN_SIZE_WIDTH, 160.0/415*(SCREEN_SIZE_HEIGHT - 65))];
        remarkView.backgroundColor = [UIColor whiteColor];
        [_view addSubview:remarkView];
        
        messageTextView = [[QRemarkTextView alloc] initWithFrame:CGRectMake(20, 0, remarkView.deFrameWidth - 2*20, remarkView.deFrameHeight)];
        messageTextView.textColor = ColorDarkGray;
        messageTextView.placeholder = @"评价留言";
        messageTextView.placeholderColor = [QTools colorWithRGB:136 :136 :136];
        [remarkView addSubview:messageTextView];
        
        //是否匿名
        UIView *anonymousView = [[UIView alloc] initWithFrame:CGRectMake(0, remarkView.deFrameBottom + 10, SCREEN_SIZE_WIDTH, 32)];
        anonymousView.backgroundColor = [UIColor whiteColor];
        [_view addSubview:anonymousView];
        
        UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(20, 0, 80, anonymousView.deFrameHeight)];
        label.backgroundColor = [UIColor clearColor];
        label.textColor = ColorDarkGray;
        label.text = @"匿名评价";
        label.font = [UIFont systemFontOfSize:14];
        [anonymousView addSubview:label];
        
        isAnonymous = NO;
        UIButton *button = [[UIButton alloc] initWithFrame:CGRectMake(anonymousView.deFrameWidth - 40, 0, 40, 32)];
        [button setImage:IMAGEOF(@"icon_collect_unselected") forState:UIControlStateNormal];
        [button setImage:IMAGEOF(@"icon_collect_selected") forState:UIControlStateSelected];
        [button addTarget:self action:@selector(onSelectAnnoymous:) forControlEvents:UIControlEventTouchUpInside];
        [anonymousView addSubview:button];
    }
    return _view;
}

#pragma mark - Action

- (void)onSelectAnnoymous:(id)sender
{
    UIButton *button = (UIButton*)sender;
    button.selected = !button.selected;
    
    isAnonymous = button.selected;
}

- (void)onSubmitRemark:(id)sender
{
    NSString *userId;
    if (isAnonymous)
        userId = @"-1";
    else
        userId = [ASUserDefaults objectForKey:AccountUserID];
    
    if (service == nil)
        service = @"5";
    if (quanlity == nil)
        quanlity = @"5";
    if (enviorment == nil)
        enviorment = @"5";
    if (description == nil)
        description = @"5";
    
    if ([messageTextView.text isEqualToString:@""]) {
        messageTextView.text = @"好评";
    }

    [[QHttpMessageManager sharedHttpMessageManager] accessSetListRemark:messageTextView.text
                                                              andUserId:userId
                                                           andProductId:[orderModel.productId stringValue]
                                                     andServiceAttitude:service
                                                             andQuality:quanlity
                                                         andEnvironment:enviorment
                                                         andDescription:description
                                                         andCommentType:@"1"
                                                           andCompanyId:[orderModel.companyId stringValue]
                                                         andOrderListId:[orderModel.orderListId stringValue]];
    [ASRequestHUD show];

}



- (void)acquireRemarkSuccessInro:(NSNotification *)noti{
    
    [ASRequestHUD dismiss];
    [QViewController backPageWithParam:nil];
}

#pragma mark - StarRatingViewDelegate

-(void)starRatingView:(ASStarRating *)view score:(float)score
{
    switch (view.tag - TagRateViewOffset) {
        case 0:
            //服务态度
            service = [NSString stringWithFormat:@"%f",score];
            break;
        case 1:
            //质量
            quanlity = [NSString stringWithFormat:@"%f",score];
            break;
        case 2:
            //环境
            enviorment = [NSString stringWithFormat:@"%f",score];
            break;
        case 3:
            //描述
            description = [NSString stringWithFormat:@"%f",score];
            break;
        default:
            break;
    }
}


@end
