//
//  QAgainSetPayKey.m
//  HRClient
//
//  Created by ekoo on 14/12/10.
//  Copyright (c) 2014年 panyj. All rights reserved.
//

#import "QAgainSetPayKey.h"
#import "QViewController.h"
#import "QHttpMessageManager.h"

@interface QAgainSetPayKey (){
    UITextField *inputNewTextFiled;
    UITextField *sureNewTextFiled;
}

@end

@implementation QAgainSetPayKey


- (NSString *)title{
    return @"重新设置支付密码";
}

- (void)pageEvent:(QPageEventType)eventType
{
    if (eventType == kPageEventViewCreate)
    {
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(successResetPayPwd:) name:kReSetPayPwd object:nil];
    }
    else if (eventType == kPageEventViewDispose)
    {
        [[NSNotificationCenter defaultCenter] removeObserver:self];
    }
}

- (UIView *)viewWithFrame:(CGRect)frame{
    if ([super viewWithFrame:frame]) {
        _view.backgroundColor = [QTools colorWithRGB:240 :239 :237];
        CGFloat beforeW = 15.0;
        CGFloat topH = 25.0;
        CGFloat w = frame.size.width - 2*15;
        CGFloat h = 37.0;
        CGFloat blank = 10.0;
        
        inputNewTextFiled = [[UITextField alloc] initWithFrame:CGRectMake(beforeW, topH, w, h)];
        inputNewTextFiled.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
        inputNewTextFiled.borderStyle = UITextBorderStyleRoundedRect;
        inputNewTextFiled.clearButtonMode = UITextFieldViewModeWhileEditing;
        inputNewTextFiled.keyboardType = UIKeyboardTypePhonePad;
        inputNewTextFiled.font = [UIFont systemFontOfSize:14];
        inputNewTextFiled.secureTextEntry = YES;
        inputNewTextFiled.placeholder = @"输入新的支付密码";
        [_view addSubview:inputNewTextFiled];
        
        sureNewTextFiled = [[UITextField alloc] initWithFrame:CGRectMake(beforeW, inputNewTextFiled.deFrameBottom + blank, w, h)];
        sureNewTextFiled.borderStyle = UITextBorderStyleRoundedRect;
        sureNewTextFiled.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
        sureNewTextFiled.clearButtonMode = UITextFieldViewModeWhileEditing;
        sureNewTextFiled.keyboardType = UIKeyboardTypePhonePad;
        sureNewTextFiled.font = [UIFont systemFontOfSize:14];
        sureNewTextFiled.secureTextEntry = YES;
        sureNewTextFiled.placeholder = @"确认新的支付密码";
        [_view addSubview:sureNewTextFiled];
        
        UIButton *finishBtn = [[UIButton alloc] initWithFrame:CGRectMake(beforeW, sureNewTextFiled.deFrameBottom + blank, w, h - 2)];
        [finishBtn setBackgroundImage:[QTools createImageWithColor:ColorTheme] forState:UIControlStateNormal];
        [finishBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [finishBtn setTitle:@"完成" forState:UIControlStateNormal];
        finishBtn.titleLabel.font = [UIFont systemFontOfSize:16];
        finishBtn.layer.masksToBounds = YES;
        finishBtn.layer.cornerRadius = 4.0;
        [finishBtn addTarget:self action:@selector(sureAcommendPayPwd) forControlEvents:UIControlEventTouchUpInside];
        [_view addSubview:finishBtn];
    }
    return _view;
}

#pragma mark - Action
- (void)sureAcommendPayPwd
{
    if (inputNewTextFiled.text.length != 6) {
        [ASRequestHUD showErrorWithStatus:@"请输入6位数字密码"];
    }
    else if (![sureNewTextFiled.text isEqualToString:inputNewTextFiled.text]) {
        [ASRequestHUD showErrorWithStatus:@"新密码两次输入不一致"];
    }
    else {
        [[QHttpMessageManager sharedHttpMessageManager] accessReSetPayPwd:inputNewTextFiled.text andVerifyPayPasswd:sureNewTextFiled.text];
        [ASRequestHUD show];
    }
}

#pragma mark - Notification

- (void)successResetPayPwd:(NSNotification*)noti
{
    [ASRequestHUD dismissWithSuccess:@"支付密码重置成功"];
    
    [QViewController backPageWithParam:nil];
}

@end
