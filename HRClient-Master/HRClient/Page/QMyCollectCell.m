//
//  QMyCollectCell.m
//  HRClient
//
//  Created by ekoo on 14/12/17.
//  Copyright (c) 2014年 panyj. All rights reserved.
//

#import "QMyCollectCell.h"
#import "QMyFavoritedModel.h"
#import "UIImageView+WebCache.h"

@interface QMyCollectCell ()

@property (nonatomic,strong)UIImageView *img;
@property (nonatomic,strong)UILabel *titleLabel;
@property (nonatomic,strong)UILabel *descLabel;
@property (nonatomic,strong)UILabel *priceLabel;
@property (nonatomic,strong)UILabel *rateAndCountLabel;
@property (nonatomic,strong)UILabel *qlyGuar;
@property (nonatomic,copy)NSString *price;
@property (nonatomic,copy)NSString *retailPrice;
@property (nonatomic,strong)UILabel *vipPriceLabel;
@property (nonatomic,strong)UILabel *vipLabel;

@end

@implementation QMyCollectCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
        [self.contentView.subviews makeObjectsPerformSelector:@selector(removeFromSuperview)];
        self.selectionStyle = UITableViewCellSelectionStyleNone;
        self.contentView.backgroundColor = [UIColor whiteColor];
        
        CGFloat marginLeft, marginTop, labelWidth, labelHeight;
        // 展示图片
        _img = [[UIImageView alloc] initWithFrame:CGRectMake(8, (MyCollectCell_Height - 65)/2, 80, 65)];
        _img.contentMode = UIViewContentModeScaleAspectFill;
        _img.clipsToBounds = YES;
        [self.contentView addSubview:_img];
        
        // 标题
        marginLeft = 100;
        marginTop = 0;
        labelWidth = SCREEN_SIZE_WIDTH - 110 - 90;
        labelHeight = 30;
        CGRect labelFrame = CGRectMake(marginLeft, marginTop, labelWidth, labelHeight);
        _titleLabel= [[UILabel alloc] initWithFrame:labelFrame];
        _titleLabel.backgroundColor = [UIColor clearColor];
        _titleLabel.font = [UIFont systemFontOfSize:15];
        _titleLabel.textColor = ColorDarkGray;
        _titleLabel.numberOfLines = 2;
        [self.contentView addSubview:_titleLabel];
        
        //质保
        _qlyGuar = [[UILabel alloc] initWithFrame:CGRectMake(SCREEN_SIZE_WIDTH - 40, _titleLabel.deFrameTop + 5, 30, 17)];
        _qlyGuar.text = @"质保";
        _qlyGuar.font = [UIFont systemFontOfSize:11];
        _qlyGuar.textAlignment = NSTextAlignmentCenter;
        _qlyGuar.backgroundColor = ColorTheme;
        _qlyGuar.textColor = [UIColor whiteColor];
        [self.contentView addSubview:_qlyGuar];
        
        //        会员卡
        _vipLabel = [[UILabel alloc] initWithFrame:CGRectMake(_qlyGuar.deFrameLeft - 30, _qlyGuar.deFrameTop, 20, 17)];
        _vipLabel.text = @"卡";
        _vipLabel.font = [UIFont systemFontOfSize:11];
        _vipLabel.textAlignment = NSTextAlignmentCenter;
        _vipLabel.textColor = [UIColor whiteColor];
        _vipLabel.backgroundColor = [QTools colorWithRGB:233 :113 :78];
        [self.contentView addSubview:_vipLabel];
        
        // 简介
        marginTop = _titleLabel.deFrameBottom;
        marginLeft = _titleLabel.deFrameLeft;
        labelFrame = CGRectMake(marginLeft, marginTop, labelWidth, labelHeight - 15);
         _descLabel= [[UILabel alloc] initWithFrame:labelFrame];
        _descLabel.backgroundColor = [UIColor clearColor];
        _descLabel.lineBreakMode = NSLineBreakByWordWrapping;
        _descLabel.numberOfLines = 0;
        _descLabel.textColor = [QTools colorWithRGB:149 :149 :149];
        _descLabel.font = [UIFont systemFontOfSize:15];
        [self.contentView addSubview:_descLabel];
        _descLabel.hidden = YES;
        
        //        会员低至多少
        _vipPriceLabel = [[UILabel alloc] initWithFrame:CGRectMake(_descLabel.deFrameLeft, _descLabel.deFrameBottom, _descLabel.deFrameWidth, _descLabel.deFrameHeight)];
        _vipPriceLabel.backgroundColor = [UIColor clearColor];
        _vipPriceLabel.font = [UIFont systemFontOfSize:12];
        _vipPriceLabel.textColor = [QTools colorWithRGB:233 :113 :78];
        [self.contentView addSubview:_vipPriceLabel];
        
        // 价格
        marginTop = 53;
        marginLeft = 100;
        labelFrame = CGRectMake(marginLeft, marginTop, labelWidth, labelHeight);
         _priceLabel= [[UILabel alloc] initWithFrame:labelFrame];
        NSString *price = @"0";
        NSString *retailPrice = @"0元";
        NSString *text = [NSString stringWithFormat:@"%@元   %@", price, retailPrice];
        NSMutableAttributedString *string = [[NSMutableAttributedString alloc] initWithString:text attributes:@{NSStrikethroughStyleAttributeName: @(NSUnderlineStyleNone)}];
        [string addAttributes:@{NSStrikethroughStyleAttributeName:@(NSUnderlineStyleSingle)} range:[text rangeOfString:retailPrice]];
        [string addAttribute:NSFontAttributeName value:[UIFont systemFontOfSize:18] range:[text rangeOfString:price]];
        [string addAttribute:NSForegroundColorAttributeName value:[QTools colorWithRGB:196 :0 :0] range:[text rangeOfString:price]];
        _priceLabel.textColor = [QTools colorWithRGB:149 :149 :149];
        _priceLabel.font = [UIFont systemFontOfSize:11];
        _priceLabel.attributedText = string;
        [self.contentView addSubview:_priceLabel];
        
        // 评分 & 销量
        marginLeft = 100;
        marginTop = 62;
        labelHeight = 15;
        labelFrame = CGRectMake(marginLeft, marginTop, SCREEN_SIZE_WIDTH - 110, labelHeight);
        _rateAndCountLabel= [[UILabel alloc] initWithFrame:labelFrame];
        _rateAndCountLabel.font = [UIFont systemFontOfSize:11];
        _rateAndCountLabel.textColor = [QTools colorWithRGB:149 :149 :149];
        _rateAndCountLabel.textAlignment = NSTextAlignmentRight;
        _rateAndCountLabel.backgroundColor = [UIColor clearColor];
        [self.contentView addSubview:_rateAndCountLabel];
        
        // SeparatorLine
#define selfHeight 87
#define selfWidth SCREEN_SIZE_WIDTH
        UIView *separatorLineView = [[UIView alloc] initWithFrame:CGRectMake(0, selfHeight- 1.0, selfWidth, 0.5)];
        separatorLineView.backgroundColor = ColorLine;
        [self.contentView addSubview:separatorLineView];
        [self awakeFromNib];
    }
    SDWebImageManager.sharedManager.imageDownloader.executionOrder = SDWebImageDownloaderLIFOExecutionOrder;
    return self;
}

- (void)awakeFromNib {
    // Initialization code
    
}

- (void)configureCellWithData:(NSArray *)arr andIndexPath:(NSIndexPath *)indexPath
{
    if (arr.count <= indexPath.row) {
        return ;
    }
    QMyFavoritedModel *model = [arr[indexPath.row] objectForKey:@"model"];
    //名称
    _titleLabel.text = model.subject;
    _titleLabel.frame = CGRectMake(100, 12, SCREEN_SIZE_WIDTH - 110 - 15, 50);
    [_titleLabel sizeToFit];

    //价格
    _price = [model.member_bidPrice stringValue];
    _retailPrice = [[model.price stringValue] stringByAppendingString:@"元"];
    if (_price == nil) {
        _price = @"0";
    }
    if (_retailPrice == nil) {
        _retailPrice = @"0";
    }
    
    //是否质保和是否会员
    if ([model.guaranteePeriod integerValue] == 0 && [model.ismember integerValue] == 0)
    {
        [_qlyGuar removeFromSuperview];
        [_vipLabel removeFromSuperview];
    }
    else if ([model.guaranteePeriod integerValue] == 0 && [model.ismember integerValue] == 1)
    {
        [_qlyGuar removeFromSuperview];
        _vipLabel.deFrameRight = SCREEN_SIZE_WIDTH - 10;
        [self.contentView addSubview:_vipLabel];
    }
    else if ([model.guaranteePeriod integerValue] != 0 && [model.ismember integerValue] == 0)
    {
        [self.contentView addSubview:_qlyGuar];
        [_vipLabel removeFromSuperview];
    }
    else if ([model.guaranteePeriod integerValue] != 0 && [model.ismember integerValue] == 1)
    {
        [self.contentView addSubview:_qlyGuar];
        [self.contentView addSubview:_vipLabel];
    }

    if ([model.minMemberPrice isEqualToString:@""]) {
        [_vipPriceLabel removeFromSuperview];
    }
    else{
        [self.contentView addSubview:_vipPriceLabel];
        _vipPriceLabel.text = [NSString stringWithFormat:@"%@",model.minMemberPrice];
    }
    
    NSString *text = [NSString stringWithFormat:@"%@元   %@", _price, _retailPrice];
    NSMutableAttributedString *string = [[NSMutableAttributedString alloc] initWithString:text attributes:@{NSStrikethroughStyleAttributeName: @(NSUnderlineStyleNone)}];
    [string addAttributes:@{NSStrikethroughStyleAttributeName:@(NSUnderlineStyleSingle)} range:NSMakeRange(text.length - _retailPrice.length, _retailPrice.length)];
    [string addAttribute:NSFontAttributeName value:[UIFont systemFontOfSize:18] range:[text rangeOfString:_price]];
    [string addAttribute:NSForegroundColorAttributeName value:ColorTheme range:[text rangeOfString:_price]];
    _priceLabel.textColor = [QTools colorWithRGB:149 :149 :149];
    _priceLabel.font = [UIFont systemFontOfSize:11];
    _priceLabel.attributedText = string;
    _rateAndCountLabel.text = [NSString stringWithFormat:@"已售%@",[model.salesVolume stringValue]];
    
    //图片缓存
    if (model.photoPath && ![model.photoPath isEqualToString:@""])
    {
        NSString *str = PICTUREHTTP(model.photoPath);
        [_img sd_setImageWithURL:[NSURL URLWithString:str]
                placeholderImage:[UIImage imageNamed:@"default_image"]
                         options:SDWebImageRefreshCached];
    }
    
    
}

- (void) setCheckImageViewCenter:(CGPoint)pt alpha:(CGFloat)alpha animated:(BOOL)animated
{
    if (animated)
    {
        [UIView beginAnimations:nil context:nil];
        [UIView setAnimationBeginsFromCurrentState:YES];
        [UIView setAnimationCurve:UIViewAnimationCurveEaseInOut];
        [UIView setAnimationDuration:0.3];
        
        m_checkImageView.center = pt;
        m_checkImageView.alpha = alpha;
        
        [UIView commitAnimations];
    }
    else
    {
        m_checkImageView.center = pt;
        m_checkImageView.alpha = alpha;
    }
}

- (void) setEditing:(BOOL)editting animated:(BOOL)animated
{
    if (self.editing == editting)
    {
        return;
    }
    
    [super setEditing:editting animated:animated];
    
    if (editting)
    {
        self.selectionStyle = UITableViewCellSelectionStyleNone;
        self.backgroundView = [[UIView alloc] init];
        self.backgroundView.backgroundColor = [UIColor whiteColor];
        self.textLabel.backgroundColor = [UIColor clearColor];
        self.detailTextLabel.backgroundColor = [UIColor clearColor];
        
        if (m_checkImageView == nil)
        {
            m_checkImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 45, MyCollectCell_Height)];
            m_checkImageView.image = [UIImage imageNamed:@"icon_collect_unselected"];
            m_checkImageView.userInteractionEnabled = YES;
            m_checkImageView.contentMode = UIViewContentModeCenter;
            UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(selectTap:)];
            [m_checkImageView addGestureRecognizer:tap];
            [self addSubview:m_checkImageView];
        }
        
        m_checkImageView.center = CGPointMake(-CGRectGetWidth(m_checkImageView.frame) * 0.5,
                                              CGRectGetHeight(self.bounds) * 0.5);
        m_checkImageView.alpha = 0.0;
        [self setCheckImageViewCenter:CGPointMake(20.5, CGRectGetHeight(self.bounds) * 0.5)
                                alpha:1.0 animated:animated];
    }
    else
    {
        self.selectionStyle = UITableViewCellSelectionStyleBlue;
        self.backgroundView = nil;
        
        if (m_checkImageView)
        {
            [self setCheckImageViewCenter:CGPointMake(-CGRectGetWidth(m_checkImageView.frame) * 0.5, 
                                                      CGRectGetHeight(self.bounds) * 0.5)
                                    alpha:0.0 
                                 animated:animated];
        }
    }
}

- (void)setIsChecked:(BOOL)isChecked
{
    if (isChecked)
    {
        m_checkImageView.image = [UIImage imageNamed:@"icon_collect_selected"];
    }
    else
    {
        m_checkImageView.image = [UIImage imageNamed:@"icon_collect_unselected"];
    }
    _isChecked = isChecked;
    
}

- (void)selectTap:(UIGestureRecognizer *)sender{
    self.isChecked = !self.isChecked;
    if (self.delegate &&[self.delegate respondsToSelector:@selector(setSelectforDelete:delete:)]) {
        [self.delegate setSelectforDelete:self delete:_isChecked];
    }
}

@end
