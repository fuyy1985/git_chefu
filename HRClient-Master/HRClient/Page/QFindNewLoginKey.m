//
//  QFindNewLoginKey.m
//  HRClient
//
//  Created by ekoo on 14/12/18.
//  Copyright (c) 2014年 panyj. All rights reserved.
//

#import "QFindNewLoginKey.h"
#import "QViewController.h"
#import "QHttpMessageManager.h"
#define kAlphaNum   @"ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789"

@interface QFindNewLoginKey (){
    UITextField *nowKeyTextFiled;
    UITextField *againKeyTextFiled;
}

@end

@implementation QFindNewLoginKey

- (void)dealloc{
    NSLog(@"");
}

- (void)pageEvent:(QPageEventType)eventType
{
    if (eventType == kPageEventWillShow)
    {
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(sureToFindLoginPwd:) name:kSureFindLoginPwd object:nil];
    }
    else if (eventType == kPageEventWillHide)
    {
        [[NSNotificationCenter defaultCenter] removeObserver:self name:kSureFindLoginPwd object:nil];
    }
}

- (NSString *)title{
    return @"找回登录密码";
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
        nowKeyTextFiled.placeholder = @"输入新的登录密码";
        nowKeyTextFiled.secureTextEntry = YES;
        nowKeyTextFiled.borderStyle = UITextBorderStyleRoundedRect;
        nowKeyTextFiled.clearButtonMode = UITextFieldViewModeWhileEditing;
        nowKeyTextFiled.font = [UIFont systemFontOfSize:14];
        [_view addSubview:nowKeyTextFiled];
        
        againKeyTextFiled = [[UITextField alloc] initWithFrame:CGRectMake(beforeW, nowKeyTextFiled.frame.size.height+nowKeyTextFiled.frame.origin.y + blank, w - 20, h)];
        againKeyTextFiled.placeholder = @"确认新的登录密码";
        againKeyTextFiled.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
        againKeyTextFiled.secureTextEntry = YES;
        againKeyTextFiled.borderStyle = UITextBorderStyleRoundedRect;
        againKeyTextFiled.clearButtonMode = UITextFieldViewModeWhileEditing;
        againKeyTextFiled.font = [UIFont systemFontOfSize:14];
        [_view addSubview:againKeyTextFiled];
        
        UIButton *sureBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        sureBtn.frame = CGRectMake(beforeW, againKeyTextFiled.frame.size.height+againKeyTextFiled.frame.origin.y+2*blank, w - 20, h);
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

- (void)gotoSuccessReplance{
    if ([nowKeyTextFiled.text length] < 6) {
        [ASRequestHUD showErrorWithStatus:@"请输入6-12英文或者数字"];
        return ;
    }
    if ([nowKeyTextFiled.text isEqualToString:againKeyTextFiled.text]) {
        [[QHttpMessageManager sharedHttpMessageManager] accessSureFindLoginPwd:nowKeyTextFiled.text andVerifyNewPassword:againKeyTextFiled.text];
        [ASRequestHUD show];
    }else{
        [ASRequestHUD showErrorWithStatus:@"两次输入密码不一致"];
    }
    
}
/**
 密码修改成功
 */
- (void)sureToFindLoginPwd:(NSNotification *)noti{
    [ASRequestHUD dismissWithSuccess:@"密码修改成功"];
    
    [QViewController gotoPage:@"QMyPage" withParam:nil];
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string{
    if ([string isEqualToString:@"\n"]) {
        return NO;
    }
    NSString *toBeString = [textField.text stringByReplacingCharactersInRange:range withString:string];
    if (nowKeyTextFiled == textField) {
        if ([toBeString length] >12) {
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
