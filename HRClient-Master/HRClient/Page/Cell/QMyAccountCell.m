//
//  QMyAccountCell.m
//  HRClient
//
//  Created by ekoo on 14/12/23.
//  Copyright (c) 2014年 panyj. All rights reserved.
//

#import "QMyAccountCell.h"

@implementation QMyAccountCell
@synthesize nameLabel = _nameLabel;
@synthesize moneyLabel = _moneyLabel;

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
        CGFloat topH = 10;
        CGFloat nameH = 20;
        _nameLabel = [[UILabel alloc] initWithFrame:CGRectMake(15, topH, 180, nameH)];
        _nameLabel.textColor = ColorDarkGray;
        _nameLabel.font = [UIFont systemFontOfSize:14];
        [self.contentView addSubview:_nameLabel];
        
        CGFloat enterW = 20;
        CGFloat moneyW = 100;
        _moneyLabel = [[UILabel alloc] initWithFrame:CGRectMake(SCREEN_SIZE_WIDTH - 10 - enterW - 5 - moneyW, topH, moneyW, 20)];
        _moneyLabel.textAlignment = NSTextAlignmentRight;
        _moneyLabel.font = [UIFont systemFontOfSize:14];
        [self.contentView addSubview:_moneyLabel];
        
        [self awakeFromNib];
    }
    return self;
}

- (void)configureCellToModel:(NSArray *)arr andIndexPath:(NSIndexPath *)indexPath{
    
}

- (void)awakeFromNib {
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
