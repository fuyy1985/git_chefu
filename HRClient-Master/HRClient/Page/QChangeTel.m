//
//  QChangeTel.m
//  HRClient
//
//  Created by ekoo on 14/12/10.
//  Copyright (c) 2014年 panyj. All rights reserved.
//

#import "QChangeTel.h"
#import "QViewController.h"
#import "DHTwoTabControl.h"
#import "QRegularHelp.h"
#import "QCountDown.h"
#import "QHttpMessageManager.h"
#define WIDTH(x)  (((CGFloat)x/320)*([[UIScreen mainScreen] bounds].size.width))
#define HEIGHT(y)  ((CGFloat)y/((480-64)*(([[UIScreen mainScreen] bounds].size.height)-64)))

@interface QChangeTel (){
    UITextField *codeTextFiled;
    UIButton *acquireBtn;
    UITextField *inputNewTel;
    NSString *code;
}

@end

@implementation QChangeTel

- (void)dealloc{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:kConfirmBindPhone object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:kAcquireCode object:nil];
}

- (void)pageEvent:(QPageEventType)eventType
{
    if (eventType == kPageEventWillShow)
    {
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(acquireBindInfo:) name:kConfirmBindPhone object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(acquireCode:) name:kAcquireCode object:nil];
    }
    else if (eventType == kPageEventWillHide)
    {
        [[NSNotificationCenter defaultCenter] removeObserver:self name:kConfirmBindPhone object:nil];
        [[NSNotificationCenter defaultCenter] removeObserver:self name:kAcquireCode object:nil];
    }
}


- (NSString *)title{
    return @"更改绑定手机";
}


- (UIView *)viewWithFrame:(CGRect)frame{
    if ([super viewWithFrame:frame]) {
        _view.backgroundColor = [QTools colorWithRGB:240 :239 :237];
        UIView *view1 = [[UIView alloc] initWithFrame:CGRectMake(0, 0, frame.size.width, frame.size.height)];
        view1.backgroundColor = [QTools colorWithRGB:236 :235 :232];
        [_view addSubview:view1];
        
        CGFloat beforeW = 15.0;
        CGFloat topH = 25.0;
        CGFloat h = 35.0;
        codeTextFiled = [[UITextField alloc] initWithFrame:CGRectMake(beforeW, topH, 200, h)];
        codeTextFiled.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
        codeTextFiled.placeholder = @"输入手机号";
        codeTextFiled.text = NSString_No_Nil([ASUserDefaults objectForKey:LoginUserPhone]);
        codeTextFiled.borderStyle = UITextBorderStyleRoundedRect;
        codeTextFiled.clearButtonMode = UITextFieldViewModeWhileEditing;
        codeTextFiled.keyboardType = UIKeyboardTypePhonePad;
        codeTextFiled.font = [UIFont systemFontOfSize:14];
        [_view addSubview:codeTextFiled];
        
        acquireBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        acquireBtn.frame = CGRectMake(codeTextFiled.deFrameRight + 15, topH + 1, frame.size.width - 2 * beforeW - codeTextFiled.frame.size.width - 5, h - 2);
        [acquireBtn setTitle:@"获取验证码" forState:UIControlStateNormal];
        [acquireBtn setBackgroundImage:[QTools createImageWithColor:ColorTheme] forState:UIControlStateNormal];
        [acquireBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        acquireBtn.layer.masksToBounds = YES;
        acquireBtn.layer.cornerRadius = 2.0;
        acquireBtn.titleLabel.font = [UIFont systemFontOfSize:13];
        [acquireBtn addTarget:self action:@selector(gotoAcquireNeedCode) forControlEvents:UIControlEventTouchUpInside];
        [_view addSubview:acquireBtn];
        
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
        [sureChangeBtn setTitle:@"验证" forState:UIControlStateNormal];
        [sureChangeBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [sureChangeBtn setBackgroundImage:[QTools createImageWithColor:ColorTheme] forState:UIControlStateNormal];
        sureChangeBtn.titleLabel.font = [UIFont systemFontOfSize:16];
        sureChangeBtn.layer.masksToBounds = YES;
        sureChangeBtn.layer.cornerRadius = 2.0;
        [sureChangeBtn addTarget:self action:@selector(gotoNewTel) forControlEvents:UIControlEventTouchUpInside];
        [_view addSubview:sureChangeBtn];
    }
    return _view;
}

- (void)gotoAcquireNeedCode{
    
    if ([QRegularHelp validateUserPhone:codeTextFiled.text] == NO) {
        [ASRequestHUD showErrorWithStatus:@"电话号码输入有误"];
    }
    else {
        [QCountDown startTime:acquireBtn];
        [[QHttpMessageManager sharedHttpMessageManager] accessAcquireCode:codeTextFiled.text andMessage:@"(更改绑定手机验证码)"];
        [ASRequestHUD show];
    }
}
//获取验证码成功
- (void)acquireCode:(NSNotification *)noti{
    
    [ASRequestHUD dismiss];
    code = noti.object;
}

- (void)gotoNewTel{
    if ([QRegularHelp validateUserPhone:codeTextFiled.text] == NO) {
        [ASRequestHUD showErrorWithStatus:@"电话号码输入有误"];
    }
    else if ([inputNewTel.text isEqualToString:@""]){
        [ASRequestHUD showErrorWithStatus:@"验证码不能为空"];
    }
    else {
        [[QHttpMessageManager sharedHttpMessageManager] accessConfirmBindPhone:codeTextFiled.text andVerifyCode:inputNewTel.text];
        [ASRequestHUD show];
    }
}
//验证手机成功
- (void)acquireBindInfo:(NSNotification *)noti{
    
    [ASRequestHUD dismiss];
    [QViewController gotoPage:@"QNewTel" withParam:nil];
}


@end
