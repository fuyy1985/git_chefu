//
//  QFindKey.m
//  HRClient
//
//  Created by ekoo on 14/12/12.
//  Copyright (c) 2014年 panyj. All rights reserved.
//

#import "QFindKey.h"

@implementation QFindKey

- (NSString *)title{
    return @"找回密码";
}

- (UIView *)viewWithFrame:(CGRect)frame{
    if ([super viewWithFrame:frame]) {
        _view.backgroundColor = [QTools colorWithRGB:240 :239 :237];
        CGFloat blankW = 30;
        CGFloat topH = 10;
        CGFloat w = frame.size.width - 2 * blankW;
        CGFloat h = 35;
        UITextField *accountTextFiled = [[UITextField alloc] initWithFrame:CGRectMake(blankW, 15, w, h)];
        accountTextFiled.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
        accountTextFiled.placeholder = @"手机号/用户名/邮箱";
        accountTextFiled.borderStyle = UITextBorderStyleRoundedRect;
        [_view addSubview:accountTextFiled];
        
        UIButton *getNumberBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        getNumberBtn.frame = CGRectMake(blankW, accountTextFiled.frame.origin.y + accountTextFiled.frame.size.height + topH, w, h - 5);
        [getNumberBtn setTitle:@"获取验证码" forState:UIControlStateNormal];
        [getNumberBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        getNumberBtn.layer.masksToBounds = YES;
        getNumberBtn.layer.cornerRadius = 2.0;
        getNumberBtn.titleLabel.font = [UIFont boldSystemFontOfSize:20];
        getNumberBtn.titleLabel.font = [UIFont systemFontOfSize:18];
        getNumberBtn.backgroundColor = [QTools colorWithRGB:184 :184 :184];
        [_view addSubview:getNumberBtn];
        
        UITextField *numberTextFiled = [[UITextField alloc] initWithFrame:CGRectMake(blankW, getNumberBtn.frame.origin.y + getNumberBtn.frame.size.height + topH, w, h)];
        numberTextFiled.placeholder = @"输入手机验证码";
        numberTextFiled.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
        numberTextFiled.borderStyle = UITextBorderStyleRoundedRect;
        [_view addSubview:numberTextFiled];
        
        UIButton *submitBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        submitBtn.frame = CGRectMake(blankW, numberTextFiled.frame.origin.y + numberTextFiled.frame.size.height + topH + 5, w, h + 5);
        [submitBtn setTitle:@"提交" forState:UIControlStateNormal];
        [submitBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        submitBtn.layer.masksToBounds = YES;
        submitBtn.layer.cornerRadius = 8.0;
        submitBtn.titleLabel.font = [UIFont boldSystemFontOfSize:30];
        submitBtn.titleLabel.font = [UIFont systemFontOfSize:20];
        submitBtn.backgroundColor = [QTools colorWithRGB:233 :12 :31];
        [_view addSubview:submitBtn];
        
        UILabel *leftLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, frame.size.height - 80, (SCREEN_SIZE_WIDTH - 80)/2, .5)];
        leftLabel.backgroundColor = [QTools colorWithRGB:200 :200 :198];
        [_view addSubview:leftLabel];
        
        UILabel *rightLineLabel = [[UILabel alloc] initWithFrame:CGRectMake(frame.size.width/2+40, frame.size.height - 80, (frame.size.width - 80)/2, .5)];
        rightLineLabel.backgroundColor =[QTools colorWithRGB:200 :200 :198];
        [_view addSubview:rightLineLabel];
        
        UIButton *centerBtn = [[UIButton alloc] initWithFrame:CGRectMake(frame.size.width/2-40, frame.size.height - 95, 80, 30)];
        [centerBtn setTitle:@"帮助中心" forState:UIControlStateNormal];
        [centerBtn setTitleColor:[QTools colorWithRGB:61 :61 :61] forState:UIControlStateNormal];
        centerBtn.titleLabel.textAlignment = NSTextAlignmentCenter;
        centerBtn.titleLabel.font = [UIFont systemFontOfSize:16];
        [_view addSubview:centerBtn];

        
    }
    return _view;
}

@end
