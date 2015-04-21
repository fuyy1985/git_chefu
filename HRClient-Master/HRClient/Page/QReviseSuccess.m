//
//  QReviseSuccess.m
//  HRClient
//
//  Created by ekoo on 14/12/12.
//  Copyright (c) 2014年 panyj. All rights reserved.
//

#import "QReviseSuccess.h"

@implementation QReviseSuccess

- (NSString *)title{
    return @"修改成功";
}

- (UIView *)viewWithFrame:(CGRect)frame{
    if ([super viewWithFrame:frame]) {
        _view.backgroundColor = [QTools colorWithRGB:240 :239 :237];
        UIView *view1 = [[UIView alloc] initWithFrame:CGRectMake(15, 30, frame.size.width - 30, 115)];
        view1.backgroundColor = [UIColor whiteColor];
        view1.layer.masksToBounds = YES;
        view1.layer.cornerRadius = 4.0;
        [_view addSubview:view1];
        UILabel *instructLabel = [[UILabel alloc] initWithFrame:CGRectMake(37, 32, 220, 60)];
        instructLabel.text = @"您的支付密码已重置成功请务必牢记!";
        instructLabel.textColor = [UIColor blackColor];
        instructLabel.font = [UIFont boldSystemFontOfSize:20];
        instructLabel.font = [UIFont systemFontOfSize:20];
        instructLabel.numberOfLines = 2;
        instructLabel.textAlignment = NSTextAlignmentCenter;
        instructLabel.backgroundColor = [UIColor whiteColor];
        [view1 addSubview:instructLabel];
    }
    return _view;
}

@end
