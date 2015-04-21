//
//  QAccountLogin.m
//  HRClient
//
//  Created by ekoo on 14/12/11.
//  Copyright (c) 2014年 panyj. All rights reserved.
//

#import "QAccountLogin.h"
#import "QViewController.h"
#import "QHttpMessageManager.h"
#import "QLoginModel.h"
#import "Header.h"
#import "QUser.h"
#import "DES3Util.h"
#import "QMyData.h"
#define kAlphaNum   @"ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789"


@interface QAccountLogin (){
    QLoginModel *loginModel;
    UITextField *accountTextFiled;
    UITextField *keyTextFiled;
}

@property (nonatomic, strong) NSString *nextPage;

@end

@implementation QAccountLogin

- (QCacheType)pageCacheType
{
    return kCacheTypeNone;
}

- (void)setActiveWithParams:(NSDictionary *)params
{
    _nextPage = [params objectForKey:@"NextPage"];
}
- (void)pageEvent:(QPageEventType)eventType
{
    if (eventType == kPageEventWillShow)
    {
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didGetModelFromMessage:) name:kLogin object:nil];
    }
    else if (eventType == kPageEventWillHide)
    {
        [[NSNotificationCenter defaultCenter] removeObserver:self name:kLogin object:nil];
    }
    if (eventType == kPageEventViewCreate)
    {
        
    }
}

- (NSString *)title{
    return @"登录";
}

- (UIView *)viewWithFrame:(CGRect)frame{
    if ([super viewWithFrame:frame]) {
        
        _view.backgroundColor = [QTools colorWithRGB:255 :255 :255];
        CGFloat beforeW = 30.0;
        CGFloat topH = 24.0;
        CGFloat w = frame.size.width - 60;
        CGFloat h = 35.0;
        CGFloat blank = 10.0;
        
        UIImageView *loginImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, frame.size.width, 198)];
        loginImageView.image = [UIImage imageNamed:@"pic_login_head"];
        [_view addSubview:loginImageView];
//        外框
        UILabel *accountLabel = [[UILabel alloc] initWithFrame:CGRectMake(beforeW, loginImageView.frame.size.height + loginImageView.frame.origin.y + topH, w, h)];
        accountLabel.layer.masksToBounds = YES;
        accountLabel.layer.cornerRadius = 4.0;
        accountLabel.layer.borderColor = [QTools colorWithRGB:213 :213 :213].CGColor;
        accountLabel.layer.borderWidth = 1;
        accountLabel.userInteractionEnabled = YES;
//        accountLabel.backgroundColor = [UIColor yellowColor];
        [_view addSubview:accountLabel];
//        icon
        UIImageView *iconImageView = [[UIImageView alloc] initWithFrame:CGRectMake(9, 9, 17, 16)];
        iconImageView.image = [UIImage imageNamed:@"icon_login_name"];
        [accountLabel addSubview:iconImageView];
        
//        竖线
        UILabel *lineLabel = [[UILabel alloc] initWithFrame:CGRectMake(iconImageView.frame.origin.x + iconImageView.frame.size.width +10, iconImageView.frame.origin.y - 1, 1, iconImageView.frame.size.height + 2)];
        lineLabel.backgroundColor = ColorLine;
        [accountLabel addSubview:lineLabel];
        
        accountTextFiled = [[UITextField alloc] initWithFrame:CGRectMake(lineLabel.frame.origin.x + 4, 0, accountLabel.frame.size.width - lineLabel.frame.origin.x - 2, accountLabel.frame.size.height)];
        accountTextFiled.font = [UIFont systemFontOfSize:14];
        accountTextFiled.clearButtonMode = UITextFieldViewModeWhileEditing;
        accountTextFiled.returnKeyType = UIReturnKeyNext;
        accountTextFiled.placeholder = @"手机/用户名";
        accountTextFiled.delegate = self;
        [accountLabel addSubview:accountTextFiled];
        
        
        //        外框,,,输入密码
        UILabel *keyLabel = [[UILabel alloc] initWithFrame:CGRectMake(beforeW, accountLabel.frame.size.height + accountLabel.frame.origin.y + blank, w, h)];
        keyLabel.layer.masksToBounds = YES;
        keyLabel.layer.cornerRadius = 4.0;
        keyLabel.layer.borderColor = [QTools colorWithRGB:213 :213 :213].CGColor;
        keyLabel.layer.borderWidth = 1;
        keyLabel.userInteractionEnabled = YES;
        //        accountLabel.backgroundColor = [UIColor yellowColor];
        [_view addSubview:keyLabel];
        //        icon
        UIImageView *keyImageView = [[UIImageView alloc] initWithFrame:CGRectMake(9, 9, 17, 16)];
        keyImageView.image = [UIImage imageNamed:@"icon_login_pwd"];
        [keyLabel addSubview:keyImageView];
        
        //        竖线
        UILabel *keyLineLabel = [[UILabel alloc] initWithFrame:CGRectMake(keyImageView.frame.origin.x + keyImageView.frame.size.width +10, keyImageView.frame.origin.y - 1, 1, keyImageView.frame.size.height + 2)];
        keyLineLabel.backgroundColor = [QTools colorWithRGB:239 :239 :239];
        [keyLabel addSubview:keyLineLabel];
        
        keyTextFiled = [[UITextField alloc] initWithFrame:CGRectMake(keyLineLabel.frame.origin.x + 4, 0, keyLabel.frame.size.width - keyLineLabel.frame.origin.x - 2, keyLabel.frame.size.height)];
        keyTextFiled.font = [UIFont systemFontOfSize:14];
        keyTextFiled.clearButtonMode = UITextFieldViewModeWhileEditing;
        keyTextFiled.returnKeyType = UIReturnKeyJoin;
        keyTextFiled.placeholder = @"输入您的密码";
        keyTextFiled.secureTextEntry = YES;
        keyTextFiled.delegate = self;
        [keyLabel addSubview:keyTextFiled];
        
        UIButton *loginBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        loginBtn.frame = CGRectMake(beforeW, keyLabel.frame.origin.y + keyLabel.frame.size.height + 0.5*topH, (keyLabel.frame.size.width - blank)/2, h);
        [loginBtn setTitle:@"登录" forState:UIControlStateNormal];
        [loginBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [loginBtn setBackgroundImage:[QTools createImageWithColor:ColorTheme] forState:UIControlStateNormal];
        loginBtn.layer.masksToBounds = YES;
        loginBtn.layer.cornerRadius = 4.0;
        loginBtn.titleLabel.font = [UIFont systemFontOfSize:14];
        [loginBtn addTarget:self action:@selector(loginToAccount) forControlEvents:UIControlEventTouchUpInside];
        [_view addSubview:loginBtn];
        
        UIButton *speedBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        speedBtn.frame = CGRectMake(loginBtn.frame.origin.x + loginBtn.frame.size.width + blank, keyLabel.frame.origin.y + keyLabel.frame.size.height + 0.5*topH, (keyLabel.frame.size.width - blank)/2, h);
        [speedBtn setTitle:@"无帐号快捷登录" forState:UIControlStateNormal];
        [speedBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [speedBtn setBackgroundImage:[QTools createImageWithColor:[QTools colorWithRGB:244 :80 :25]] forState:UIControlStateNormal];
        speedBtn.layer.masksToBounds = YES;
        speedBtn.layer.cornerRadius = 4.0;
        [speedBtn addTarget:self action:@selector(gotoSpeedLogin) forControlEvents:UIControlEventTouchUpInside];
        speedBtn.titleLabel.font = [UIFont systemFontOfSize:14];
        [_view addSubview:speedBtn];
        
    
        CGFloat lineW = 0.3*frame.size.width;
        CGFloat lineTop = 42;
        
        UILabel *leftLabal = [[UILabel alloc] initWithFrame:CGRectMake(0, loginBtn.frame.origin.y + loginBtn.frame.size.height + lineTop, lineW, 0.5f)];
        leftLabal.backgroundColor = [QTools colorWithRGB:223 :223 :223];
        [_view addSubview:leftLabal];
        
        UIButton *accountRegisterBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        accountRegisterBtn.frame = CGRectMake(leftLabal.frame.origin.x + leftLabal.frame.size.width, leftLabal.frame.origin.y - 13, frame.size.width/2 - leftLabal.frame.size.width, 26);
        [accountRegisterBtn setTitle:@"用户注册" forState:UIControlStateNormal];
        [accountRegisterBtn setTitleColor:ColorTheme forState:UIControlStateNormal];
        accountRegisterBtn.titleLabel.font = [UIFont systemFontOfSize:12];
        [accountRegisterBtn addTarget:self action:@selector(gotoAccountRegister) forControlEvents:UIControlEventTouchUpInside];
        [_view addSubview:accountRegisterBtn];
        
        UILabel *erectLabel = [[UILabel alloc] initWithFrame:CGRectMake(frame.size.width/2, leftLabal.frame.origin.y - 8, 0.5f, 26/2)];
        erectLabel.backgroundColor = ColorLine;
        [_view addSubview:erectLabel];
        
        UIButton *forgetBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        forgetBtn.frame = CGRectMake(frame.size.width - leftLabal.frame.size.width - accountRegisterBtn.frame.size.width, leftLabal.frame.origin.y - 13, frame.size.width/2 - leftLabal.frame.size.width, 26);
        [forgetBtn setTitle:@"忘记密码" forState:UIControlStateNormal];
        [forgetBtn setTitleColor:ColorTheme forState:UIControlStateNormal];
        forgetBtn.titleLabel.font = [UIFont systemFontOfSize:12];
        [forgetBtn addTarget:self action:@selector(gotoFindeKey) forControlEvents:UIControlEventTouchUpInside];
        [_view addSubview:forgetBtn];
        
        UILabel *rightLabel = [[UILabel alloc] initWithFrame:CGRectMake(frame.size.width - lineW, loginBtn.frame.origin.y + loginBtn.frame.size.height + lineTop, lineW, 0.5f)];
        rightLabel.backgroundColor = ColorLine;
        [_view addSubview:rightLabel];
        
    }
    return _view;
}
/**
    登录成功
 */
- (void)didGetModelFromMessage:(NSNotification *)noti{
    
    [ASRequestHUD dismiss];
    
    loginModel = noti.object;
    if (!loginModel) {
        [QViewController showMessage:@"登录失败"];
    }
    else{
        [QUser sharedQUser].isLogin = YES;
        [loginModel savetoLocal:keyTextFiled.text];
        if (_nextPage) {
            [QViewController gotoPage:_nextPage withParam:nil];
        }
        else {
            [QViewController backPageWithParam:nil];
        }
    }
}

- (void)gotoSpeedLogin{
    [QViewController gotoPage:@"QNoAccountLogin" withParam:nil];
}

- (void)gotoAccountRegister{
    [QViewController gotoPage:@"QRegister" withParam:nil];
}

- (void)gotoFindeKey{
    [QViewController gotoPage:@"QFindLoginKey" withParam:nil];
}

- (void)loginToAccount{
    [keyTextFiled resignFirstResponder];
    [accountTextFiled resignFirstResponder];
    
    if ([accountTextFiled.text isEqualToString:@""]) {
        [ASRequestHUD showErrorWithStatus:@"用户名不能为空"];
    }else if ([keyTextFiled.text isEqualToString:@""]){
        [ASRequestHUD showErrorWithStatus:@"登录密码不能为空"];
    } else if ([keyTextFiled.text length] < 6 || [keyTextFiled.text length] > 12) {
        [ASRequestHUD showErrorWithStatus:@"请输入6-12英文或者数字"];
    }
    else{
        [[QHttpMessageManager sharedHttpMessageManager] accessLogin:accountTextFiled.text andPassword:keyTextFiled.text];
        [ASRequestHUD show];
    }
}

#pragma mark - UITexFieldDelegate
- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
    if ([string isEqualToString:@"\n"])
    {
        if ([textField isEqual:accountTextFiled]) {
            [keyTextFiled becomeFirstResponder];
        }
        else if([textField isEqual:keyTextFiled]) {
            [self loginToAccount];
        }
        return NO;
    }
    NSString *toBeString = [textField.text stringByReplacingCharactersInRange:range withString:string];
    if (keyTextFiled == textField && [toBeString length] > 12) {
        [ASRequestHUD showErrorWithStatus:@"请输入6-12英文或者数字"];
        return NO;
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

