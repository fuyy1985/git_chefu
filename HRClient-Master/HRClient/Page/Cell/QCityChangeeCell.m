//
//  QCityChangeeCell.m
//  HRClient
//
//  Created by ekoo on 14/12/30.
//  Copyright (c) 2014年 panyj. All rights reserved.
//

#import "QCityChangeeCell.h"

#define ButtonTagOffset         (8909)
#define ButtonWidth             (((SCREEN_SIZE_WIDTH - 2 * 15) - 2 * 25)/3.0)
#define ButtonBgColor           ([QTools colorWithRGB:250 :250 :250])
#define ButtonTextColor         ([QTools colorWithRGB:114 :114 :114])
#define ButtonTextFont          ([UIFont systemFontOfSize:14])

@implementation QCityChangeeCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        [self awakeFromNib];
    }
    return self;
}

- (void)awakeFromNib {
    // Initialization code
}

+ (UIButton*)cityButton:(CGRect)frame title:(NSString*)title
{
    UIButton *btn = [[UIButton alloc] initWithFrame:frame];
    
    UIImage *image = [QTools createImageWithColor:ButtonBgColor];
    [btn setBackgroundImage:image forState:UIControlStateNormal];
    [btn setBackgroundImage:image forState:UIControlStateHighlighted];
    
    [btn setTitle:title forState:UIControlStateNormal];
    [btn setTitleColor:ButtonTextColor forState:UIControlStateNormal];
    btn.titleLabel.font = ButtonTextFont;
    return btn;
}

- (void)configureCellForTableView:(NSArray *)localArr andRecent:(NSArray *)recentArr andHot:(NSArray *)hotArr andIndexPath:(NSIndexPath *)indexPath{
    
    /* 定位城市 */
    if (indexPath.section == 0 && indexPath.row == 0) {
        
        UIButton *btn = [QCityChangeeCell cityButton:CGRectMake(15, 10, ButtonWidth, 30) title:localArr[0]];
        btn.tag = ButtonTagOffset;
        [self.contentView addSubview:btn];
    }
    /* 最近访问城市 */
    else if (indexPath.section == 1 && indexPath.row == 0){
        for (int i = 0; i < recentArr.count; i ++) {
 
            UIButton *btn = [QCityChangeeCell cityButton:CGRectMake(15 + (ButtonWidth + 15) * (i%3),
                                                                     10 + (7 + 30) * (i/3),
                                                                     ButtonWidth,
                                                                     30)
                                                    title:recentArr[i]];
            btn.tag = ButtonTagOffset + i;
            [btn addTarget:self action:@selector(clickBtnToChange:) forControlEvents:UIControlEventTouchUpInside];
            [self.contentView addSubview:btn];
        }
    }
    /* 热门城市 */
    else if (indexPath.section == 2 && indexPath.row == 0){
        for (int i = 0; i < hotArr.count; i ++) {
            UIButton *btn = [QCityChangeeCell cityButton:CGRectMake(15 + (ButtonWidth + 15) * (i%3),
                                                                    10 + (7 + 30) * (i/3),
                                                                    ButtonWidth,
                                                                    30)
                                                   title:hotArr[i]];
            btn.tag = ButtonTagOffset + i;
            [btn addTarget:self action:@selector(clickBtnToChange:) forControlEvents:UIControlEventTouchUpInside];
            [self.contentView addSubview:btn];
    }
}
}

- (void)clickBtnToChange:(UIButton *)sender
{
    UIButton *button = (UIButton *)sender;
    
    if (self.delegate && [self.delegate respondsToSelector:@selector(citySelected:andCityIndex:)]) {
        [self.delegate citySelected:self andCityIndex:button.tag - ButtonTagOffset];
    }
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
