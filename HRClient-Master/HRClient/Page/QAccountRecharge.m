//
//  QAccountRecharge.m
//  HRClient
//
//  Created by ekoo on 14/12/12.
//  Copyright (c) 2014年 panyj. All rights reserved.
//

#import "QAccountRecharge.h"
#import "QViewController.h"
#import "QVIPCardChong.h"


@interface QAccountRecharge ()
{
    NSArray *moneyArr;
    UITextField *inputTextFiled;
    NSMutableDictionary *dic;
}

@property (nonatomic, strong) UIButton *btnSure;

@end

@implementation QAccountRecharge

- (NSString *)title
{
    return @"账户充值";
}

- (QCacheType)pageCacheType
{
    return kCacheTypeNone;
}

- (UIView *)viewWithFrame:(CGRect)frame
{
    if ([super viewWithFrame:frame]) {
        _view.backgroundColor = [QTools colorWithRGB:240 :239 :237];
        dic = [[NSMutableDictionary alloc] init];
        moneyArr = [[NSArray alloc] initWithObjects:@"100",@"200",@"300",@"500",@"1000",@"2000", nil];
        CGFloat topH = 20;
        CGFloat blankW = 20;
        CGFloat moneyH = 35;
        for (int i = 0; i < 3; i ++)
        {
            for (int j = 0; j < 2;j ++)
            {
                UIButton *moneyBtn = [UIButton buttonWithType:UIButtonTypeCustom];
                moneyBtn.frame = CGRectMake(blankW + ((frame.size.width - 2 * blankW - topH)/2 + topH)*j, topH + (moneyH + topH)*i, (frame.size.width - 2 * blankW - topH)/2, moneyH);
                [moneyBtn setTitle:moneyArr[2*i +j] forState:UIControlStateNormal];
                [moneyBtn setTitleColor:ColorDarkGray forState:UIControlStateNormal];
                [moneyBtn setBackgroundImage:[QTools createImageWithColor:[UIColor whiteColor]] forState:UIControlStateNormal];
                moneyBtn.tag = 100 + (2 * i +j);
                [moneyBtn addTarget:self action:@selector(gotoVipRecharge:) forControlEvents:UIControlEventTouchUpInside];
                [_view addSubview:moneyBtn];
                
                moneyBtn.layer.borderWidth = .5f;
                moneyBtn.layer.borderColor = ColorLine.CGColor;
                moneyBtn.layer.masksToBounds = YES;
            }
        }
        
        CGFloat otherW = 80;
        CGFloat otherH = 35;
        UILabel *otherLabel = [[UILabel alloc] initWithFrame:CGRectMake(blankW, 3 * topH + 3 * moneyH + 20, otherW, otherH)];
        otherLabel.backgroundColor = [UIColor clearColor];
        otherLabel.text = @"其他金额";
        otherLabel.textColor = ColorTheme;
        otherLabel.font = [UIFont boldSystemFontOfSize:16];
        [_view addSubview:otherLabel];
        
        CGFloat inputW = frame.size.width - 2 * blankW - otherLabel.frame.size.width - blankW + topH;
        CGFloat inputH = 35;
        inputTextFiled = [[UITextField alloc] initWithFrame:CGRectMake(otherLabel.deFrameRight + 5, otherLabel.frame.origin.y, inputW, inputH)];
        inputTextFiled.backgroundColor = [QTools colorWithRGB:255 :255 :255];
        inputTextFiled.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
        inputTextFiled.layer.masksToBounds = YES;
        inputTextFiled.borderStyle = UITextBorderStyleRoundedRect;
        inputTextFiled.placeholder = @"请输入要充值的金额";
        inputTextFiled.font = [UIFont systemFontOfSize:14];
        inputTextFiled.keyboardType = UIKeyboardTypeDefault;
        [_view addSubview:inputTextFiled];
        [inputTextFiled addTarget:self action:@selector(textFieldDidChanged:) forControlEvents:UIControlEventEditingChanged];
        
        CGFloat sureW = frame.size.width - 2*blankW;
        CGFloat sureH = 35;
        CGFloat sureTopH = otherLabel.deFrameBottom + 20;
        UIButton *sureBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        sureBtn.frame = CGRectMake(blankW,sureTopH , sureW, sureH);
        [sureBtn setTitle:@"确认充值" forState:UIControlStateNormal];
        [sureBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        sureBtn.titleLabel.font = [UIFont systemFontOfSize:16];
        [sureBtn setBackgroundImage:[QTools createImageWithColor:ColorTheme] forState:UIControlStateNormal];
        sureBtn.layer.masksToBounds = YES;
        sureBtn.layer.cornerRadius = 4.0;
        sureBtn.enabled = NO;
        [sureBtn addTarget:self action:@selector(gotoVipRecharge1:) forControlEvents:UIControlEventTouchUpInside];
        [_view addSubview:sureBtn];
        
        _btnSure = sureBtn;
    }
    return  _view;
}

- (void)gotoVipRecharge:(UIButton *)sender
{
    dic = [NSMutableDictionary dictionary];

    [dic setValue:moneyArr[sender.tag - 100] forKey:@"noramlAccAmount"];
    [dic setValue:[NSNumber numberWithInteger:3] forKey:@"buy_type"];
    
    [QViewController gotoPage:@"QVIPCardChong" withParam:dic];
}

- (void)gotoVipRecharge1:(UIButton *)sender
{
    dic = [NSMutableDictionary dictionary];
    
    [dic setValue:inputTextFiled.text forKey:@"noramlAccAmount"];
    [dic setValue:[NSNumber numberWithInteger:3] forKey:@"buy_type"];
    
    [QViewController gotoPage:@"QVIPCardChong" withParam:dic];
}

- (void)textFieldDidChanged:(id)sender
{
    _btnSure.enabled = ([inputTextFiled.text isEqualToString:@""]) ? NO : YES;
}

@end
