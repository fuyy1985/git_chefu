//
//  QPurchaseSuccessCell.m
//  HRClient
//
//  Created by ekoo on 14/12/31.
//  Copyright (c) 2014年 panyj. All rights reserved.
//

#import "QPurchaseSuccessCell.h"

@interface QPurchaseSuccessCell ()


@end

@implementation QPurchaseSuccessCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
        CGFloat beforeW = 10;
        _headLabel = [[UILabel alloc] initWithFrame:CGRectMake(beforeW, 5, SCREEN_SIZE_WIDTH/3.0, 30)];
        _headLabel.backgroundColor = [UIColor clearColor];
        _headLabel.textColor = [QTools colorWithRGB:86 :86 :86];
        [self.contentView addSubview:_headLabel];
        
        _backLabel = [[UILabel alloc] initWithFrame:CGRectMake(SCREEN_SIZE_WIDTH/3.0, 5, SCREEN_SIZE_WIDTH/3.0 * 2 - 10, 30)];
        _backLabel.textAlignment = NSTextAlignmentRight;
        _backLabel.backgroundColor = [UIColor clearColor];
        [self.contentView addSubview:_backLabel];
        
        
        [self awakeFromNib];
    }
    return self;
}

- (void)awakeFromNib {
    // Initialization code
}

- (void)configureCellToModel:(NSArray *)arr andPath:(NSIndexPath *)indexPath{
    _backLabel.text  = arr[indexPath.section];
    if (indexPath.section == 0) {
        _headLabel.text = @"商品名称";
    }else{
        _headLabel.text = @"车夫券";
    }
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
