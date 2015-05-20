//
//  QMyDataCell.m
//  HRClient
//
//  Created by ekoo on 14/12/10.
//  Copyright (c) 2014年 panyj. All rights reserved.
//

#import "QMyDataCell.h"
#import "QHttpMessageManager.h"

static BOOL isChange;
@interface QMyDataCell (){
    UITapGestureRecognizer *tap;
    NSString *nameStr;
    NSString *newString;
}

@property (nonatomic,strong)UILabel *beforeLabel;
@property (nonatomic,strong)UILabel *backLabel;
@property (nonatomic,strong)UITextField *accountTextFiled;

@end

@implementation QMyDataCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
 
        // Initialization code
        CGFloat beforeW = 13.0;
        CGFloat topH = 0;
        CGFloat h = 45;
        
        _beforeLabel = [[UILabel alloc] initWithFrame:CGRectMake(beforeW, topH, 75, h)];
        _beforeLabel.textColor = [QTools colorWithRGB:85 :85 :85];
        _beforeLabel.backgroundColor = [UIColor clearColor];
        _beforeLabel.font = [UIFont systemFontOfSize:15];
        [self.contentView addSubview:_beforeLabel];
        
        _backLabel = [[UILabel alloc] initWithFrame:CGRectMake(SCREEN_SIZE_WIDTH - 150 - 30, topH, 150, h)];
        _backLabel.textColor = [QTools colorWithRGB:136 :136 :136];
        _backLabel.backgroundColor = [UIColor clearColor];
        _backLabel.font = [UIFont systemFontOfSize:15];
        _backLabel.textAlignment = NSTextAlignmentRight;
        isChange = NO;
        _backLabel.userInteractionEnabled = isChange;
        tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(sureToChangeColor:)];
        [self.contentView addSubview:_backLabel];
        
        _accountTextFiled = [[UITextField alloc] initWithFrame:CGRectMake(_beforeLabel.deFrameRight, topH, 140, h)];
        _accountTextFiled.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
        _accountTextFiled.font = [UIFont systemFontOfSize:15];
        _accountTextFiled.clearButtonMode = UITextFieldViewModeWhileEditing;
        _accountTextFiled.delegate = self;
        [self.contentView addSubview:_accountTextFiled];
        _accountTextFiled.hidden = YES;
        
        [self awakeFromNib];
    }
    return self;
}

- (void)awakeFromNib {
    // Initialization code
}

- (void)configurationCellWithModel:(NSArray *)arr andIndexPath:(NSIndexPath *)indexPath andPayPwd:(NSString *)myPayPwd{

    if (indexPath.section == 0) {
        
        _beforeLabel.text = arr[indexPath.section];
        _backLabel.text = @"修改";
        [_backLabel addGestureRecognizer:tap];
        _accountTextFiled.text = [ASUserDefaults objectForKey:AccountNick];
        _accountTextFiled.hidden = NO;
        
    }
    else if (indexPath.section == 1){
        
        if (indexPath.row == 0 && [myPayPwd isEqualToString:@"Y"]) {
            _backLabel.text = @"修改/找回";
            _beforeLabel.text = arr[indexPath.row + 1];
        }
        else if (indexPath.row == 0){
            _beforeLabel.text = arr[indexPath.row + 1];
            _backLabel.text = @"设置";
        }
        else if (indexPath.row == 2){
            _beforeLabel.text = arr[indexPath.row + 1];
            _backLabel.text = [ASUserDefaults objectForKey:LoginUserPhone];
        }
        else{
            _beforeLabel.text = arr[indexPath.row + 1];
            _backLabel.text = @"修改";
        }
    }
}


- (void)sureToChangeColor:(UIGestureRecognizer *)sender{
    
    if (_accountTextFiled.isFirstResponder) {
        [_accountTextFiled resignFirstResponder];
        _backLabel.textColor = [QTools colorWithRGB:136 :136 :136];
        _backLabel.text = @"修改";
        
        NSString * oldNickName = [ASUserDefaults objectForKey:AccountNick];
        if (![newString isEqualToString:oldNickName]) {
            if (self.delegate && [self.delegate respondsToSelector:@selector(setNick:)]) {
                [self.delegate setNick:newString];
            }
        }
    }
    else {
        [_accountTextFiled becomeFirstResponder];
    }
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string{
    newString = nil;
    if (range.length == 0) {
        newString = [textField.text stringByAppendingString:string];
    } else {
        NSString *headPart = [textField.text substringToIndex:range.location];
        NSString *tailPart = [textField.text substringFromIndex:range.location+range.length];
        newString = [NSString stringWithFormat:@"%@%@",headPart,tailPart];
    }
    
    if ([newString isEqualToString:nameStr]) {
        _backLabel.textColor = [QTools colorWithRGB:136 :136 :136];
        _backLabel.userInteractionEnabled = isChange;
        _backLabel.text = @"修改";
    }else{
        isChange = YES;
        _backLabel.textColor = ColorTheme;
        _backLabel.text = @"确认修改";
        _backLabel.userInteractionEnabled = isChange;
    }
    return YES;
}

- (void)beginEditNickName
{
    [_accountTextFiled becomeFirstResponder];
}

@end
