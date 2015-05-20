//
//  QNewTel.m
//  HRClient
//
//  Created by ekoo on 14/12/10.
//  Copyright (c) 2014年 panyj. All rights reserved.
//

#import "QNewTel.h"
#import "QHttpMessageManager.h"
#import "QRegularHelp.h"
#import "QCountDown.h"
#import "QViewController.h"

@interface QNewTel (){
    UITextField *inputNewTel;
    UIButton *acquireBtn;
    UITextField *codeTextFiled;
}

@end

@implementation QNewTel

- (void)dealloc{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:kChangeBindPhone object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:kAcquireCode object:nil];
}

- (void)pageEvent:(QPageEventType)eventType
{
    if (eventType == kPageEventWillShow)
    {
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(changeBindInfo:) name:kChangeBindPhone object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(acquireChangeCode:) name:kAcquireCode object:nil];
    }
    else if (eventType == kPageEventWillHide)
    {
        [[NSNotificationCenter defaultCenter] removeObserver:self name:kChangeBindPhone object:nil];
        [[NSNotificationCenter defaultCenter] removeObserver:self name:kAcquireCode object:nil];
    }
}


- (NSString *)title{
    return @"更改绑定手机";
}

- (UIView *)viewWithFrame:(CGRect)frame{
    if ([super viewWithFrame:frame]) {
        
        _view.backgroundColor = [QTools colorWithRGB:236 :235 :232];
        
        CGFloat beforeW = 15.0;
        CGFloat topH = 25.0;
        CGFloat h = 35.0;
        inputNewTel = [[UITextField alloc] initWithFrame:CGRectMake(beforeW, topH, frame.size.width - 2 * 15.0, h)];
        inputNewTel.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
        inputNewTel.font = [UIFont systemFontOfSize:14];
        inputNewTel.placeholder = @"输入新的手机号码";
        inputNewTel.borderStyle = UITextBorderStyleRoundedRect;
        inputNewTel.clearButtonMode = UITextFieldViewModeWhileEditing;
        [_view addSubview:inputNewTel];
        
        acquireBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        acquireBtn.frame = CGRectMake(beforeW, inputNewTel.deFrameBottom + 15, 105.0, h);
        [acquireBtn setTitle:@"获取验证码" forState:UIControlStateNormal];
        [acquireBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [acquireBtn setBackgroundImage:[QTools createImageWithColor:ColorTheme] forState:UIControlStateNormal];
        acquireBtn.layer.masksToBounds = YES;
        acquireBtn.layer.cornerRadius = 2.0;
        acquireBtn.titleLabel.font = [UIFont systemFontOfSize:14];
        [acquireBtn addTarget:self action:@selector(acquireChangePhoneCode) forControlEvents:UIControlEventTouchUpInside];
        [_view addSubview:acquireBtn];
        
        codeTextFiled = [[UITextField alloc] initWithFrame:CGRectMake(acquireBtn.deFrameRight + 15, acquireBtn.deFrameTop, inputNewTel.frame.size.width - acquireBtn.deFrameRight, h)];
        codeTextFiled.font = [UIFont systemFontOfSize:14];
        codeTextFiled.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
        codeTextFiled.placeholder = @"输入验证码";
        codeTextFiled.borderStyle = UITextBorderStyleRoundedRect;
        codeTextFiled.clearButtonMode = UITextFieldViewModeWhileEditing;
        [_view addSubview:codeTextFiled];
        
        UIButton *sureChangeBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        sureChangeBtn.frame = CGRectMake(beforeW, acquireBtn.deFrameBottom + 15, frame.size.width - 2 * beforeW, h);
        [sureChangeBtn setTitle:@"确认更改" forState:UIControlStateNormal];
        [sureChangeBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [sureChangeBtn setBackgroundImage:[QTools createImageWithColor:ColorTheme] forState:UIControlStateNormal];
        sureChangeBtn.titleLabel.font = [UIFont systemFontOfSize:16];
        sureChangeBtn.layer.masksToBounds = YES;
        sureChangeBtn.layer.cornerRadius = 2.0;
        [sureChangeBtn addTarget:self action:@selector(sureToChangeBindPhone) forControlEvents:UIControlEventTouchUpInside];
        [_view addSubview:sureChangeBtn];
    }
    return _view;
}
- (void)acquireChangePhoneCode{
    if ([QRegularHelp validateUserPhone:inputNewTel.text]) {
        [QCountDown startTime:acquireBtn];
        [[QHttpMessageManager sharedHttpMessageManager] accessAcquireCode:inputNewTel.text andMessage:@"(更改绑定验证码)"];
    }
    else{
        [ASRequestHUD showErrorWithStatus:@"电话号码输入有误"];
    }
}

- (void)acquireChangeCode:(NSNotification *)noti{
    
    [ASRequestHUD dismiss];
}
- (void)changeBindInfo:(NSNotification *)noti{
    
    [ASRequestHUD dismissWithSuccess:@"新手机号码绑定成功"];
    //回到我的信息页面
    [QViewController gotoPage:@"QMyData" withParam:nil];
}

- (void)sureToChangeBindPhone{
    
    if ([QRegularHelp validateUserPhone:inputNewTel.text] == NO) {
        [ASRequestHUD showErrorWithStatus:@"电话号码输入有误"];
    }
    else if ([inputNewTel.text isEqualToString:@""]){
        [ASRequestHUD showErrorWithStatus:@"验证码不能为空"];
    }
    else {
        [[QHttpMessageManager sharedHttpMessageManager] accessChangeBindPhone:inputNewTel.text andVerifyCode:codeTextFiled.text];
        [ASRequestHUD show];
    }
}

@end
