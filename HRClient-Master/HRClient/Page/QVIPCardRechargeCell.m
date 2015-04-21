//
//  QVIPCardRechargeCell.m
//  HRClient
//
//  Created by ekoo on 14/12/16.
//  Copyright (c) 2014年 panyj. All rights reserved.
//

#import "QVIPCardRechargeCell.h"
#import "QCardDetailModel.h"

#define selfWidth SCREEN_SIZE_WIDTH - 2 * 15 - 2 * 10
@interface QVIPCardRechargeCell ()

@property (nonatomic,strong)UILabel *styleLabel;
@property (nonatomic,strong)UILabel *carLabel;
@property (nonatomic,strong)UILabel *SUVLabel;
@property (nonatomic,strong)UILabel *priceLabel;


@end

@implementation QVIPCardRechargeCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
        CGFloat agreeBeforeW = 10;
        CGFloat agreeTopH = 5;
        CGFloat agreeW = 25;
        CGFloat agreeH = 25;
        _agreeImageView = [[UIImageView alloc] initWithFrame:CGRectMake(agreeBeforeW, agreeTopH, agreeW, agreeH)];
        [self.contentView addSubview:_agreeImageView];
        
//        _sureImageView = [[UIImageView alloc] initWithFrame:CGRectMake(2, 2, 20, 20)];
        _sureImageView = [[UIImageView alloc] init];
        _sureImageView.frame = _agreeImageView.bounds;
        [_agreeImageView addSubview:_sureImageView];
        
        _styleLabel = [[UILabel alloc] initWithFrame:CGRectMake(_agreeImageView.deFrameRight + 10, agreeTopH, 55, 25)];
        _styleLabel.textColor = [QTools colorWithRGB:51 :51 :51];
        _styleLabel.adjustsFontSizeToFitWidth = YES;
        [self.contentView addSubview:_styleLabel];
        
        _carLabel = [[UILabel alloc] initWithFrame:CGRectMake(_styleLabel.deFrameRight + 15, agreeTopH, 50, 25)];
        _carLabel.textColor = [QTools colorWithRGB:51 :51 :51];
        [self.contentView addSubview:_carLabel];
        
        _SUVLabel = [[UILabel alloc] initWithFrame:CGRectMake(_carLabel.deFrameRight + 15, agreeTopH, 50, 25)];
        _SUVLabel.textColor = [QTools colorWithRGB:51 :51 :51];
        [self.contentView addSubview:_SUVLabel];
        
        _priceLabel = [[UILabel alloc] initWithFrame:CGRectMake(_SUVLabel.deFrameRight + 15, agreeTopH, 45, 25)];
        _priceLabel.textColor = [QTools colorWithRGB:51 :51 :51];
        [self.contentView addSubview:_priceLabel];

//        UIView *separatorLineView = [[UIView alloc] initWithFrame:CGRectMake(10, selfHeight, selfWidth, 0.5)];
//        separatorLineView.backgroundColor = [QTools colorWithRGB:149 :149 :149];
//        [self.contentView addSubview:separatorLineView];
        [self awakeFromNib];
    }
    return self;
}

- (void)awakeFromNib {
    // Initialization code
    }

- (void)configureModelForCell:(NSArray *)arr andIndexPath:(NSIndexPath *)indexPath{
    if (indexPath.row == 0)
    {
        _styleLabel.text = @"类型";
        _styleLabel.font = [UIFont systemFontOfSize:14];
        _carLabel.text = @"轿车";
        _carLabel.font = [UIFont systemFontOfSize:14];
        _SUVLabel.text = @"SUV";
        _SUVLabel.font = [UIFont systemFontOfSize:14];
        _priceLabel.text = @"价格";
        _priceLabel.font = [UIFont systemFontOfSize:14];
        _priceLabel.textColor = [QTools colorWithRGB:51 :51 :51];
    }
    else
    {
        if ((indexPath.row - 1) >= arr.count) {
            return;
        }
        
        QCardDetailModel *model = arr[indexPath.row - 1];
        _styleLabel.text = model.memberTypeName;
        _styleLabel.font = [UIFont systemFontOfSize:13];
        
        for (NSDictionary *dict in model.memberPrices)
        {
            NSString *price = [@"￥" stringByAppendingString:[[dict objectForKey:@"memberUnitPrice"] stringValue]];
            if ([[dict objectForKey:@"memberPriceId"] intValue] < 6)
                _carLabel.text = price;
            else
                _SUVLabel.text = price;
        }
        
        _carLabel.font = [UIFont systemFontOfSize:13];
        _SUVLabel.font = [UIFont systemFontOfSize:13];
        
        _priceLabel.text = [@"￥" stringByAppendingString:[model.amount stringValue]];
        _priceLabel.font = [UIFont systemFontOfSize:13];
        _priceLabel.textColor = UIColorFromRGB(0xc40000);
    
    }
}

@end
