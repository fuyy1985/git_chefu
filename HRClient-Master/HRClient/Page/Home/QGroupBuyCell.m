//
//  QGroupBuyself.m
//  HRClient
//
//  Created by chenyf on 14/12/4.
//  Copyright (c) 2014年 panyj. All rights reserved.
//  团购cell

#import "QGroupBuyCell.h"
#import "UIImageView+WebCache.h"
#import "QRegularHelp.h"

@interface QGroupBuyCell ()

@property (nonatomic,strong)UIImageView *img;
@property (nonatomic,strong)UILabel *titleLabel;
@property (nonatomic,strong)UILabel *descLabel;
@property (nonatomic,strong)UILabel *priceLabel;
@property (nonatomic,strong)UILabel *rateAndCountLabel;
@property (nonatomic,copy)NSString *price;
@property (nonatomic,copy)NSString *retailPrice;
@property (nonatomic,strong)UILabel *qlyGuar;
@property (nonatomic,strong)UILabel *vipLabel;
@property (nonatomic,strong)UILabel *vipPriceLabel;

@end

@implementation QGroupBuyCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
        [self.contentView.subviews makeObjectsPerformSelector:@selector(removeFromSuperview)];
        self.selectionStyle = UITableViewCellSelectionStyleNone;
        self.contentView.backgroundColor = [UIColor whiteColor];
        
        CGFloat margin = 10;
        
        // 展示图片
        _img = [[UIImageView alloc] initWithFrame:CGRectMake(margin, margin, 90, 80)];
        _img.contentMode = UIViewContentModeScaleAspectFill;
        _img.clipsToBounds = YES;
        [self.contentView addSubview:_img];
        
        CGFloat leftBegin = _img.deFrameRight + margin;
        CGFloat labelWidth = SCREEN_SIZE_WIDTH - 80 - 2 * margin;
        CGFloat heightBegin = margin;
        
        // 标题
        CGRect labelFrame = CGRectMake(leftBegin, heightBegin, labelWidth , 22);
        _titleLabel = [[UILabel alloc] initWithFrame:labelFrame];
        _titleLabel.backgroundColor = [UIColor clearColor];
        _titleLabel.text = @"未知商家";
        _titleLabel.font = [UIFont systemFontOfSize:15];
        _titleLabel.lineBreakMode =  NSLineBreakByTruncatingTail;
        _titleLabel.adjustsFontSizeToFitWidth = NO;
        _titleLabel.textColor = [UIColor darkGrayColor];
        [self.contentView addSubview:_titleLabel];
        
        // 质保标记
        _qlyGuar = [[UILabel alloc] initWithFrame:CGRectMake(SCREEN_SIZE_WIDTH - 40, _titleLabel.deFrameTop + 5, 30, 17)];
        _qlyGuar.backgroundColor = [UIColor clearColor];
        _qlyGuar.backgroundColor = [UIColor clearColor];
        _qlyGuar.font = [UIFont systemFontOfSize:10];
        _qlyGuar.textAlignment = NSTextAlignmentCenter;
        _qlyGuar.textColor = ColorDarkGray;
        [self.contentView addSubview:_qlyGuar];
        
        // 会员卡
        _vipLabel = [[UILabel alloc] initWithFrame:CGRectMake(_qlyGuar.deFrameLeft - 30, _qlyGuar.deFrameTop, 20, 17)];
        _vipLabel.backgroundColor = [UIColor clearColor];
        _vipLabel.text = @"卡";
        _vipLabel.font = [UIFont systemFontOfSize:11];
        _vipLabel.textAlignment = NSTextAlignmentCenter;
        _vipLabel.textColor = [QTools colorWithRGB:255 :255 :255];
        _vipLabel.backgroundColor = [QTools colorWithRGB:233 :113 :78];
        [self.contentView addSubview:_vipLabel];
        
        // 商品介绍
        heightBegin = _titleLabel.deFrameBottom;
        labelFrame = CGRectMake(leftBegin, heightBegin, labelWidth - 5, 40);
        _descLabel.text = @"";
        _descLabel = [[UILabel alloc] initWithFrame:labelFrame];
        _descLabel.backgroundColor = [UIColor clearColor];
        _descLabel.textAlignment = NSTextAlignmentLeft;
        _descLabel.numberOfLines = 2;
        _descLabel.textColor = [QTools colorWithRGB:0x9b :0x9b :0x9b];
        _descLabel.font = [UIFont systemFontOfSize:13];
        [self.contentView addSubview:_descLabel];
        
        // 价格
        heightBegin = _descLabel.deFrameBottom;;
        labelFrame = CGRectMake(leftBegin, heightBegin, labelWidth - 100, 17);
        _priceLabel.text = @"0元";
        _priceLabel = [[UILabel alloc] initWithFrame:labelFrame];
        _priceLabel.backgroundColor = [UIColor clearColor];
        _priceLabel.font = [UIFont systemFontOfSize:17];
        _priceLabel.textAlignment = NSTextAlignmentLeft;
        [self.contentView addSubview:_priceLabel];
        
        // 会员低至多少
        _vipPriceLabel = [[UILabel alloc] initWithFrame:CGRectMake(SCREEN_SIZE_WIDTH - 140,
                                                                   heightBegin, 100, 17)];
        _vipPriceLabel.backgroundColor = [UIColor clearColor];
        _vipPriceLabel.font = [UIFont systemFontOfSize:14];
        _vipPriceLabel.text = @"会员价2元起";
        _vipPriceLabel.textColor = [QTools colorWithRGB:233 :113 :78];
        [self.contentView addSubview:_vipPriceLabel];
        
        // 评分 & 销量
        labelFrame = CGRectMake(SCREEN_SIZE_WIDTH - 105, heightBegin+5, 95, 17);
        _rateAndCountLabel.text = @"已售0";
        _rateAndCountLabel = [[UILabel alloc] initWithFrame:labelFrame];
        _rateAndCountLabel.backgroundColor = [UIColor clearColor];
        _rateAndCountLabel.font = [UIFont systemFontOfSize:11];
        _rateAndCountLabel.textColor = [QTools colorWithRGB:149 :149 :149];
        _rateAndCountLabel.textAlignment = NSTextAlignmentRight;
        [self.contentView addSubview:_rateAndCountLabel];
        
        // SeparatorLine
        UIView *separatorLineView = [[UIView alloc] initWithFrame:CGRectMake(0, 99, SCREEN_SIZE_WIDTH, 1)];
        separatorLineView.backgroundColor = [QTools colorWithRGB:0xec :0xec :0xec];
        [self.contentView addSubview:separatorLineView];
        [self awakeFromNib];
    }
    
    SDWebImageManager.sharedManager.imageDownloader.executionOrder = SDWebImageDownloaderLIFOExecutionOrder;
    return self;
}

+ (float)GetQGroupBuyCellHeight
{
    return 100;
}

- (void)configureCellForBusinPage:(NSArray *)model1 andIndexPath:(NSIndexPath *)indexPath
{
    QBusinessDetailResult *model = model1[indexPath.row];
    
    if(model == nil) return;
    
    //公司
    if (model.subject) _titleLabel.text = model.subject;
    CGFloat margin = 10;
    CGFloat leftBegin = _img.deFrameRight + margin;
    CGFloat labelWidth = SCREEN_SIZE_WIDTH - 80 - 2 * margin;
    CGFloat heightBegin = margin;
    _titleLabel.frame = CGRectMake(leftBegin, heightBegin, labelWidth - 10, 22);
    _titleLabel.font = [UIFont systemFontOfSize:15.f];
    
    //标题
    if (model.serviceDesc) _descLabel.text = model.serviceDesc;
    _descLabel.font = [UIFont systemFontOfSize:12];
    _descLabel.hidden = YES;
    
    //价格
    _price = [model.bidPrice stringValue];          //会员价
    _retailPrice = [model.price stringValue];       //原价
    _retailPrice = [_retailPrice stringByAppendingString:@"元  "];
    if (_price == nil) {
        _price = @"0";
    }
    if (_retailPrice == nil) {
        _retailPrice = @"0";
    }
    
    NSString *text = [NSString stringWithFormat:@"%@元 %@", _price, _retailPrice];
    NSMutableAttributedString *string = [[NSMutableAttributedString alloc] initWithString:text attributes:@{NSStrikethroughStyleAttributeName: @(NSUnderlineStyleNone)}];
    [string addAttributes:@{NSStrikethroughStyleAttributeName:@(NSUnderlineStyleSingle)} range:[text rangeOfString:_retailPrice]];
    [string addAttribute:NSFontAttributeName value:[UIFont systemFontOfSize:18] range:[text rangeOfString:_price]];
    [string addAttribute:NSForegroundColorAttributeName value:[QTools colorWithRGB:196 :0 :0] range:[text rangeOfString:_price]];
    _priceLabel.textColor = [QTools colorWithRGB:149 :149 :149];
    _priceLabel.font = [UIFont systemFontOfSize:11];
    _priceLabel.attributedText = string;
    
    _rateAndCountLabel.text = [NSString stringWithFormat:@"已售%d",[model.salesVolume intValue]];
    
    if ([_vipLabel superview]) [_vipLabel removeFromSuperview];
    if ([_vipPriceLabel superview]) [_vipPriceLabel removeFromSuperview];
    
    //是否质保和是否会员
    _qlyGuar.attributedText = [QRegularHelp guaranteeStringbyPeriod:[model.guaranteePeriod integerValue]];
    
    [_qlyGuar sizeToFit];
    _qlyGuar.deFrameRight = SCREEN_SIZE_WIDTH - 5;
    _titleLabel.deFrameWidth -= _qlyGuar.deFrameWidth;
    
    //图片异步加载
    if (model.photoPath && ![model.photoPath isEqualToString:@""])
    {
        NSString *str = PICTUREHTTP(model.photoPath);
        RunOnMainThread([_img sd_setImageWithURL:[NSURL URLWithString:str]
                                placeholderImage:[UIImage imageNamed:@"default_image"]
                                         options:SDWebImageRetryFailed|(indexPath.row == 0) ? SDWebImageRefreshCached : 0])
    }
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
}

@end
