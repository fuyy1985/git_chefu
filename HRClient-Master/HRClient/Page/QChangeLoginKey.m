//
//  QChangeLoginKey.m
//  HRClient
//
//  Created by ekoo on 14/12/10.
//  Copyright (c) 2014年 panyj. All rights reserved.
//

#import "QChangeLoginKey.h"
#import "QViewController.h"
#import "QHttpMessageManager.h"
#define kAlphaNum   @"ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789"

@interface QChangeLoginKey (){
    UITextField *nowKeyTextFiled;
    UITextField *againKeyTextFiled;
    UITextField *sureKeyTextFiled;
}

@end

@implementation QChangeLoginKey

- (NSString *)title{
    return @"修改登录密码";
}

- (void)pageEvent:(QPageEventType)eventType
{
    if (eventType == kPageEventWillShow)
    {
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(acommendLoginPwdInfro:) name:kSureFindLoginPwd object:nil];
    }
    else if (eventType == kPageEventWillHide)
    {
        [ASRequestHUD dismiss];
        [[NSNotificationCenter defaultCenter] removeObserver:self name:kSureFindLoginPwd object:nil];
    }
}

- (UIView *)viewWithFrame:(CGRect)frame{
    if ([super viewWithFrame:frame]) {
        _view.backgroundColor = [QTools colorWithRGB:240 :239 :237];
        CGFloat beforeW = 10.0;
        CGFloat topH = 10.0;
        CGFloat w = frame.size.width;
        CGFloat h = 37.0;
        CGFloat blank = 10.0;
        nowKeyTextFiled = [[UITextField alloc] initWithFrame:CGRectMake(beforeW, topH, w - 20, h)];
        nowKeyTextFiled.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
        nowKeyTextFiled.placeholder = @"当前登录密码";
        nowKeyTextFiled.borderStyle = UITextBorderStyleRoundedRect;
        nowKeyTextFiled.clearButtonMode = UITextFieldViewModeWhileEditing;
        nowKeyTextFiled.font = [UIFont systemFontOfSize:14];
        nowKeyTextFiled.delegate = self;
        nowKeyTextFiled.secureTextEntry = YES;
        [_view addSubview:nowKeyTextFiled];
        
        againKeyTextFiled = [[UITextField alloc] initWithFrame:CGRectMake(beforeW, nowKeyTextFiled.frame.size.height+nowKeyTextFiled.frame.origin.y + blank, w - 20, h)];
        againKeyTextFiled.placeholder = @"新登录密码";
        againKeyTextFiled.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
        againKeyTextFiled.borderStyle = UITextBorderStyleRoundedRect;
        againKeyTextFiled.clearButtonMode = UITextFieldViewModeWhileEditing;
        againKeyTextFiled.font = [UIFont systemFontOfSize:14];
        againKeyTextFiled.delegate = self;
        againKeyTextFiled.secureTextEntry = YES;
        [_view addSubview:againKeyTextFiled];
        
        sureKeyTextFiled = [[UITextField alloc] initWithFrame:CGRectMake(beforeW, againKeyTextFiled.frame.size.height+againKeyTextFiled.frame.origin.y + blank, w - 20, h)];
        sureKeyTextFiled.placeholder = @"确认新登录密码";
        sureKeyTextFiled.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
        sureKeyTextFiled.borderStyle = UITextBorderStyleRoundedRect;
        sureKeyTextFiled.clearButtonMode = UITextFieldViewModeWhileEditing;
        sureKeyTextFiled.font = [UIFont systemFontOfSize:14];
        sureKeyTextFiled.delegate = self;
        sureKeyTextFiled.secureTextEntry = YES;
        [_view addSubview:sureKeyTextFiled];
        
        UIButton *sureBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        sureBtn.frame = CGRectMake(beforeW, sureKeyTextFiled.frame.size.height+sureKeyTextFiled.frame.origin.y+2*blank, w - 20, h);
        [sureBtn setTitle:@"确认修改" forState:UIControlStateNormal];
        [sureBtn setBackgroundImage:[QTools createImageWithColor:ColorTheme] forState:UIControlStateNormal];
        sureBtn.layer.masksToBounds = YES;
        sureBtn.layer.cornerRadius = 4.0;
        [sureBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [sureBtn addTarget:self action:@selector(gotoSuccessReplance) forControlEvents:UIControlEventTouchUpInside];
        [_view addSubview:sureBtn];
        
    }
    return _view;
}

#pragma mark - Private

- (void)viewResignFirstResponder
{
    if (nowKeyTextFiled.isFirstResponder) {
        [nowKeyTextFiled resignFirstResponder];
    }
    else if (againKeyTextFiled.isFirstResponder) {
        [againKeyTextFiled resignFirstResponder];
    }
    else if (sureKeyTextFiled.isFirstResponder) {
        [sureKeyTextFiled resignFirstResponder];
    }
}

- (void)gotoSuccessReplance{
    
    [self viewResignFirstResponder];
    
    if ([againKeyTextFiled.text length] < 6) {
        [ASRequestHUD showErrorWithStatus:@"请输入6-12英文或者数字"];
        return ;
    }
    if ([againKeyTextFiled.text isEqualToString:sureKeyTextFiled.text]) {
        [[QHttpMessageManager sharedHttpMessageManager] accessAcommendLoginPwd:nowKeyTextFiled.text andPassword:againKeyTextFiled.text andVerifyPassword:sureKeyTextFiled.text];
        [ASRequestHUD show];
    }else{
        [ASRequestHUD showErrorWithStatus:@"两次密码输入不一致"];
    }
}

- (void)acommendLoginPwdInfro:(NSNotification *)noti{
    [ASRequestHUD dismissWithSuccess:@"修改成功"];
    [QViewController backPageWithParam:nil];
}

#pragma mark - UITextFieldDelegate
//textField的限制
- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string{
    if ([string isEqualToString:@"\n"]) {
        return NO;
    }
    NSString *toBeString = [textField.text stringByReplacingCharactersInRange:range withString:string];
    if (againKeyTextFiled == textField) {
        if ([toBeString length] >12) {
            textField.text = [toBeString substringToIndex:12];
            [ASRequestHUD showErrorWithStatus:@"请输入6-12英文或者数字"];
            return NO;
        }
    }
    return YES;
/*
    NSCharacterSet *cs = [[NSCharacterSet characterSetWithCharactersInString:kAlphaNum] invertedSet];
    NSString *filtered = [[string componentsSeparatedByCharactersInSet:cs] componentsJoinedByString:@""];
    BOOL canChange = [string isEqualToString:filtered];
    return canChange;
*/
}


@end
