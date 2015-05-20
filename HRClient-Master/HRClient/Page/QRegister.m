//
//  QRegister.m
//  HRClient
//
//  Created by ekoo on 14/12/12.
//  Copyright (c) 2014年 panyj. All rights reserved.
//

#import "QRegister.h"
#import "QHttpMessageManager.h"
#import "QRegisterModel.h"
#import "QRegularHelp.h"
#import "QCountDown.h"
#import "DES3Util.h"
#import "QViewController.h"

#define kAlphaNum   @"ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789"

@interface QRegister (){
    UITextField *accountTextFiled;
    UIButton *getNumberBtn;
    UITextField *numberTextFiled;
    UITextField *inputKeyTextFiled;
    UITextField *sureTextFiled;
    UIButton *submitBtn;
    NSString *message;
}

@end

@implementation QRegister

- (void)pageEvent:(QPageEventType)eventType
{
    if (eventType == kPageEventViewCreate)
    {
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(acquireRegisterInfo:) name:kRegister object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(acquireCode:) name:kAcquireCode object:nil];
    }
    else if (eventType == kPageEventViewDispose)
    {
        [[NSNotificationCenter defaultCenter] removeObserver:self name:kRegister object:nil];
        [[NSNotificationCenter defaultCenter] removeObserver:self name:kAcquireCode object:nil];
    }
}


- (NSString *)title{
    return @"注册";
}

- (UIView *)viewWithFrame:(CGRect)frame{
    if ([super viewWithFrame:frame]) {
        _view.backgroundColor = [QTools colorWithRGB:240 :239 :237];
        CGFloat blankW = 30;
        CGFloat topH = 10;
        CGFloat w = frame.size.width - 2 * blankW;
        CGFloat h = 35;
        accountTextFiled = [[UITextField alloc] initWithFrame:CGRectMake(blankW, 20, w, h)];
        accountTextFiled.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
        accountTextFiled.placeholder = @"输入11位手机号";
        accountTextFiled.borderStyle = UITextBorderStyleRoundedRect;
        accountTextFiled.font = [UIFont systemFontOfSize:14];
        accountTextFiled.clearButtonMode = UITextFieldViewModeWhileEditing;
        //accountTextFiled.keyboardType = UIKeyboardTypeNumberPad;
        accountTextFiled.tag = 100;
        [_view addSubview:accountTextFiled];
        
        getNumberBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        getNumberBtn.frame = CGRectMake(blankW, accountTextFiled.frame.origin.y + accountTextFiled.frame.size.height + topH, w, h - 5);
        [getNumberBtn setTitle:@"获取验证码" forState:UIControlStateNormal];
        [getNumberBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [getNumberBtn setBackgroundImage:[QTools createImageWithColor:UIColorFromRGB(0xc40000)] forState:UIControlStateNormal];
        getNumberBtn.layer.masksToBounds = YES;
        getNumberBtn.layer.cornerRadius = 2.0;
        getNumberBtn.titleLabel.font = [UIFont systemFontOfSize:14];
        [getNumberBtn addTarget:self action:@selector(gotoAcquireCode) forControlEvents:UIControlEventTouchUpInside];
        [_view addSubview:getNumberBtn];
        
        numberTextFiled = [[UITextField alloc] initWithFrame:CGRectMake(blankW, getNumberBtn.frame.origin.y + getNumberBtn.frame.size.height + topH, w, h)];
        numberTextFiled.font = [UIFont systemFontOfSize:14];
        numberTextFiled.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
        numberTextFiled.placeholder = @"输入验证码";
        numberTextFiled.borderStyle = UITextBorderStyleRoundedRect;
        numberTextFiled.clearButtonMode = UITextFieldViewModeWhileEditing;
        [_view addSubview:numberTextFiled];
        
        inputKeyTextFiled = [[UITextField alloc] initWithFrame:CGRectMake(blankW, numberTextFiled.frame.origin.y + numberTextFiled.frame.size.height + topH, w, h)];
        inputKeyTextFiled.font = [UIFont systemFontOfSize:14];
        inputKeyTextFiled.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
        inputKeyTextFiled.placeholder = @"输入密码（6-12位）";
        inputKeyTextFiled.borderStyle = UITextBorderStyleRoundedRect;
        inputKeyTextFiled.clearButtonMode = UITextFieldViewModeWhileEditing;
        inputKeyTextFiled.delegate = self;
        inputKeyTextFiled.secureTextEntry = YES;
        [_view addSubview:inputKeyTextFiled];
        
        sureTextFiled = [[UITextField alloc] initWithFrame:CGRectMake(blankW, inputKeyTextFiled.frame.origin.y + inputKeyTextFiled.frame.size.height + topH, w, h)];
        sureTextFiled.font = [UIFont systemFontOfSize:14];
        sureTextFiled.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
        sureTextFiled.placeholder = @"确认密码";
        sureTextFiled.borderStyle = UITextBorderStyleRoundedRect;
        sureTextFiled.clearButtonMode = UITextFieldViewModeWhileEditing;
        sureTextFiled.secureTextEntry = YES;
        [_view addSubview:sureTextFiled];
        
        
        submitBtn = [[UIButton alloc] initWithFrame:CGRectMake(blankW, sureTextFiled.frame.origin.y + sureTextFiled.frame.size.height + blankW + 5, w, h + 5)];
        [submitBtn setTitle:@"注册并登录" forState:UIControlStateNormal];
        [submitBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [submitBtn setBackgroundImage:[QTools createImageWithColor:UIColorFromRGB(0xc40000)] forState:UIControlStateNormal];
        submitBtn.layer.masksToBounds = YES;
        submitBtn.layer.cornerRadius = 4.0;
        submitBtn.titleLabel.font = [UIFont systemFontOfSize:14];
        [submitBtn addTarget:self action:@selector(registerAndLogin) forControlEvents:UIControlEventTouchUpInside];
        [_view addSubview:submitBtn];
        
        UIButton *button = [[UIButton alloc] initWithFrame:CGRectMake(blankW, submitBtn.frame.origin.y + submitBtn.frame.size.height + blankW, 20, 20)];
        button.selected = YES;
        [button setImage:[UIImage imageNamed:@"icon_agree_unselected"] forState:UIControlStateNormal];
        [button setImage:[UIImage imageNamed:@"icon_agree_selected"] forState:UIControlStateSelected];
        [button addTarget:self action:@selector(onAgree:) forControlEvents:UIControlEventTouchUpInside];
        [_view addSubview:button];
        
        UILabel *instrcutLabel = [[UILabel alloc] initWithFrame:CGRectMake(button.deFrameRight  + 10, submitBtn.frame.origin.y + submitBtn.frame.size.height + blankW, frame.size.width - button.deFrameRight - 10 - blankW + 20 , 20)];
        instrcutLabel.font = [UIFont systemFontOfSize:12];
        instrcutLabel.textColor = [QTools colorWithRGB:80 :80 :80];
        instrcutLabel.backgroundColor = [UIColor clearColor];
        //属性文字
        NSString *text = @"我已阅读并同意车夫用户使用协议";
        NSMutableAttributedString *string = [[NSMutableAttributedString alloc] initWithString:text attributes:@{NSStrikethroughStyleAttributeName: @(NSUnderlineStyleNone)}];
        [string addAttributes:@{NSUnderlineStyleAttributeName:@(NSLineBreakByClipping)} range:[text rangeOfString:@"用户使用协议"]];
        [string addAttribute:NSForegroundColorAttributeName value:ColorTheme range:[text rangeOfString:@"用户使用协议"]];
        instrcutLabel.attributedText = string;
        
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(onAgreementView)];
        [instrcutLabel addGestureRecognizer:tap];
        instrcutLabel.userInteractionEnabled = YES;
        
        [_view addSubview:instrcutLabel];
    }
    return _view;
}

#pragma mark - Action

- (void)onAgree:(id)sender
{
    UIButton *button = (UIButton*)sender;
    button.selected = !button.selected;
    submitBtn.enabled = button.selected;
}

- (void)onAgreementView
{
    [QViewController gotoPage:@"QAgreementPage" withParam:[[NSDictionary alloc] initWithObjectsAndKeys:[NSNumber numberWithInt:1], @"agreementType", nil]];
}

#pragma mark - Notification
- (void)acquireCode:(NSNotification *)noti{
    message = noti.object;
    
    NSLog(@"%@",message);
}

//成功回调
- (void)acquireRegisterInfo:(NSNotification *)noti
{
    [ASRequestHUD dismiss];
    
    QRegisterModel *dataArr = noti.object;
    [self saveRegisterInfro:dataArr];
    
    [QViewController gotoPage:@"QMyPage" withParam:nil];
}
//存储信息
- (void)saveRegisterInfro:(QRegisterModel *)data{
    NSUserDefaults *usrDefault = [NSUserDefaults standardUserDefaults];
//    密码加密
    NSString *password = [DES3Util encrypt:data.password];
    [usrDefault setObject:data.balance forKey:@"balance"];
    [usrDefault setObject:data.ticket forKey:@"ticket"];
    [usrDefault setObject:data.userId forKey:@"userId"];
    [usrDefault setObject:data.realName forKey:@"realName"];
    [usrDefault setObject:data.nick forKey:@"nick"];
    [usrDefault setObject:data.mail forKey:@"mail"];
    [usrDefault setObject:data.phone forKey:@"phone"];
    [usrDefault setObject:password forKey:@"password"];
    [usrDefault setObject:data.payPasswd forKey:@"payPasswd"];
    [usrDefault setObject:data.gmtCreate forKey:@"gmtCreate"];
    [usrDefault setObject:data.gmtModified forKey:@"gmtModified"];
    [usrDefault setObject:data.createUser forKey:@"createUser"];
    [usrDefault setObject:data.modifiedUser forKey:@"modifiedUser"];
    [usrDefault setObject:data.status forKey:@"status"];
    [usrDefault setObject:data.photoPath forKey:@"photoPath"];
    [usrDefault setObject:data.member forKey:@"member"];
    [usrDefault synchronize];
}

- (void)gotoAcquireCode{
    if ([QRegularHelp validateUserPhone:accountTextFiled.text]) {
        [QCountDown startTime:getNumberBtn];
        [[QHttpMessageManager sharedHttpMessageManager] accessAcquireCode:accountTextFiled.text andMessage:@"(手机注册验证码)"];
    }else{
        [ASRequestHUD showErrorWithStatus:@"电话号码输入有误"];
    }
}

- (void)registerAndLogin{
    if ([inputKeyTextFiled.text length] < 6) {
        [ASRequestHUD showErrorWithStatus:@"请输入6-12英文或者数字"];
        return ;
    }
    if ([inputKeyTextFiled.text isEqualToString:sureTextFiled.text]) {
        [[QHttpMessageManager sharedHttpMessageManager] accessRegister:accountTextFiled.text andVerifyCode:numberTextFiled.text andPassword:inputKeyTextFiled.text andVerifyPassword:sureTextFiled.text];
        [ASRequestHUD show];
    }else{
        [ASRequestHUD showErrorWithStatus:@"新密码两次输入不一致"];
    }
}

//textField的限制
- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string{
    if ([string isEqualToString:@"\n"]) {
        return NO;
    }
    NSString *toBeString = [textField.text stringByReplacingCharactersInRange:range withString:string];
    if (inputKeyTextFiled == textField) {
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
