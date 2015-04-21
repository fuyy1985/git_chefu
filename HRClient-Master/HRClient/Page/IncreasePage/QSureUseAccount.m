//
//  QSureUseAccount.m
//  HRClient
//
//  Created by ekoo on 14/12/26.
//  Copyright (c) 2014年 panyj. All rights reserved.
//

#import "QSureUseAccount.h"

@implementation QSureUseAccount

- (NSString *)title{
    return @"支付密码";
}

- (UIView *)viewWithFrame:(CGRect)frame{
    if ([super viewWithFrame:frame]) {
        UILabel *keyLabel = [[UILabel alloc] initWithFrame:CGRectMake(15, 21, 80, 38)];
        keyLabel.text = @"支付密码";
        keyLabel.backgroundColor = UIColorFromRGB(0xc40000);
        keyLabel.layer.masksToBounds = YES;
        keyLabel.layer.cornerRadius = 3.0;
        keyLabel.textColor = [QTools colorWithRGB:255 :255 :255];
        keyLabel.textAlignment = NSTextAlignmentCenter;
        [_view addSubview:keyLabel];
        
        UITextField *keyTextField = [[UITextField alloc] initWithFrame:CGRectMake(keyLabel.deFrameRight + 10, 20, frame.size.width - 2 * 15 - keyLabel.deFrameRight, 40)];
        keyTextField.placeholder = @"请输入支付密码";
        keyTextField.borderStyle = UITextBorderStyleRoundedRect;
        [_view addSubview:keyTextField];
        
        UIButton *sureBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        sureBtn.frame = CGRectMake(15, keyLabel.deFrameBottom + 20, frame.size.width - 2 * 15, 40);
        [sureBtn setTitle:@"确认支付" forState:UIControlStateNormal];
        sureBtn.backgroundColor = UIColorFromRGB(0xc40000);
        sureBtn.layer.masksToBounds = YES;
        sureBtn.layer.cornerRadius = 4.0;
        [_view addSubview:sureBtn];
    }
    return _view;
}

@end
