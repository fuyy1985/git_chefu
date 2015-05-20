//
//  QNoAccountLogin.m
//  HRClient
//
//  Created by ekoo on 14/12/18.
//  Copyright (c) 2014年 panyj. All rights reserved.
//

#import "QNoAccountLogin.h"
#import "QHttpMessageManager.h"
#import "QCountDown.h"
#import "QViewController.h"
#import "QRegularHelp.h"
#import "QCardDetailModel.h"

@interface QNoAccountLogin (){
    NSString *success;
    UITextField *codeTextFiled;
    UIButton *acquireBtn;
    UITextField *inputNewTel;
    BuyType buyType;
    QCardDetailModel *vipModel;
}

@end

@implementation QNoAccountLogin

- (void)dealloc{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:kAcquireCode object:nil];
}

- (QCacheType)pageCacheType //NOTE:页面缓存方式
{
    return kCacheTypeNone;
}

- (void)setActiveWithParams:(NSDictionary*)params
{
    buyType = [[params objectForKey:@"buy_type"] integerValue];
    
    switch (buyType) {
        case BuyType_directly:
            //nothing
            break;
            
        case BuyType_vipCard:
            vipModel = [params objectForKey:@"cardModel"];
            break;
            
        case BuyType_vipCardCharge:
            
            break;
            
        case BuyType_normalCharge:
            
            break;
            
        default:
            break;
    }
}

- (NSString *)title{
    return @"无账号快捷登录";
}

- (void)pageEvent:(QPageEventType)eventType
{
    if (eventType == kPageEventWillShow)
    {
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didGetModelFromMessage:) name:kAcquireCode object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(quickLoginSucess:) name:kFindLoginPwd object:nil];
    }
    else if (eventType == kPageEventWillHide)
    {
        [[NSNotificationCenter defaultCenter] removeObserver:self name:kFindLoginPwd object:nil];
        [[NSNotificationCenter defaultCenter] removeObserver:self name:kAcquireCode object:nil];
    }
}

- (UIView *)viewWithFrame:(CGRect)frame{
    if ([super viewWithFrame:frame]) {
        _view.backgroundColor = [QTools colorWithRGB:240 :239 :237];
        
        CGFloat beforeW = 15.0;
        CGFloat topH = 25.0;
        CGFloat h = 35.0;
        codeTextFiled = [[UITextField alloc] initWithFrame:CGRectMake(beforeW, topH, 160, h)];
        codeTextFiled.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
        codeTextFiled.font = [UIFont systemFontOfSize:14];
        codeTextFiled.placeholder = @"输入手机号";
        codeTextFiled.borderStyle = UITextBorderStyleRoundedRect;
        codeTextFiled.clearButtonMode = UITextFieldViewModeWhileEditing;
        codeTextFiled.keyboardType = UIKeyboardTypePhonePad;
        [_view addSubview:codeTextFiled];
        
        acquireBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        acquireBtn.frame = CGRectMake(codeTextFiled.deFrameRight + 10, topH + 1, frame.size.width - 2 * beforeW - codeTextFiled.frame.size.width - 5, h - 2);
        [acquireBtn setTitle:@"获取验证码" forState:UIControlStateNormal];
        [acquireBtn setBackgroundImage:[QTools createImageWithColor:ColorTheme] forState:UIControlStateNormal];
        [acquireBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        acquireBtn.layer.masksToBounds = YES;
        acquireBtn.layer.cornerRadius = 2.0;
        acquireBtn.titleLabel.font = [UIFont systemFontOfSize:14];
        [acquireBtn addTarget:self action:@selector(acquireCode) forControlEvents:UIControlEventTouchUpInside];
        [_view addSubview:acquireBtn];
        
        inputNewTel = [[UITextField alloc] initWithFrame:CGRectMake(beforeW, codeTextFiled.deFrameBottom + 15, frame.size.width - 2 * 15.0, h)];
        inputNewTel.font = [UIFont systemFontOfSize:14];
        inputNewTel.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
        inputNewTel.placeholder = @"输入手机验证码";
        inputNewTel.borderStyle = UITextBorderStyleRoundedRect;
        inputNewTel.clearButtonMode = UITextFieldViewModeWhileEditing;
        codeTextFiled.keyboardType = UIKeyboardTypeNumberPad;
        [_view addSubview:inputNewTel];
        
        UIButton *sureChangeBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        sureChangeBtn.frame = CGRectMake(beforeW, inputNewTel.deFrameBottom + 15, frame.size.width - 2 * beforeW, h);
        [sureChangeBtn setTitle:@"验证并登录" forState:UIControlStateNormal];
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

- (void)gotoNewTel{
    
    if ([QRegularHelp validateUserPhone:codeTextFiled.text] == NO) {
        [ASRequestHUD showErrorWithStatus:@"电话号码输入有误"];
    }
    else if ([inputNewTel.text isEqualToString:@""]){
        [ASRequestHUD showErrorWithStatus:@"验证码不能为空"];
    }
    else{
        [[QHttpMessageManager sharedHttpMessageManager] accessFindLoginPwd:codeTextFiled.text andVerifyCode:inputNewTel.text];
        [ASRequestHUD show];
    }
}

- (void)acquireCode{
    
    if ([QRegularHelp validateUserPhone:codeTextFiled.text]) {
        [QCountDown startTime:acquireBtn];
        [[QHttpMessageManager sharedHttpMessageManager] accessAcquireCode:codeTextFiled.text andMessage:@"(手机注册验证码)"];
        [ASRequestHUD show];
    }
    else{
        [ASRequestHUD showErrorWithStatus:@"电话号码输入有误"];
    }
}

- (void)didGetModelFromMessage:(NSNotification *)noti{
    
    [ASRequestHUD dismiss];
    success = noti.object;
}

- (void)quickLoginSucess:(NSNotification*)noti {
    
    [ASRequestHUD dismiss];
    
    //登录完成
    QLoginModel *model = noti.object;
    if (!model) {
        [QViewController showMessage:@"登录失败"];
    }
    else
    {
        [QUser sharedQUser].isLogin = YES;
        
        switch (buyType) {
            case BuyType_directly:
            {
                [model savetoLocal:@""];
                [QViewController gotoPage:@"QMyPage" withParam:nil];
            }
                break;
                
            case BuyType_vipCard:
            {
                if ([model.member integerValue])
                {
                    [QViewController gotoPage:@"QMyVIPCard" withParam:nil];
                }
                else
                {
                    [QViewController gotoPage:@"QVIPCardChong" withParam:[[NSDictionary alloc]
                                                                          initWithObjectsAndKeys:vipModel, @"cardModel",
                                                                          [NSNumber numberWithInteger:buyType],@"buy_type", nil]];
                }
            }
                break;
                
            case BuyType_vipCardCharge:
                
                break;
                
            case BuyType_normalCharge:
                
                break;
                
            default:
                break;
        }
        
        [[QUser sharedQUser]updateUserInfo]; //更新账户信息
    }
}

@end
