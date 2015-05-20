//
//  QBussinessCell.m
//  HRClient
//
//  Created by chenyf on 14/12/4.
//  Copyright (c) 2014年 panyj. All rights reserved.
//  商家cell

#import "QBussinessCell.h"
#import "UIImageView+WebCache.h"
#import "ASStarRating.h"
#import "QRegularHelp.h"
#import "QLocationManager.h"

#define DefaultLabelHeight          (30)
#define DefaultLabelWidth           (SCREEN_SIZE_WIDTH - 110)

@interface QBussinessCell ()
@property (nonatomic,strong)UIImageView *img;
@property (nonatomic,strong)UILabel *titleLabel;
@property (nonatomic,strong)ASStarRating *rateView;
@property (nonatomic,strong)UILabel *rateLabel;
@property (nonatomic,strong)UILabel *serviceContentAndLocationLabel;
@property (nonatomic,strong)UILabel *locationLabel;
@property (nonatomic,strong)UIImageView *locationIconImageView;

@end

@implementation QBussinessCell

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
    self.contentView.backgroundColor = [UIColor whiteColor];
    
    // Configure the self...
    
    CGFloat marginLeft, marginTop, labelWidth, labelHeight;
    
    // 展示图片
    _img = [[UIImageView alloc] initWithFrame:CGRectMake(7.5, 11, 80, 65)];
    _img.contentMode = UIViewContentModeScaleAspectFill;
    _img.clipsToBounds = YES;
    [self.contentView addSubview:_img];
    
    // 标题
    marginLeft = 100;
    marginTop = 8;
    labelWidth = DefaultLabelWidth;
    labelHeight = DefaultLabelHeight;
    
    CGRect labelFrame = CGRectMake(marginLeft, marginTop, labelWidth, 20);
    _titleLabel = [[UILabel alloc] initWithFrame:labelFrame];
    _titleLabel.backgroundColor = [UIColor clearColor];
    _titleLabel.text = @"未知商家";
    _titleLabel.font = [UIFont systemFontOfSize:15];
    _titleLabel.textColor = ColorDarkGray;
    [self.contentView addSubview:_titleLabel];

    // 评价星级
    marginTop = 30;
    _rateView = [[ASStarRating alloc] initWithFrame:CGRectMake(100, marginTop, 80, 13)];
    [self.contentView addSubview:_rateView];
    labelFrame = CGRectMake(CGRectGetMaxX(_rateView.frame) + 5, CGRectGetMinY(_rateView.frame), 150, labelHeight);
    _rateLabel = [[UILabel alloc] initWithFrame:labelFrame];
    _rateLabel.text = @"暂无评价";
    _rateLabel.backgroundColor = [UIColor clearColor];
    _rateLabel.font = [UIFont systemFontOfSize:12];
    _rateLabel.textColor = [QTools colorWithRGB:149 :149 :149];
    [_rateLabel sizeToFit];
    [self.contentView addSubview:_rateLabel];
    
    //地址
    marginTop = 65;
    labelFrame = CGRectMake(marginLeft, marginTop, labelWidth, 15);
    _serviceContentAndLocationLabel = [[UILabel alloc] initWithFrame:labelFrame];
    _serviceContentAndLocationLabel.backgroundColor = [UIColor clearColor];
    _serviceContentAndLocationLabel.font = [UIFont systemFontOfSize:12];
    _serviceContentAndLocationLabel.textColor = [QTools colorWithRGB:185 :185 :185];
    [self.contentView addSubview:_serviceContentAndLocationLabel];
    
    //距离
    _locationIconImageView = [[UIImageView alloc] initWithImage:IMAGEOF(@"location_cell")];
    _locationIconImageView.deFrameRight = self.contentView.deFrameWidth - 44;
    _locationIconImageView.deFrameTop = _rateLabel.deFrameTop;
    [self.contentView addSubview:_locationIconImageView];
    
    _locationLabel = [[UILabel alloc] init];
    _locationLabel.backgroundColor = [UIColor clearColor];
    _locationLabel.deFrameSize  = CGSizeMake(40, 15);
    _locationLabel.deFrameOrigin = CGPointMake(_locationIconImageView.deFrameRight + 5, marginTop);
    _locationLabel.font = [UIFont systemFontOfSize:12];
    _locationLabel.textColor = [QTools colorWithRGB:149 :149 :149];
    [_locationLabel sizeToFit];
    [self.contentView addSubview:_locationLabel];
    
    // SeparatorLine
#define selfHeight 89
#define selfWidth SCREEN_SIZE_WIDTH
    UIView *separatorLineView = [[UIView alloc] initWithFrame:CGRectMake(0, selfHeight - 0.5, selfWidth, 0.5)];
    separatorLineView.backgroundColor = ColorLine;
    [self.contentView addSubview:separatorLineView];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
    
    // Configure the view for the selected state
}

- (void)configureCellForHomePage:(NSArray *)modelList andIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.row >= modelList.count) {
        return;
    }
    QBusinessListModel *model = modelList[indexPath.row];
    
    //图片
    NSString *str = PICTUREHTTP(model.photoPath);
    [_img sd_setImageWithURL:[NSURL URLWithString:str]
            placeholderImage:[UIImage imageNamed:@"default_image"]
                     options:SDWebImageRefreshCached];
    
    [_rateView setScore:(model.grade && [model.grade doubleValue] > 0) ? [model.grade doubleValue] : 5];
    _titleLabel.text = NSString_No_Nil(model.companyName);
    
    
    if ([model.commentCount intValue] > 0)
        _rateLabel.text = [NSString stringWithFormat:@"%d评价", [model.commentCount intValue]];
    else
        _rateLabel.text = @"暂无评价";
    _rateLabel.frame = CGRectMake(CGRectGetMaxX(_rateView.frame) + 5, CGRectGetMinY(_rateView.frame), DefaultLabelWidth, DefaultLabelHeight);
    [_rateLabel sizeToFit];
    
    //距离
    if ([QLocationManager sharedInstance].geoResult)
    {
        _locationLabel.hidden = NO;
        _locationLabel.deFrameWidth = 200;
        _locationLabel.text = [QRegularHelp distanceToNSString:model.distance];
        [_locationLabel sizeToFit];
        _locationLabel.deFrameHeight = 15;
        _locationLabel.deFrameTop = _serviceContentAndLocationLabel.deFrameTop;
        _locationLabel.deFrameLeft = SCREEN_SIZE_WIDTH - _locationLabel.deFrameWidth - 5;
        
        _locationIconImageView.deFrameTop = _serviceContentAndLocationLabel.deFrameTop;
        _locationIconImageView.deFrameRight = _locationLabel.deFrameLeft - 3;
    }
    else
    {
        _locationLabel.deFrameWidth = 0;
    }
    _locationIconImageView.hidden = _locationLabel.deFrameWidth ? NO : YES;
    //地址
    _serviceContentAndLocationLabel.text = NSString_No_Nil(model.detailAddress);
    _serviceContentAndLocationLabel.deFrameWidth = _locationIconImageView.deFrameLeft - _serviceContentAndLocationLabel.deFrameLeft - 5;
}

- (void)configureCellForBusinDetail:(QBusinessDetailModel *)model
{
    if (model)
    {
        //图片异步加载
        [_img sd_setImageWithURL:[NSURL URLWithString:PICTUREHTTP(NSString_No_Nil(model.photoPath))]
                placeholderImage:IMAGEOF(@"default_image")
                         options:SDWebImageRefreshCached];
        
        if (model.companyName)_titleLabel.text = model.companyName;
        
        if (model.grade && (0 != [model.grade doubleValue]))
        {
            _rateView.hidden = NO;
            _rateLabel.hidden = NO;
            [_rateView setScore:[model.grade doubleValue]];
            _rateLabel.text = [NSString stringWithFormat:@"%@分",[model.grade stringValue]];
        }
        else
        {
            _rateView.hidden = YES;
            _rateLabel.hidden = YES;
        }
        
        if (model.commentCount && (0 != model.commentCount))
        {
            _serviceContentAndLocationLabel.hidden = NO;
            _serviceContentAndLocationLabel.text = [NSString stringWithFormat:@"%d条评价", [model.commentCount intValue]];
        }
        else
        {
            _serviceContentAndLocationLabel.hidden = YES;
        }
        
        if ([_locationLabel superview])
        {
            [_locationLabel removeFromSuperview];
            [_locationIconImageView removeFromSuperview];
        }
    }
}

@end
