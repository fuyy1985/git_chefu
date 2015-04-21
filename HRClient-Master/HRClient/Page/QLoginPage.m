//
//  QLoginPage.m
//  DSSClient
//
//  Created by pany on 14-4-18.
//  Copyright (c) 2014年 SDK. All rights reserved.
//

#import "QLoginPage.h"
#import "QViewController.h"
#import "XMLParser.h"
#import "DHHudPrecess.h"
#import "QTextField.h"

@interface QLoginPage()
@property (strong,nonatomic)UIView *accAndPwd;
@property (strong,nonatomic)QTextField  *accTextField;
@property (strong,nonatomic)QTextField *pwdTextField;
@property (strong,nonatomic)UIButton *btnLogin;
@end

@implementation QLoginPage

- (QCacheType)pageCacheType
{
    return kCacheTypeCommon;
}

- (QNavigationType)navigationType
{
    return kNavigationTypeNormal;
}

- (NSString*)title
{
    return _T(@"Login");
}

- (UIBarButtonItem*)pageRightMenu
{
    UIButton *button = [QTools createBtnByImage:@"common_title_setting" action:@selector(onBtnConfig:) target:self];
    UIBarButtonItem *item = [[UIBarButtonItem alloc] initWithCustomView:button];
    return item;
}

- (UIView*)viewWithFrame:(CGRect)frame
{
    if ([super viewWithFrame:frame])
    {
        //背景颜色
        _view.backgroundColor = [QTools colorWithRGB:239 :239 :244];
        
        //账户和密码
        _accAndPwd = [[UIView alloc]init];
        [_view addSubview:_accAndPwd];
        
        //用户名图标
        UIImageView *usrImageView = [[UIImageView alloc]initWithImage:IMAGEOF(@"login_body_username_n.png")];
        usrImageView.frame = CGRectMake(20, 5, 33, 33);
        [_accAndPwd addSubview:usrImageView];
        
        UIView *lineView = [[UIView alloc]initWithFrame:CGRectMake(0, 43, 276, 1)];
        lineView.backgroundColor = [QTools colorWithRGB:198 :198 :198];
        [_accAndPwd addSubview:lineView];
        
        _accTextField = [[QTextField alloc] init];
        _accTextField.validLength = 64;
        _accTextField.invalidChars= @"~!@$%^&*=";
        _accTextField.delegate = self;
        _accTextField.placeholder = _T(@"Username");
        _accTextField.returnKeyType = UIReturnKeyNext;
        _accTextField.textColor = [UIColor darkGrayColor];
        _accTextField.textAlignment = NSTextAlignmentLeft;
        _accTextField.keyboardType = UIKeyboardTypeDefault;
        _accTextField.autocapitalizationType = UITextAutocapitalizationTypeNone;
        _accTextField.autocorrectionType = UITextAutocorrectionTypeNo;
        _accTextField.clearButtonMode = UITextFieldViewModeWhileEditing;
        [_accAndPwd addSubview:_accTextField];
        
        //密码图标
        UIImageView *pwdImageView = [[UIImageView alloc]initWithImage:IMAGEOF(@"login_body_password_n.png")];
        pwdImageView.frame = CGRectMake(20, 50, 33, 33);
        [_accAndPwd addSubview:pwdImageView];
        
        _pwdTextField = [[QTextField alloc] init];
        _pwdTextField.validLength = 64;
        _pwdTextField.delegate = self;
        _pwdTextField.placeholder = _T(@"Password");
        _pwdTextField.textAlignment = NSTextAlignmentLeft;
        _pwdTextField.textColor = [UIColor darkGrayColor];
        _pwdTextField.returnKeyType = UIReturnKeyDone;
        _pwdTextField.keyboardType = UIKeyboardTypeDefault;
        _pwdTextField.secureTextEntry = YES;
        _pwdTextField.autocapitalizationType = UITextAutocapitalizationTypeNone;
        _pwdTextField.autocorrectionType = UITextAutocorrectionTypeNo;
        _pwdTextField.clearButtonMode = UITextFieldViewModeWhileEditing;
        [_accAndPwd addSubview:_pwdTextField];
        
        lineView = [[UIView alloc]initWithFrame:CGRectMake(0, 87, 276, 1)];
        lineView.backgroundColor = [QTools colorWithRGB:198 :198 :198];
        [_accAndPwd addSubview:lineView];
        
        //登陆
        _btnLogin = [[UIButton alloc] init];
        _btnLogin.backgroundColor = [QTools colorWithRGB:29 :117 :217];
        [_btnLogin setTitle:_T(@"Login") forState:UIControlStateNormal];
        [_btnLogin setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        
        UIControlEvents state =
        UIControlEventTouchDownRepeat |
        UIControlEventTouchDragOutside |
        UIControlEventTouchUpInside  |
        UIControlEventTouchDragEnter |
        UIControlEventTouchDragExit |
        UIControlEventTouchUpOutside |
        UIControlEventTouchCancel;
        
        [_btnLogin addTarget:self action:@selector(onBtnColorChangeBack) forControlEvents:state];
        [_btnLogin addTarget:self action:@selector(onBtnColorChangeSet) forControlEvents:UIControlEventTouchDown];
        
        [_btnLogin addTarget:self action:@selector(onBtnLogin:)
            forControlEvents:UIControlEventTouchUpInside];
        
        [_view addSubview:_btnLogin];
        [QTools setBtnStyle:_btnLogin cornerRadius:5.0 borderWidth:0 bordercolor:nil];
        
        [self layoutView];
    }
    
    return _view;
}

- (void)layoutView
{
    //账户和密码
    _accTextField.frame = CGRectMake(110, 0, 150, 43);
    _pwdTextField.frame = CGRectMake(110, 44, 150, 43);
    _accAndPwd.frame = CGRectMake(22, 20, 276, 88);
    
    //登陆
    _btnLogin.frame = CGRectMake(50, 160, 220, 34);
}

#pragma mark - Rotate
- (BOOL)pageShouldAutorotate
{
    return YES;
}

- (NSUInteger)pageSupportedInterfaceOrientations
{
    return UIInterfaceOrientationMaskPortrait | UIInterfaceOrientationMaskPortraitUpsideDown;
}

- (void)hideKeyboard
{
    [_accTextField resignFirstResponder];
    [_pwdTextField resignFirstResponder];
}

#pragma mark -
#pragma mark UITextField

- (UIView*)leftViewForTextField:(UIImage*)image
{
    UIImageView *imageView = [[UIImageView alloc] initWithImage:image];
    
    UIView* view = [[UIView alloc] initWithFrame:imageView.bounds];
    [view addSubview:imageView];
    
    return view;
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    if (textField == _accTextField) {
        [_pwdTextField becomeFirstResponder];
    }
    else if (textField == _pwdTextField){
        [_pwdTextField resignFirstResponder];
    }
    return YES;
}

#pragma mark -
#pragma mark button action

- (void)onBtnConfig:(id)sender
{
    [QViewController gotoPage:@"QConfigPage" withParam:nil];
}

- (void)onBtnColorChangeBack
{
    self.btnLogin.backgroundColor = [QTools colorWithRGB:29 :117 :217];
}

- (void)onBtnColorChangeSet
{
    self.btnLogin.backgroundColor = [QTools colorWithRGB:20 :82 :151];
}

- (void)onBtnLogin:(id)sender
{
    //隐藏键盘
    [self hideKeyboard];
    
    [[DHHudPrecess sharedInstance] showWaiting:_T(@"Logging in…")
                                WhileExecuting:@selector(loginPlatform)
                                      onTarget:self
                                    withObject:NULL
                                      animated:YES
                                        atView:PAGEVIEW];
}

- (void)loginPlatform
{
    //跳转到主界面
    [QViewController initAndEnterMain];
    self.btnLogin.backgroundColor = [QTools colorWithRGB:29 :117 :217];
}

@end

