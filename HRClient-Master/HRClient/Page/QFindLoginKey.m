//
//  QFindLoginKey.m
//  HRClient
//
//  Created by ekoo on 14/12/10.
//  Copyright (c) 2014年 panyj. All rights reserved.
//

#import "QFindLoginKey.h"
#import "QViewController.h"
#import "QHttpMessageManager.h"
#import "QRegularHelp.h"
#import "QCountDown.h"

@interface QFindLoginKey (){
    UITextField *codeTextFiled;
    UIButton *acquireBtn;
    UITextField *inputNewTel;
}

@end

@implementation QFindLoginKey

- (void)dealloc{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:kAcquireCode object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:kFindLoginPwd object:nil];
}

- (void)pageEvent:(QPageEventType)eventType
{
    if (eventType == kPageEventWillShow)
    {
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(acquireCode:) name:kAcquireCode object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(acquireFindLoginPwd:) name:kFindLoginPwd object:nil];
    }
    else if (eventType == kPageEventWillHide)
    {
        [[NSNotificationCenter defaultCenter] removeObserver:self name:kFindLoginPwd object:nil];
        [[NSNotificationCenter defaultCenter] removeObserver:self name:kAcquireCode object:nil];
    }
}



- (NSString *)title{
    return @"找回登录密码";
}

- (UIView *)viewWithFrame:(CGRect)frame{
    if ([super viewWithFrame:frame]) {
        _view.backgroundColor = [QTools colorWithRGB:240 :239 :237];
        UIView *view1 = [[UIView alloc] initWithFrame:CGRectMake(0, 0, frame.size.width, frame.size.height)];
        view1.backgroundColor = [QTools colorWithRGB:236 :235 :232];
        [_view addSubview:view1];
        
        CGFloat beforeW = 15.0;
        CGFloat topH = 25.0;
        CGFloat h = 37.0;
        
        acquireBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        acquireBtn.frame = CGRectMake(frame.size.width - beforeW - 110, topH + 1, 110, h - 2);
        [acquireBtn setTitle:@"获取验证码" forState:UIControlStateNormal];
        [acquireBtn setBackgroundImage:[QTools createImageWithColor:ColorTheme] forState:UIControlStateNormal];
        [acquireBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        acquireBtn.layer.masksToBounds = YES;
        acquireBtn.layer.cornerRadius = 4.0;
        acquireBtn.titleLabel.font = [UIFont systemFontOfSize:13];
        [acquireBtn addTarget:self action:@selector(gotoAcquireNeedCode) forControlEvents:UIControlEventTouchUpInside];
        [_view addSubview:acquireBtn];
        
        codeTextFiled = [[UITextField alloc] initWithFrame:CGRectMake(beforeW, topH, acquireBtn.deFrameLeft - beforeW - 5, h)];
        codeTextFiled.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
        codeTextFiled.placeholder = @"输入手机号";
        codeTextFiled.borderStyle = UITextBorderStyleRoundedRect;
        codeTextFiled.clearButtonMode = UITextFieldViewModeWhileEditing;
        codeTextFiled.keyboardType = UIKeyboardTypePhonePad;
        codeTextFiled.font = [UIFont systemFontOfSize:14];
        [_view addSubview:codeTextFiled];
        
        inputNewTel = [[UITextField alloc] initWithFrame:CGRectMake(beforeW, codeTextFiled.deFrameBottom + 15, frame.size.width - 2 * 15.0, h)];
        inputNewTel.placeholder = @"输入验证码";
        inputNewTel.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
        inputNewTel.borderStyle = UITextBorderStyleRoundedRect;
        inputNewTel.clearButtonMode = UITextFieldViewModeWhileEditing;
        inputNewTel.keyboardType = UIKeyboardTypeNumberPad;
        inputNewTel.font = [UIFont systemFontOfSize:14];
        [_view addSubview:inputNewTel];
        
        UIButton *sureChangeBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        sureChangeBtn.frame = CGRectMake(beforeW, inputNewTel.deFrameBottom + 15, frame.size.width - 2 * beforeW, h);
        [sureChangeBtn setTitle:@"下一步" forState:UIControlStateNormal];
        [sureChangeBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [sureChangeBtn setBackgroundImage:[QTools createImageWithColor:ColorTheme] forState:UIControlStateNormal];
        sureChangeBtn.titleLabel.font = [UIFont systemFontOfSize:16];
        sureChangeBtn.layer.masksToBounds = YES;
        sureChangeBtn.layer.cornerRadius = 4.0;
        [sureChangeBtn addTarget:self action:@selector(gotoNewTel) forControlEvents:UIControlEventTouchUpInside];
        [_view addSubview:sureChangeBtn];
        }
    return _view;
}
- (void)gotoNewTel{
    if ([QRegularHelp validateUserPhone:codeTextFiled.text] == NO) {
        [ASRequestHUD showErrorWithStatus:@"电话号码输入有误"];
    }
    else if ([inputNewTel.text isEqualToString:@""]){
        [ASRequestHUD showErrorWithStatus:@"验证码不能为空"];
    }
    else {
        [[QHttpMessageManager sharedHttpMessageManager] accessFindLoginPwd:codeTextFiled.text andVerifyCode:inputNewTel.text];
        [ASRequestHUD show];
    }
}
//验证码获取成功
- (void)acquireCode:(NSNotification *)noti{
    [ASRequestHUD dismiss];
}
//找回登录密码获取数据成功获取
- (void)acquireFindLoginPwd:(NSNotification *)noti{
    [ASRequestHUD dismiss];
    QLoginModel *loginModel = noti.object;
    if (loginModel) {
        [QUser sharedQUser].isLogin = YES;
        [loginModel savetoLocal:@""];
    }
    
    [QViewController gotoPage:@"QFindNewLoginKey" withParam:nil];
}

- (void)gotoAcquireNeedCode{
    if ([QRegularHelp validateUserPhone:codeTextFiled.text]) {
        [QCountDown startTime:acquireBtn];
        [[QHttpMessageManager sharedHttpMessageManager] accessAcquireCode:codeTextFiled.text andMessage:@"(找回登陆密码验证码)"];
    }else{
        [ASRequestHUD showErrorWithStatus:@"电话号码输入有误"];
    }
}


@end
