//
//  QSetPayKey.m
//  HRClient
//
//  Created by ekoo on 14/12/10.
//  Copyright (c) 2014年 panyj. All rights reserved.
//

#import "QSetPayKey.h"
#import "QRegularHelp.h"
#import "QCountDown.h"
#import "QHttpMessageManager.h"
#import "QViewController.h"

#define kAlphaNum   @"0123456789"
@interface QSetPayKey () <UITextFieldDelegate>
{
    UIButton *codeBtn;
    UITextField *inputTextField;
}

@end
@implementation QSetPayKey

- (void)dealloc{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:kAcquireCode object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:kSetPayPwd object:nil];
}

- (void)pageEvent:(QPageEventType)eventType
{
    if (eventType == kPageEventViewCreate)
    {
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(acquireSetPayPwdCode:) name:kAcquireCode object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(successSetPayPwd:) name:kSetPayPwd object:nil];
    }
}

- (QCacheType)pageCacheType
{
    return kCacheTypeNone;
}

- (NSString *)title{
    return @"设置支付密码";
}

- (UIView *)viewWithFrame:(CGRect)frame{
    if ([super viewWithFrame:frame]) {
        _view.backgroundColor = [QTools colorWithRGB:240 :239 :237];
        CGFloat beforeW = 10.0;
        CGFloat topH = 15.0;
        CGFloat h = 38.0;
        NSArray *arr = @[@"输入6位数字密码",@"确认6位数字密码",@"输入手机号",@"输入验证码"];
        for (int i = 0; i < 5; i ++)
        {
            
            if (i < 2)
            {
                UITextField *textField = [[UITextField alloc] initWithFrame:CGRectMake(beforeW, topH + 50 * i, frame.size.width - 2 * beforeW, h)];
                textField.borderStyle = UITextBorderStyleRoundedRect;
                textField.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
                textField.clearButtonMode = UITextFieldViewModeWhileEditing;
                textField.keyboardType = UIKeyboardTypePhonePad;
                textField.font = [UIFont systemFontOfSize:14];
                textField.secureTextEntry = YES;
                textField.placeholder = arr[i];
                textField.delegate = self;
                textField.tag = 100 + i;
                [_view addSubview:textField];
            }
            else if (i == 2)
            {
                //手机号码
                inputTextField = [[UITextField alloc] initWithFrame:CGRectMake(beforeW, topH + 50 * i, 200, h)];
                inputTextField.borderStyle = UITextBorderStyleRoundedRect;
                inputTextField.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
                inputTextField.clearButtonMode = UITextFieldViewModeWhileEditing;
                inputTextField.font = [UIFont systemFontOfSize:14];
                inputTextField.text = NSString_No_Nil([ASUserDefaults objectForKey:LoginUserPhone]);
                inputTextField.placeholder = arr[i];
                [_view addSubview:inputTextField];
                
                codeBtn = [[UIButton alloc] initWithFrame:CGRectMake(inputTextField.deFrameRight + beforeW,
                                                                               topH + 50 * i + 1,
                                                                               frame.size.width - inputTextField.deFrameRight - 2 * beforeW,
                                                                               h - 2)];
                [codeBtn setBackgroundImage:[QTools createImageWithColor:ColorTheme] forState:UIControlStateNormal];
                [codeBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
                [codeBtn setTitle:@"获取验证码" forState:UIControlStateNormal];
                codeBtn.titleLabel.font = [UIFont systemFontOfSize:14];
                codeBtn.layer.masksToBounds = YES;
                codeBtn.layer.cornerRadius = 5.0;
                [codeBtn addTarget:self action:@selector(acquireSetPayPwdCode) forControlEvents:UIControlEventTouchUpInside];
                [_view addSubview:codeBtn];
            }
            else if (i == 3)
            {
                UITextField *textField = [[UITextField alloc] initWithFrame:CGRectMake(beforeW, topH + 50 * i, frame.size.width - 2 * beforeW, h)];
                textField.borderStyle = UITextBorderStyleRoundedRect;
                textField.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
                textField.clearButtonMode = UITextFieldViewModeWhileEditing;
                textField.font = [UIFont systemFontOfSize:14];
                textField.placeholder = arr[i];
                textField.tag = 100 + i;
                [_view addSubview:textField];
            }
            else
            {
                UIButton *button = [[UIButton alloc] initWithFrame:CGRectMake(beforeW, topH + 50 * i, frame.size.width - 2 * beforeW, h)];
                [button setBackgroundImage:[QTools createImageWithColor:ColorTheme] forState:UIControlStateNormal];
                [button setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
                [button setTitle:@"确认设置" forState:UIControlStateNormal];
                button.titleLabel.font = [UIFont systemFontOfSize:16];
                button.layer.masksToBounds = YES;
                button.layer.cornerRadius = 5.0;
                [button addTarget:self action:@selector(sureSetPayPwd) forControlEvents:UIControlEventTouchUpInside];
                [_view addSubview:button];
            }
        }

    }
    return _view;
}

#pragma mark - Action

- (void)acquireSetPayPwdCode
{
    if ([QRegularHelp validateUserPhone:inputTextField.text]) {
        [QCountDown startTime:codeBtn];
        
        [[QHttpMessageManager sharedHttpMessageManager] accessAcquireCode:inputTextField.text andMessage:@"(设立支付密码验证码)"];
        [ASRequestHUD show];
    }
    else{
        [ASRequestHUD showErrorWithStatus:@"电话号码输入有误"];
    }
}

- (void)sureSetPayPwd
{
    
    UITextField *setTextField = (UITextField *)[_view viewWithTag:100];
    UITextField *sureSetTextField = (UITextField *)[_view viewWithTag:101];
    UITextField *codeTextField = (UITextField *)[_view viewWithTag:103];
    if ([setTextField.text length] != 6) {
        [ASRequestHUD showErrorWithStatus:@"请输入6位数字密码"];
    }
    else if (![setTextField.text isEqualToString:sureSetTextField.text]) {
        [ASRequestHUD showErrorWithStatus:@"新密码两次输入不一致"];
    }
    else{
        //设置支付密码
        [[QHttpMessageManager sharedHttpMessageManager] accessSetPayPwd:setTextField.text andVerifyPayPasswd:sureSetTextField.text andPhone:inputTextField.text andVerifyCode:codeTextField.text];
        [ASRequestHUD show];
    }

}

#pragma mark - Notification
//成功获取验证码
- (void)acquireSetPayPwdCode:(NSNotification *)noti{
    [ASRequestHUD dismiss];
}

//设置成功
- (void)successSetPayPwd:(NSNotification *)noti{
    [ASRequestHUD dismissWithSuccess:@"支付密码设置成功"];
    [ASUserDefaults setObject:@"Y" forKey:AccountPayPasswd];
    [QViewController backPageWithParam:nil];
}

@end
