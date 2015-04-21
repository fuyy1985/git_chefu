//
//  QVIPCardCell.m
//  HRClient
//
//  Created by ekoo on 14/12/9.
//  Copyright (c) 2014年 panyj. All rights reserved.
//

#import "QVIPCardCell.h"
#import "QViewController.h"

@implementation QVIPCardCell


- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
        [self awakeFromNib];
    }
    return self;
}

- (void)awakeFromNib {
    // Initialization code
    [self.contentView.subviews makeObjectsPerformSelector:@selector(removeFromSuperview)];
    self.selectionStyle = UITableViewCellSelectionStyleNone;

    CGFloat marginLeft, marginTop, labelWidth, labelHeight;
    
//    到期日期
    marginLeft = 10;
    marginTop = 10;
    labelWidth = SCREEN_SIZE_WIDTH - 20;
    labelHeight = 40;
    UILabel *dueDateLable = [[UILabel alloc] initWithFrame:CGRectMake(marginLeft, marginTop, labelWidth, labelHeight)];
    
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"yyyy/MM/dd"];
    NSDate *expireDate = [NSDate dateWithTimeIntervalSince1970:(([[QUser sharedQUser].vipAccount.expireDate unsignedLongLongValue]) / 1000 )];
    NSString *orderTime = [dateFormatter stringFromDate:expireDate];//毫秒->秒
    
    dueDateLable.text = [NSString stringWithFormat:@"到期日：%@",orderTime];
    dueDateLable.textColor = [QTools colorWithRGB:245 :74 :0];
    dueDateLable.font = [UIFont systemFontOfSize:15];
    [self.contentView addSubview:dueDateLable];
    
//    支付密码
    marginTop = 60;
    labelWidth = 120;
    
    CGSize size = [@"输入支付密码" sizeWithFont:[UIFont systemFontOfSize:15]];
    UILabel *keyLable = [[UILabel alloc] initWithFrame:CGRectMake(marginLeft, marginTop, size.width, labelHeight)];
    keyLable.text = @"输入支付密码";
    keyLable.textColor = [QTools colorWithRGB:40 :40 :40];
    keyLable.font = [UIFont systemFontOfSize:15];
    [self.contentView addSubview:keyLable];
    
//    输入框
    marginLeft = size.width + 15;
    _keyTextField = [[UITextField alloc] initWithFrame:CGRectMake(marginLeft, marginTop+5, SCREEN_SIZE_WIDTH - 20-130, labelHeight -  10)];
    _keyTextField.borderStyle = UITextBorderStyleRoundedRect;
    _keyTextField.clearButtonMode = UITextFieldViewModeWhileEditing;
    _keyTextField.secureTextEntry = YES;
    _keyTextField.textColor = ColorDarkGray;
    _keyTextField.font = [UIFont systemFontOfSize:13];
    _keyTextField.returnKeyType = UIReturnKeyDone;
    [self.contentView addSubview:_keyTextField];
    
//    忘记密码
    marginTop = marginTop+labelHeight+5;
    marginLeft = SCREEN_SIZE_WIDTH - 100;
    labelWidth = 90;
    
    UIButton *forgetBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    forgetBtn.titleLabel.font = [UIFont systemFontOfSize:13.f];
    forgetBtn.frame = CGRectMake(marginLeft, marginTop, labelWidth, labelHeight);
    
    NSMutableAttributedString *content = [[NSMutableAttributedString alloc] initWithString:@"忘记密码？"];
    NSRange contentRange = {0, [content length]};
    [content addAttribute:NSUnderlineStyleAttributeName value:[NSNumber numberWithInteger:NSUnderlineStyleSingle] range:contentRange];
    [forgetBtn setTitle:@"忘记密码？" forState:UIControlStateNormal];
    [forgetBtn titleLabel].attributedText = content;
    [forgetBtn setTitleColor:ColorTheme forState:UIControlStateNormal];
    [forgetBtn addTarget:self action:@selector(gotoForeget) forControlEvents:UIControlEventTouchUpInside];
    [self.contentView addSubview:forgetBtn];
    
}

- (void)gotoForeget{
    [QViewController gotoPage:@"QFindPayKey" withParam:nil]; // 找回支付密码
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
