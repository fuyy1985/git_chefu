//
//  QGroupBuyWashingCarCell.m
//  HRClient
//
//  Created by chenyf on 14/12/10.
//  Copyright (c) 2014年 panyj. All rights reserved.
//  团购（洗车）cell

#import "QGroupBuyWashingCarCell.h"
#import "QHomePageModel.h" 
#import "UIImageView+WebCache.h"
#import "QRegularHelp.h"
#import "QLocationManager.h"

@interface QGroupBuyCellHeadView ()
@property (nonatomic, strong) UILabel *companyLabel;
@property (nonatomic, strong) UILabel *areaLabel;
@property (nonatomic, strong) UIImageView *iconLocationView;
@property (nonatomic, strong) UILabel *lbDistance;

@end

@implementation QGroupBuyCellHeadView

- (instancetype)initWithReuseIdentifier:(NSString *)reuseIdentifier andRect:(CGRect)frame
{
    self = [super initWithReuseIdentifier:reuseIdentifier];
    if (self) {
        
        self.frame = frame;
        self.contentView.backgroundColor = [UIColor whiteColor];
        //商家信息
        _companyLabel = [[UILabel alloc] init];
        _companyLabel.font = [UIFont boldSystemFontOfSize:17];
        _companyLabel.textColor = ColorDarkGray;
        [self addSubview:_companyLabel];
        
        // 位置图标
        UIImageView *imageView = [[UIImageView alloc] initWithImage:IMAGEOF(@"location_cell")];
        [self addSubview:imageView];
        _iconLocationView = imageView;
        
        //距离
        UILabel *label = [[UILabel alloc] init];
        label.font = [UIFont systemFontOfSize:12];
        label.textColor = [QTools colorWithRGB:149 :149 :149];
        [self addSubview:label];
        _lbDistance = label;
        
        //城区
        UILabel *areaLabel = [[UILabel alloc] init];
        areaLabel.font = [UIFont systemFontOfSize:12];
        areaLabel.textColor = [QTools colorWithRGB:149 :149 :149];
        [self addSubview:areaLabel];
        _areaLabel = areaLabel;
        
        // 分割线
        UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, self.deFrameHeight - 0.5, self.deFrameWidth, .5f)];
        view.backgroundColor = ColorLine;
        [self addSubview:view];
    }
    
    return self;
}

- (void)setCompanyName:(NSString*)companyName andRegionName:(NSString*)regionName andDistance:(NSNumber*)distance
{
    if ([QLocationManager sharedInstance].geoResult)
    {
        _lbDistance.text = [QRegularHelp distanceToNSString:distance];
        [_lbDistance sizeToFit];
        _lbDistance.deFrameTop = (self.deFrameHeight - _lbDistance.deFrameHeight)/2;
        _lbDistance.deFrameRight = self.deFrameWidth - 3;

        _iconLocationView.deFrameRight = _lbDistance.deFrameLeft - 3;
        _iconLocationView.deFrameTop = (self.deFrameHeight - _iconLocationView.deFrameHeight)/2;
    }
    else
    {
        _lbDistance.deFrameWidth = 0;
        _iconLocationView.deFrameLeft = self.deFrameWidth;
    }
    
    _iconLocationView.hidden = _lbDistance.deFrameWidth ? NO : YES;
    
    _areaLabel.text = regionName;
    [_areaLabel sizeToFit];
    _areaLabel.deFrameTop = (self.deFrameHeight - _areaLabel.deFrameHeight)/2;
    _areaLabel.deFrameRight = MIN(_iconLocationView.deFrameLeft - 3, self.deFrameWidth - 10);
    
    _companyLabel.text = companyName;
    _companyLabel.deFrameTop = 0;
    _companyLabel.deFrameLeft = 10;
    _companyLabel.deFrameHeight = self.deFrameHeight;
    _companyLabel.deFrameWidth = _areaLabel.deFrameLeft - _companyLabel.deFrameLeft;
}

@end


@interface QGroupBuyWashingCarCell ()
@property (nonatomic,strong)UIImageView *img;
@property (nonatomic,strong)UILabel *descLabel;
@property (nonatomic,strong)UILabel *granteeLabel;
@property (nonatomic,strong)UILabel *isMemberLabel;
@property (nonatomic,strong)UILabel *lowestPriceLabel;
@property (nonatomic,strong)UILabel *priceLabel;
@property (nonatomic,strong)UILabel *rateAndCountLabel;
@property (nonatomic,copy)NSString *price;
@property (nonatomic,copy)NSString *retailPrice;

@end

@implementation QGroupBuyWashingCarCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
        
        [self.contentView.subviews makeObjectsPerformSelector:@selector(removeFromSuperview)];
        self.selectionStyle = UITableViewCellSelectionStyleNone;
        
        // Configure the self...
        
        CGFloat marginLeft, marginTop, labelWidth, labelHeight;
        
        // 展示图片
        _img = [[UIImageView alloc] initWithFrame:CGRectMake(7.5, 11, 80, 65)];
        _img.contentMode = UIViewContentModeScaleAspectFill;
        _img.clipsToBounds = YES;
        [self.contentView addSubview:_img];
        
        // 标题
        marginLeft = 100;
        marginTop = 0;
        labelWidth = 210;
        labelHeight = 30;
        CGRect labelFrame = CGRectMake(marginLeft, marginTop, labelWidth, labelHeight);
        _descLabel = [[UILabel alloc] initWithFrame:labelFrame];
        _descLabel.backgroundColor = [UIColor clearColor];
        _descLabel.lineBreakMode = NSLineBreakByWordWrapping;
        _descLabel.numberOfLines = 0;
        _descLabel.textColor = [QTools colorWithRGB:149 :149 :149];
        _descLabel.font = [UIFont systemFontOfSize:15];
        [self.contentView addSubview:_descLabel];
        
        _granteeLabel = [[UILabel alloc] initWithFrame:CGRectMake(SCREEN_SIZE_WIDTH - 40, _descLabel.deFrameTop + 5, 30, 17)];
        _granteeLabel.backgroundColor = [UIColor clearColor];
        _granteeLabel.font = [UIFont systemFontOfSize:10];
        _granteeLabel.textAlignment = NSTextAlignmentCenter;
        _granteeLabel.textColor = ColorDarkGray;
        [self.contentView addSubview:_granteeLabel];
        
        //是否支持会员卡
        _isMemberLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 5, 20, 20)];
        _isMemberLabel.backgroundColor = [UIColor colorWithRed:1 green:114/255.0 blue:0 alpha:1];
        _isMemberLabel.textColor = [UIColor whiteColor];
        _isMemberLabel.font = [UIFont systemFontOfSize:11];
        _isMemberLabel.text = @" 卡 ";
        _isMemberLabel.layer.cornerRadius = 2;
        _isMemberLabel.layer.masksToBounds = YES;
        [_isMemberLabel sizeToFit];
        _isMemberLabel.deFrameHeight = 20;
        [self.contentView addSubview:_isMemberLabel];
        _isMemberLabel.deFrameRight = SCREEN_SIZE_WIDTH - 10;
        
        // 会员最低价
        marginTop = 33;
        labelFrame = CGRectMake(marginLeft, marginTop, labelWidth, labelHeight);
        _lowestPriceLabel = [[UILabel alloc] initWithFrame:labelFrame];
        _lowestPriceLabel.font = [UIFont systemFontOfSize:12];
        _lowestPriceLabel.textColor = [QTools colorWithRGB:233 :113 :78];
        [self.contentView addSubview:_lowestPriceLabel];
        
        // 价格
        marginTop = 53;
        marginLeft = 100;
        labelFrame = CGRectMake(marginLeft, marginTop, labelWidth, labelHeight);
        _priceLabel = [[UILabel alloc] initWithFrame:labelFrame];
        [self.contentView addSubview:_priceLabel];
        
        // 评分 & 销量
        marginLeft = 100;
        marginTop = 62;
        labelHeight = 15;
        labelFrame = CGRectMake(marginLeft, marginTop, labelWidth, labelHeight);
        _rateAndCountLabel = [[UILabel alloc] initWithFrame:labelFrame];
        _rateAndCountLabel.font = [UIFont systemFontOfSize:11];
        _rateAndCountLabel.textColor = [QTools colorWithRGB:149 :149 :149];
        _rateAndCountLabel.textAlignment = NSTextAlignmentRight;
        [self.contentView addSubview:_rateAndCountLabel];
        
        // SeparatorLine
#define selfHeight 86
#define selfWidth SCREEN_SIZE_WIDTH        
        [self awakeFromNib];
    }
    SDWebImageManager.sharedManager.imageDownloader.executionOrder = SDWebImageDownloaderLIFOExecutionOrder;
    return self;
}

- (void)awakeFromNib {
    // Initialization code
    
    
}

- (void)configureCellForWash:(NSArray *)arr andIndexPath:(NSIndexPath *)indexPath{
    
    if (indexPath.section >= arr.count) {
        return;
    }
    
    QProductModel *model = arr[indexPath.section];
    
    NSString *str = PICTUREHTTP(model.photoPath);
    RunOnMainThread([_img sd_setImageWithURL:[NSURL URLWithString:str]
                            placeholderImage:[UIImage imageNamed:@"default_image"]
                                     options:SDWebImageRetryFailed|(indexPath.row == 0) ? SDWebImageRefreshCached : 0])

    _descLabel.text = model.subject;
    _descLabel.deFrameWidth = (![model.ismember boolValue]) ? (SCREEN_SIZE_WIDTH - _descLabel.deFrameLeft - 10) : (_isMemberLabel.deFrameLeft - _descLabel.deFrameLeft - 2);
    
    //是否质保和是否会员
    _granteeLabel.attributedText = [QRegularHelp guaranteeStringbyPeriod:[model.guaranteePeriod integerValue]];
    
    [_granteeLabel sizeToFit];
    _granteeLabel.deFrameRight = SCREEN_SIZE_WIDTH - 5;
    _descLabel.deFrameWidth -= _granteeLabel.deFrameWidth;
    
    _isMemberLabel.hidden = ![model.ismember boolValue];
    
    if (!model.minMemberPrice || [model.minMemberPrice isEqualToString:@""]) {
        _lowestPriceLabel.hidden = YES;
    }else{
        _lowestPriceLabel.hidden = NO;
        _lowestPriceLabel.text = [NSString stringWithFormat:@"%@",model.minMemberPrice];
    }
    
    _price = [model.member_bidPrice stringValue];
    _retailPrice = [NSString stringWithFormat:@" %@元", [model.price stringValue]];
    NSString *text = [NSString stringWithFormat:@"%@元   %@", _price, _retailPrice];
    NSMutableAttributedString *string = [[NSMutableAttributedString alloc] initWithString:text attributes:@{NSStrikethroughStyleAttributeName: @(NSUnderlineStyleNone)}];
    [string addAttributes:@{NSStrikethroughStyleAttributeName:@(NSUnderlineStyleSingle)} range:[text rangeOfString:_retailPrice]];
    [string addAttribute:NSFontAttributeName value:[UIFont systemFontOfSize:16] range:[text rangeOfString:_price]];
    [string addAttribute:NSForegroundColorAttributeName value:ColorTheme range:[text rangeOfString:_price]];
    _priceLabel.textColor = [QTools colorWithRGB:149 :149 :149];
    _priceLabel.font = [UIFont systemFontOfSize:11];
    _priceLabel.attributedText = string;
    /*
    _rateAndCountLabel.text = [NSString stringWithFormat:@"%@分   已售%@", model.evaluateAvgScore, model.salesVolume];
    */
    _rateAndCountLabel.text = [NSString stringWithFormat:@"已售%@", model.salesVolume];
    
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
