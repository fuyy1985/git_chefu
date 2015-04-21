//
//  QOrderKeyCell.m
//  HRClient
//
//  Created by ekoo on 14/12/10.
//  Copyright (c) 2014年 panyj. All rights reserved.
//

#import "QOrderKeyCell.h"

@implementation QOrderKeyCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
        
        [self awakeFromNib];
    }
    return self;
}


- (void)awakeFromNib
{
    _m_checkImageView = [[UIImageView alloc] initWithFrame:CGRectMake(SCREEN_SIZE_WIDTH - 60, 5, 15, 15)];
    [self.contentView addSubview:_m_checkImageView];
    
}

- (void)setChecked:(BOOL)checked
{
    if (checked)
    {
        _m_checkImageView.image = [UIImage imageNamed:@"check001.png"];
    }
    else
    {
        _m_checkImageView.image = [UIImage imageNamed:@"check002.png"];
    }
    
    m_checked = checked;
}

@end
