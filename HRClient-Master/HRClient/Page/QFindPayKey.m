//
//  QFindPayKey.m
//  HRClient
//
//  Created by ekoo on 14/12/10.
//  Copyright (c) 2014年 panyj. All rights reserved.
//

#import "QFindPayKey.h"
#import "QViewController.h"
#import "QCountDown.h"
#import "QHttpMessageManager.h"
#import "QRegularHelp.h"

@interface QFindPayKey (){
    UITextField *numberTextFiled;
    UIButton *getBtn;
    NSString *code;
    UITextField *inputTextFiled;
    NSString *phoneStr;
//    MBProgressHUD *_HUD;
}

@end

@implementation QFindPayKey

- (void)dealloc{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:kAcquireCode object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:kFindPayPwd object:nil];
}

- (void)pageEvent:(QPageEventType)eventType
{
    if (eventType == kPageEventViewCreate)
    {
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(acquireSuccess:) name:kFindPayPwd object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(acquireFindPayCode:) name:kAcquireCode object:nil];
    }
}

- (QCacheType)pageCacheType
{
    return kCacheTypeNone;
}

- (NSString *)title{
    return @"找回支付密码";
}

- (UIView *)viewWithFrame:(CGRect)frame{
    if ([super viewWithFrame:frame]) {
        _view.backgroundColor = [QTools colorWithRGB:240 :239 :237];
        _view.autoresizesSubviews = YES;
        
        CGFloat beforeW = 15.0;
        CGFloat topH = 25.0;
        CGFloat h = 37.0;
        CGFloat getW = 110;
        getBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        getBtn.frame = CGRectMake(frame.size.width - beforeW - getW, topH+1, getW , h - 2);
        [getBtn setTitle:@"获取验证码" forState:UIControlStateNormal];
        [getBtn setBackgroundImage:[QTools createImageWithColor:ColorTheme] forState:UIControlStateNormal];
        getBtn.titleLabel.font = [UIFont systemFontOfSize:14];
        getBtn.layer.masksToBounds = YES;
        getBtn.layer.cornerRadius = 2.0;
        [getBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [getBtn addTarget:self action:@selector(acquireCode) forControlEvents:UIControlEventTouchUpInside];
        [_view addSubview:getBtn];
        
        CGFloat w = frame.size.width - 2*15;
        CGFloat blank = 10.0;
        numberTextFiled = [[UITextField alloc] initWithFrame:CGRectMake(beforeW, topH, getBtn.deFrameLeft - 20 , h)];
        numberTextFiled.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
        numberTextFiled.clearButtonMode = UITextFieldViewModeWhileEditing;
        numberTextFiled.font = [UIFont systemFontOfSize:14];
        numberTextFiled.borderStyle = UITextBorderStyleRoundedRect;
        numberTextFiled.placeholder = @"请输入手机号";
        numberTextFiled.text = NSString_No_Nil([ASUserDefaults objectForKey:LoginUserPhone]);
        [_view addSubview:numberTextFiled];
        
        inputTextFiled = [[UITextField alloc] initWithFrame:CGRectMake(beforeW, numberTextFiled.deFrameBottom + blank, w , h)];
        inputTextFiled.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
        inputTextFiled.borderStyle = UITextBorderStyleRoundedRect;
        inputTextFiled.clearButtonMode = UITextFieldViewModeWhileEditing;
        inputTextFiled.font = [UIFont systemFontOfSize:14];
        inputTextFiled.placeholder = @"输入验证码";
        [_view addSubview:inputTextFiled];
        
        UIButton *confimeBtn = [[UIButton alloc] initWithFrame:CGRectMake(beforeW, inputTextFiled.deFrameBottom + 2 * blank, w , h)];
        [confimeBtn setBackgroundImage:[QTools createImageWithColor:ColorTheme] forState:UIControlStateNormal];
        [confimeBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [confimeBtn setTitle:@"下一步" forState:UIControlStateNormal];
        confimeBtn.titleLabel.font = [UIFont systemFontOfSize:16];
        confimeBtn.layer.masksToBounds = YES;
        confimeBtn.layer.cornerRadius = 4.0;
        [confimeBtn addTarget:self action:@selector(gotoNext) forControlEvents:UIControlEventTouchUpInside];
        [_view addSubview:confimeBtn];
    }
    return _view;
}

#pragma mark - Action

- (void)gotoNext
{
    if ([numberTextFiled.text isEqualToString:@""]) {
        [ASRequestHUD showErrorWithStatus:@"电话号码输入不能为空"];
    }
    else if ([QRegularHelp validateUserPhone:numberTextFiled.text] == NO) {
        [ASRequestHUD showErrorWithStatus:@"电话号码输入有误"];
    }
    else if ([inputTextFiled.text isEqualToString:@""]){
        [ASRequestHUD showErrorWithStatus:@"验证码不能为空"];
    }
    else{
        [[QHttpMessageManager sharedHttpMessageManager] accessFindePayPwd:numberTextFiled.text andVerifyCode:inputTextFiled.text];
        [ASRequestHUD show];
    }
}

- (void)acquireCode
{
    if ([QRegularHelp validateUserPhone:numberTextFiled.text]) {
        [QCountDown startTime:getBtn];
        [[QHttpMessageManager sharedHttpMessageManager] accessAcquireCode:numberTextFiled.text andMessage:@"(找回支付密码验证码)"];
    }
    else{
        [ASRequestHUD showErrorWithStatus:@"电话号码输入有误"];
    }
}


#pragma mark - Notifiction
- (void)acquireFindPayCode:(NSNotification *)noti{
    
    [ASRequestHUD dismiss];
    code = noti.object;
}

- (void)acquireSuccess:(NSNotification *)noti{
    
    [ASRequestHUD dismiss];
    [QViewController gotoPage:@"QAgainSetPayKey" withParam:nil];
}
@end
