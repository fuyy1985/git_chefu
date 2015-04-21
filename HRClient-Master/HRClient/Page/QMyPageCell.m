//
//  QMyPageCell.m
//  HRClient
//
//  Created by ekoo on 14/12/15.
//  Copyright (c) 2014年 panyj. All rights reserved.
//

#import "QMyPageCell.h"

@interface QMyPageCell ()

@property (nonatomic,strong)UIImageView *iconImageView;
@property (nonatomic,strong)UILabel *nameLabel;

@end

@implementation QMyPageCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
        
        CGFloat iconW = 22;
        CGFloat iconH = 22;
        CGFloat iconTopH = (self.contentView.frame.size.height - iconH)/2;
        CGFloat iconBeforeW = 23;
        _iconImageView = [[UIImageView alloc] initWithFrame:CGRectMake(iconBeforeW, iconTopH, iconW, iconH)];
        [self.contentView addSubview:_iconImageView];
        
        CGFloat titleW = 160;
        CGFloat titleH = self.contentView.frame.size.height;
        CGFloat titleTop = 0;
        CGFloat blank = 15;
        CGFloat titleBeforeW =_iconImageView.deFrameRight + blank;
        _nameLabel = [[UILabel alloc] initWithFrame:CGRectMake(titleBeforeW, titleTop, titleW, titleH)];
        _nameLabel.font = [UIFont systemFontOfSize:14];
        _nameLabel.textColor = ColorDarkGray;
        _nameLabel.backgroundColor = [UIColor clearColor];
        [self.contentView addSubview:_nameLabel];
        
        UIView *lineView = [[UIView alloc] initWithFrame:CGRectMake(10, CellHeight - 0.5f, SCREEN_SIZE_WIDTH - 2*10, 0.5f)];
        lineView.backgroundColor = ColorLine;
        [self.contentView addSubview:lineView];
        
        [self awakeFromNib];
    }
    return self;
}

- (void)awakeFromNib {
    // Initialization code
    
    
}

- (void)configureModelForCell:(NSArray *)imageArr andTitle:(NSArray *)titleArr andIndexPath:(NSIndexPath *)indexPath{
    _iconImageView.image = [UIImage imageNamed:imageArr[indexPath.row]];
    _nameLabel.text = titleArr[indexPath.row];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
