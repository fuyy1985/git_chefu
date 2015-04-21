//
//  QMyCounponPage.m
//  HRClient
//
//  Created by ekoo on 14/12/26.
//  Copyright (c) 2014年 panyj. All rights reserved.
//

#import "QMyCounponPage.h"
#import "QViewController.h"
#import "QHttpMessageManager.h"
#import "QRCodeGenerator.h"
#import "QMyListDetailModel.h"

@interface QMyCounponPage ()
{
    NSNumber *orderListId;
    UILabel *_lbName;
    UILabel *_lbExpireData;
    UILabel *_lbKey;
    UIImageView *_codeImageView;
}

@end
@implementation QMyCounponPage

- (void)setActiveWithParams:(NSDictionary *)params
{
    orderListId = [params objectForKey:@"orderListId"];
}

- (NSString *)title{
    return @"车夫券";
}


- (void)pageEvent:(QPageEventType)eventType
{
    if (eventType == kPageEventViewCreate)
    {
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(successGetCouponDetail:) name:kMyCouponDetail object:nil];
        [[QHttpMessageManager sharedHttpMessageManager] accessMyCouponDetail:[orderListId stringValue]];
        [ASRequestHUD show];
    }
    else if (eventType == kPageEventViewDispose)
    {
        [[NSNotificationCenter defaultCenter] removeObserver:self];
    }
}

- (UIView *)viewWithFrame:(CGRect)frame{
    if ([super viewWithFrame:frame]) {
        UILabel *topLineLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 9.5, frame.size.width, 0.5)];
        topLineLabel.backgroundColor = [QTools colorWithRGB:217 :217 :217];
        [_view addSubview:topLineLabel];
        
        UIView *view1 = [[UIView alloc] initWithFrame:CGRectMake(0, 10, frame.size.width, 280)];
        view1.backgroundColor = [QTools colorWithRGB:255 :255 :255];
        [_view addSubview:view1];
        
        UIView *view2 = [[UIView alloc] initWithFrame:CGRectMake(0, 0, frame.size.width, 75)];
        view2.userInteractionEnabled = YES;
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(gotoDrawBack)];
        [view2 addGestureRecognizer:tap];
        [view1 addSubview:view2];
        
        UIImageView *iconImageView = [[UIImageView alloc] initWithFrame:CGRectMake(10, 10, 50, 50)];
        iconImageView.image = [UIImage imageNamed:@"icon_quan"];
        [view2 addSubview:iconImageView];
        
        CGFloat insertW = 20;
        UIImageView *insertImageView =[[UIImageView alloc] initWithFrame:CGRectMake(frame.size.width - 10 - insertW + 8, (iconImageView.frame.size.height - insertW)/2.0 + 12, insertW/2.0, insertW)];
        insertImageView.image = IMAGEOF(@"icon_order_arrow");
        [view2 addSubview:insertImageView];
        
        UILabel *nameLabel = [[UILabel alloc] initWithFrame:CGRectMake(iconImageView.deFrameRight + 10, 10, frame.size.width - iconImageView.deFrameRight - 2 * 10 - insertW, 20)];
        [view2 addSubview:nameLabel];
        _lbName = nameLabel;
        
        UILabel *dateLabel = [[UILabel alloc] initWithFrame:CGRectMake(nameLabel.deFrameLeft, nameLabel.deFrameBottom + 10, nameLabel.frame.size.width, nameLabel.frame.size.height)];
        dateLabel.textColor = [UIColor grayColor];
        dateLabel.font = [UIFont systemFontOfSize:15];
        [view2 addSubview:dateLabel];
        _lbExpireData = dateLabel;
        
        UILabel *lineLable = [[UILabel alloc] initWithFrame:CGRectMake(10, view2.deFrameBottom, frame.size.width - 2*10, 0.5)];
        lineLable.backgroundColor = ColorLine;
        [view1 addSubview:lineLable];
        
        UILabel *keyLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, view2.deFrameBottom + 15, frame.size.width, 15)];
        keyLabel.textAlignment = NSTextAlignmentCenter;
        [view1 addSubview:keyLabel];
        _lbKey = keyLabel;
        
        UIImageView *codeImageView = [[UIImageView alloc] initWithFrame:CGRectMake((frame.size.width - 140)/2.0, keyLabel.deFrameBottom + 15, 140, 140)];
        [view1 addSubview:codeImageView];
        _codeImageView = codeImageView;

        NSString *text = @"温馨提示：请在确认消费完毕后再出示消费密码或二维码";
        NSRange range = [text rangeOfString:@"温馨提示："];
        NSMutableAttributedString *string = [[NSMutableAttributedString alloc] initWithString:text attributes:@{NSStrikethroughStyleAttributeName:@(NSUnderlineStyleNone)}];
        [string addAttribute:NSFontAttributeName value:[UIFont boldSystemFontOfSize:16] range:range];
        [string addAttribute:NSForegroundColorAttributeName value:ColorTheme range:range];
        
        UILabel *tipLabel = [[UILabel alloc] initWithFrame:CGRectMake(15, view1.deFrameBottom + 15, SCREEN_SIZE_WIDTH - 2*15, 30)];
        tipLabel.numberOfLines = 0;
        tipLabel.textColor = ColorDarkGray;
        tipLabel.font = [UIFont systemFontOfSize:14];
        tipLabel.attributedText = string;
        [tipLabel sizeToFit];
        [_view addSubview:tipLabel];
        
    }
    return _view;
}

#pragma mark - Aciton
- (void)gotoDrawBack
{
    [QViewController gotoPage:@"QListDetail" withParam:[[NSDictionary alloc] initWithObjectsAndKeys:orderListId, @"orderListId", [NSNumber numberWithInt:kOrderStatusUnUsed], @"status", nil]];
}

#pragma mark - Notification
- (void)successGetCouponDetail:(NSNotification*)noti {
    [ASRequestHUD dismiss];
    
    QMyCouponDetailModel *model = (QMyCouponDetailModel*)noti.object;
    //商品名称
    _lbName.text = NSString_No_Nil(model.subject);
    //消费密码
    _lbExpireData.text = NSString_No_Nil(model.expireDate);
    //消费二维码
    NSString *key = @"消费密码：";
    _lbKey.text = [key stringByAppendingString:model.verificationCode];
    _codeImageView.image = [QRCodeGenerator qrImageForString:model.verificationCode imageSize:140];
}

@end
