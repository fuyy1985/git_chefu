//
//  QVIPRechargeCell.m
//  HRClient
//
//  Created by ekoo on 14/12/8.
//  Copyright (c) 2014年 panyj. All rights reserved.
//

#import "QVIPRechargeCell.h"

@interface QVIPRechargeCell ()

@property (nonatomic,strong)UIImageView *img;
@property (nonatomic,strong)UILabel *payStyleLable;
@property (nonatomic,strong)UILabel *detailLabel;


@end

@implementation QVIPRechargeCell

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
    
    // Configure the self...
    
    CGFloat marginLeft, marginTop, labelWidth, labelHeight;
    CGFloat blank = 5;
    // 展示图片
    _img = [[UIImageView alloc] initWithFrame:CGRectMake(blank + 5, 3 + 5, 60, self.contentView.frame.size.height - 10)];
    _img.layer.masksToBounds = YES;
    _img.layer.cornerRadius = 4.0;
    [self.contentView addSubview:_img];
    
    //支付方式
    marginLeft = _img.frame.origin.x + _img.frame.size.width + blank;
    marginTop = blank;
    labelWidth = SCREEN_SIZE_WIDTH - _img.frame.size.width - 2*blank;
    labelHeight = 22;
    CGRect payStyleLableFrame =CGRectMake(marginLeft, marginTop, labelWidth, labelHeight);
    _payStyleLable = [[UILabel alloc] initWithFrame:payStyleLableFrame];
//    _payStyleLable.text = @"银行卡支付";
    _payStyleLable.font = [UIFont boldSystemFontOfSize:15];
    _payStyleLable.font = [UIFont systemFontOfSize:18];
    _payStyleLable.textColor = [QTools colorWithRGB:85 :85 :85];
//    payStyleLable.backgroundColor = [UIColor yellowColor];
    [self.contentView addSubview:_payStyleLable];
    
    //详细说明
    marginTop = _payStyleLable.frame.origin.y+_payStyleLable.frame.size.height ;
    CGRect detailLabelFrame = CGRectMake(marginLeft, marginTop, labelWidth, labelHeight);
    _detailLabel = [[UILabel alloc] initWithFrame:detailLabelFrame];
//    _detailLabel.text = @"支持储蓄卡信用卡，无需开通网银";
    _detailLabel.font = [UIFont systemFontOfSize:13];
    _detailLabel.textColor = [QTools colorWithRGB:153 :153 :153];
//    detailLabel.backgroundColor = [UIColor cyanColor];
    [self.contentView addSubview:_detailLabel];
    
//    选择
    CGFloat selectW = 30;
    CGFloat selectH = (self.contentView.frame.size.height - 20)/2;
    _selectImageView = [[UIImageView alloc] initWithFrame:CGRectMake(SCREEN_SIZE_WIDTH - blank - selectW - 5, selectH, selectW, 30)];
//    _selectImageView.image = [UIImage imageNamed:@"yuan01.gif"];
    [self.contentView addSubview:_selectImageView];
    
}

- (void)cofigureModelToCell:(NSArray *)arr andIndexPath:(NSIndexPath *)indexPath{
    _img.image = IMAGEOF([arr[indexPath.row] objectForKey:@"icon"]);
    _payStyleLable.text = [arr[indexPath.row] objectForKey:@"title"];
    _detailLabel.text = [arr[indexPath.row] objectForKey:@"detail"];
//    _selectImageView.image = IMAGEOF([arr[indexPath.row] objectForKey:@"select"]);
}

- (void)sendModelToImage1:(NSArray *)arr andRow:(NSInteger)row{
    // m_checkImageView.image = IMAGEOF([arr[row - 1] objectForKey:@"checked"]);
    _selectImageView.image = [UIImage imageNamed:arr[row]];
    
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
