//
//  QHSearchBar.m
//  HRClient
//
//  Created by ekoo on 14/12/31.
//  Copyright (c) 2014年 panyj. All rights reserved.
//

#import "QHSearchBar.h"

@implementation QHSearchBar


- (id)initWithFrame:(CGRect)frame{
    self = [super initWithFrame:frame];
    if (self) {
        UIColor *color = [QTools colorWithRGB:86 :86 :86];
        [self changeBarTextFieldWithColor:color bgImageName:nil];
        [self changeBarCancelButtonWithColor:UIColorFromRGB(0xc40000) bgImageName:nil];
    }
    return self;
}

- (void)changeBarTextFieldWithColor:(UIColor *)color bgImageName:(NSString *)bgImageName{
    self.tintColor = color;
    UITextField *textField;
    if (IOSVERSION > 6.1f) {
        for (UIView *view in self.subviews) {
            if ([view isKindOfClass:NSClassFromString(@"UISearchBarTextField")]) {
                textField = (UITextField *)view;
                textField.layer.borderWidth = 1.0;
                textField.layer.cornerRadius = 6.0;
                textField.layer.borderColor = color.CGColor;
                break;
            }
        }
    }else{
        for (UITextField *subv in self.subviews) {
            if ([subv isKindOfClass:[UITextField class]]) {
                textField  =(UITextField *)subv;
                break;
            }
        }
    
    }
    
//    设置文本框背景
    NSArray *subs = self.subviews;
    if (IOSVERSION > 6.1f) {
        for (int i = 0; i < [subs count]; i ++) {
            UIView *subv = (UIView *)[self.subviews objectAtIndex:i];
            for (UIView *subview in subv.subviews) {
                if ([subview isKindOfClass:NSClassFromString(@"UISearchBarBackground")]) {
                    [subview setHidden:YES];
                    [subview removeFromSuperview];
                    break;
                }
            }
        }
    }else{
        for (int i = 0; i < [subs count]; i ++) {
            UIView *subv = (UIView *)[self.subviews objectAtIndex:i];
            if ([subv isKindOfClass:NSClassFromString(@"UISearchBarBackground")]) {
                [subv removeFromSuperview];
                break;
            }
        }
    }
//    UIImage *searchBarBgImage = [commonm]
    
}

- (void)changeBarCancelButtonWithColor:(UIColor *)textColor bgImageName:(NSString *)bgImageName{
    for (UIView *searchbuttons in self.subviews)
    {
        
        if ([searchbuttons isKindOfClass:[UIButton class]]) // ios7以下
        {
            UIButton *cancelButton = (UIButton*)searchbuttons;
            cancelButton.enabled = YES;
            [cancelButton setTitleColor:textColor forState:UIControlStateNormal];
            [cancelButton setTitleColor:textColor forState:UIControlStateSelected];
            if (bgImageName)
            {
                [cancelButton setBackgroundImage:[UIImage imageNamed:bgImageName] forState:UIControlStateNormal];
                [cancelButton setBackgroundImage:[UIImage imageNamed:bgImageName] forState:UIControlStateSelected];
            }
            break;
        }
    }
}


@end
