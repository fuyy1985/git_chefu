//
//  QInviteFriendPage.m
//  HRClient
//
//  Created by panyj on 15/3/29.
//  Copyright (c) 2015年 panyj. All rights reserved.
//

#import "QInviteFriendPage.h"

#import "UMSocialSnsService.h"
#import "UMSocialSnsPlatformManager.h"
#import "QViewController.h"

@implementation QInviteFriendPage

- (void)pageEvent:(QPageEventType)eventType
{
    if (eventType == kPageEventViewCreate)
    {
        //NOTE:页面的消息接口 同普通controller的 隐藏消失回调
    }
}

- (UIView *)viewWithFrame:(CGRect)frame{
    if ([super viewWithFrame:frame]) {
        UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
        btn.frame = CGRectMake((20.0/640)*SCREEN_SIZE_WIDTH, (20.0/960)*SCREEN_SIZE_HEIGHT, (100.0/640)*SCREEN_SIZE_WIDTH, (110.0/960.0)*SCREEN_SIZE_HEIGHT);
        [btn setImage:[UIImage imageNamed:@"icon_weixin"] forState:UIControlStateNormal];
//        btn.titleEdgeInsets = UIEdgeInsetsMake(<#CGFloat top#>, <#CGFloat left#>, <#CGFloat bottom#>, <#CGFloat right#>)
//        btn.titleEdgeInsets = UIEdgeInsetsMake((110.0/960.0)*SCREEN_SIZE_HEIGHT, 0, 0, (50.0/640)*SCREEN_SIZE_WIDTH);
        btn.imageEdgeInsets = UIEdgeInsetsMake(0, 0, (10.0/960.0)*SCREEN_SIZE_HEIGHT, 0);
        [btn addTarget:self action:@selector(clickToShare) forControlEvents:UIControlEventTouchUpInside];
        [_view addSubview:btn];
        
        UIButton *btn1 = [UIButton buttonWithType:UIButtonTypeCustom];
        btn1.frame = CGRectMake(btn.deFrameLeft, btn.deFrameBottom, btn.deFrameWidth, (30.0/960.0)*SCREEN_SIZE_HEIGHT);
        btn1.contentHorizontalAlignment = UIControlContentHorizontalAlignmentCenter;
        [btn1 setTitleColor:ColorDarkGray forState:UIControlStateNormal];
        [btn1 setTitle:@"微信" forState:UIControlStateNormal];
        btn1.titleLabel.font = [UIFont systemFontOfSize:14];
        [btn1 addTarget:self action:@selector(clickToShare) forControlEvents:UIControlEventTouchUpInside];
        [_view addSubview:btn1];
        
        
        UIButton *wxLineBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        wxLineBtn.frame = CGRectMake(btn.deFrameRight + (20.0/640)*SCREEN_SIZE_WIDTH, btn.deFrameTop, btn.deFrameWidth, btn.deFrameHeight);
        [wxLineBtn setImage:[UIImage imageNamed:@"icon_pengyouquan"] forState:UIControlStateNormal];
        wxLineBtn.imageEdgeInsets = UIEdgeInsetsMake(0, 0, (10.0/960.0)*SCREEN_SIZE_HEIGHT, 0);
        [wxLineBtn addTarget:self action:@selector(clickToShareLine) forControlEvents:UIControlEventTouchUpInside];
        [_view addSubview:wxLineBtn];
        
        UIButton *wxLineBtn1 = [UIButton buttonWithType:UIButtonTypeCustom];
        wxLineBtn1.frame = CGRectMake(wxLineBtn.deFrameLeft, wxLineBtn.deFrameBottom, wxLineBtn.deFrameWidth, (30.0/960.0)*SCREEN_SIZE_HEIGHT);
        wxLineBtn1.contentHorizontalAlignment = UIControlContentHorizontalAlignmentCenter;
        [wxLineBtn1 setTitle:@"朋友圈" forState:UIControlStateNormal];
        [wxLineBtn1 setTitleColor:ColorDarkGray forState:UIControlStateNormal];
        wxLineBtn1.titleLabel.font = [UIFont systemFontOfSize:14];
        [wxLineBtn1 addTarget:self action:@selector(clickToShareLine) forControlEvents:UIControlEventTouchUpInside];
        [_view addSubview:wxLineBtn1];
        
    }
    return _view;
}
//微信朋友
- (void)clickToShare{
    
    //点击分享的内容时跳到得url
    [[UMSocialDataService defaultDataService] postSNSWithTypes:@[UMShareToWechatSession]
                                                        content:@"车夫-您的全能养车小帮手\n随时随地养车，让服务离您更近，让您养车更省心、有保障更放心，一路都是为了您……"
                                                          image:[UIImage imageNamed:@"icon_share"]
                                                       location:nil
                                                    urlResource:[[UMSocialUrlResource alloc] initWithSnsResourceType:UMSocialUrlResourceTypeDefault url:@"www.baidu.com"]
                                            presentedController:[QViewController shareController]
                                                     completion:^(UMSocialResponseEntity *response){
        if (response.responseCode == UMSResponseCodeSuccess) {
            debug_NSLog(@"分享成功！");
        }
    }];
}
//微信朋友圈
- (void)clickToShareLine
{
    [[UMSocialDataService defaultDataService] postSNSWithTypes:@[UMShareToWechatTimeline]
                                                       content:@"车夫-您的全能养车小帮手\n随时随地养车，让服务离您更近，让您养车更省心、有保障更放心，一路都是为了您……"
                                                         image:[UIImage imageNamed:@"icon_share"]
                                                      location:nil
                                                   urlResource:nil
                                           presentedController:[QViewController shareController]
                                                    completion:^(UMSocialResponseEntity *response) {
        if (response.responseCode == UMSResponseCodeSuccess) {
            debug_NSLog(@"分享成功！");
        }
    }];
}

- (NSString*)title //NOTE:页面标题
{
    return _T(@"邀请好友");
}

- (QNavigationType)navigationType //NOTE:导航栏是否存在
{
    return kNavigationTypeNormal;
}



@end
