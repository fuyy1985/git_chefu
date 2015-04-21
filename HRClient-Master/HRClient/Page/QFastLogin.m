//
//  QFastLogin.m
//  HRClient
//
//  Created by ekoo on 14/12/15.
//  Copyright (c) 2014年 panyj. All rights reserved.
//

#import "QFastLogin.h"

@implementation QFastLogin

- (NSString *)title{
    return @"选择银行";
}

- (UIView *)viewWithFrame:(CGRect)frame{
    if ([super viewWithFrame:frame]) {
        _view.backgroundColor = [QTools colorWithRGB:240 :239 :237];
        CGFloat viewBeforeW = 20;
        CGFloat viewTopH = 20;
        CGFloat viewW = frame.size.width - 2 * viewBeforeW;
        CGFloat viewH = 37;
        UIView *view = [[UIView alloc] initWithFrame:CGRectMake(viewBeforeW, viewTopH, viewW, viewH)];
//        view.backgroundColor = [UIColor yellowColor];
        [_view addSubview:view];
        
        CGFloat telW = view.frame.size.width - 105 - 10;
        CGFloat telH = 37;
        UITextField *telNumTextFiled = [[UITextField alloc] initWithFrame:CGRectMake(0, 0, telW, telH)];
        telNumTextFiled.placeholder = @"输入手机号";
        telNumTextFiled.borderStyle = UITextBorderStyleRoundedRect;
        telNumTextFiled.layer.borderColor = [QTools colorWithRGB:225 :225 :225].CGColor;
        telNumTextFiled.layer.masksToBounds = YES;
        [view addSubview:telNumTextFiled];
        
        CGFloat getCodeNumBeforeW = telNumTextFiled.deFrameRight + 10;
        CGFloat getCodeNumW = 105;
        CGFloat getCodeNumH = 35;
        UIButton *getCodeNumBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        getCodeNumBtn.frame = CGRectMake(getCodeNumBeforeW, 1, getCodeNumW, getCodeNumH);
        [getCodeNumBtn setTitle:@"获取验证码" forState:UIControlStateNormal];
        [getCodeNumBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        getCodeNumBtn.backgroundColor = [QTools colorWithRGB:181 :0 :7];
        getCodeNumBtn.titleLabel.font = [UIFont boldSystemFontOfSize:16];
        getCodeNumBtn.layer.masksToBounds = YES;
        getCodeNumBtn.layer.cornerRadius = 4.0;
        [view addSubview:getCodeNumBtn];
        
        CGFloat inputCodeBeforeW = 20;
        CGFloat inputCodeTopH = view.deFrameBottom + 15;
        CGFloat inputCodeW = frame.size.width - 2 * inputCodeBeforeW;
        CGFloat inputCodeH = telH;
        UITextField *inputCodeNumTextFiled = [[UITextField alloc] initWithFrame:CGRectMake(inputCodeBeforeW, inputCodeTopH, inputCodeW, inputCodeH)];
        inputCodeNumTextFiled.placeholder = @"输入手机验证码";
        inputCodeNumTextFiled.borderStyle = UITextBorderStyleRoundedRect;
        inputCodeNumTextFiled.layer.borderColor = [QTools colorWithRGB:225 :225 :225].CGColor;
        inputCodeNumTextFiled.layer.masksToBounds = YES;
        [_view addSubview:inputCodeNumTextFiled];
        
        CGFloat loginBeforeW = inputCodeBeforeW;
        CGFloat loginTopH =inputCodeNumTextFiled.deFrameBottom + 30;
        CGFloat loginW = frame.size.width - 2 * loginBeforeW;
        CGFloat loginH = 35;
        UIButton *loginBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        loginBtn.frame = CGRectMake(loginBeforeW, loginTopH, loginW, loginH);
        [loginBtn setTitle:@"获取验证码" forState:UIControlStateNormal];
        [loginBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        loginBtn.backgroundColor = [QTools colorWithRGB:233 :12 :31];
        loginBtn.titleLabel.font = [UIFont boldSystemFontOfSize:20];
        loginBtn.layer.masksToBounds = YES;
        loginBtn.layer.cornerRadius = 4.0;
        [_view addSubview:loginBtn];
    }
    return _view;
}

@end
