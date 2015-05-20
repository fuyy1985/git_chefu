//
//  QMyListCell.m
//  HRClient
//
//  Created by ekoo on 14/12/11.
//  Copyright (c) 2014年 panyj. All rights reserved.
//

#import "QMyListCell.h"
#import "UIImageView+WebCache.h"
#import "QMyListDetailModel.h"

@interface QMyListCell ()

@property (nonatomic,strong)UILabel *titleLabel;
@property (nonatomic,strong)UIImageView *iconImageView;
@property (nonatomic,strong)UILabel *totalLabel;
@property (nonatomic,strong)UILabel *quantityLabel;
@property (nonatomic,strong)UILabel *varyLabel;
@property (nonatomic,strong)QMyListDetailModel *listModel;


@end

@implementation QMyListCell
- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
        [self awakeFromNib];
        CGFloat beforeW = 10.0;
        CGFloat topH = 10.0;
        CGFloat blank = 10.0;
//        84
//        icon图片
        CGFloat imageW = 80;
        CGFloat imageH = 64;
        _iconImageView = [[UIImageView alloc] initWithFrame:CGRectMake(beforeW, topH, imageW, imageH)];
        _iconImageView.contentMode = UIViewContentModeScaleAspectFill;
        _iconImageView.clipsToBounds = YES;
        [self.contentView addSubview:_iconImageView];
//        商家名字
        CGFloat titleW = SCREEN_SIZE_WIDTH - _iconImageView.frame.size.width - 2*blank;
        CGFloat titleH = 15;
        _titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(_iconImageView.frame.size.width + 2*blank, blank, titleW, titleH)];
        _titleLabel.backgroundColor = [UIColor clearColor];
        _titleLabel.font = [UIFont systemFontOfSize:17];
        [self.contentView addSubview:_titleLabel];
//        总价
        CGFloat erectH = 7;
        CGFloat totalW = 80;
        CGFloat totalH = 10;
        _totalLabel = [[UILabel alloc] initWithFrame:CGRectMake(_titleLabel.frame.origin.x,
                                                                _titleLabel.frame.origin.y + _titleLabel.frame.size.height + erectH + 10,
                                                                totalW, totalH)];
        _totalLabel.backgroundColor = [UIColor clearColor];
        _totalLabel.font = [UIFont systemFontOfSize:13];
        _totalLabel.textColor = [UIColor grayColor];
        [self.contentView addSubview:_totalLabel];
//        数量
        CGFloat quantityW = 60;
        CGFloat quantityH = 10;
        _quantityLabel = [[UILabel alloc] initWithFrame:CGRectMake(_totalLabel.frame.origin.x + _totalLabel.frame.size.width + erectH,
                                                                   _titleLabel.frame.origin.y + _titleLabel.frame.size.height + erectH + 10,
                                                                   quantityW, quantityH)];
        _quantityLabel.backgroundColor = [UIColor clearColor];
        _quantityLabel.font = [UIFont systemFontOfSize:13];
        _quantityLabel.textColor = [UIColor grayColor];
        [self.contentView addSubview:_quantityLabel];
//        状态
//        162  34
        CGFloat varyW = 70;
        CGFloat varyH = 25;
        _varyLabel = [[UILabel alloc] init];
        _varyLabel.backgroundColor = [UIColor clearColor];
        _varyLabel.frame = CGRectMake(SCREEN_SIZE_WIDTH - 80, _totalLabel.frame.origin.y + _totalLabel.frame.size.height , varyW, varyH);
        _varyLabel.textAlignment = NSTextAlignmentCenter;
        _varyLabel.layer.masksToBounds = YES;
        _varyLabel.layer.cornerRadius = 2.0;
        _varyLabel.font = [UIFont systemFontOfSize:13];
        [self.contentView addSubview:_varyLabel];
        
        UIView *lineView = [[UIView alloc] initWithFrame:CGRectMake(0, ListCellHeight - .5f, SCREEN_SIZE_WIDTH, .5f)];
        lineView.backgroundColor = ColorLine;
        [self.contentView addSubview:lineView];
    }
    return self;
}

- (void)awakeFromNib {
    // Initialization code
}

- (void)configureModelForCell:(NSArray *)arr andInexPath:(NSIndexPath *)indexPath{
    
    _listModel = arr[indexPath.row];
    
    //图片异步加载
    [_iconImageView sd_setImageWithURL:[NSURL URLWithString:PICTUREHTTP(NSString_No_Nil(_listModel.photo))]
                      placeholderImage:[UIImage imageNamed:@"default_image"]
                               options:SDWebImageRefreshCached];
    
    _titleLabel.text = _listModel.subject;
    _totalLabel.text = [NSString stringWithFormat:@"总价:%@",_listModel.total];
    _quantityLabel.text = [NSString stringWithFormat:@"数量:%@",[_listModel.quantity stringValue]];
    
    if ([[_listModel.status stringValue] isEqualToString:@"3"]) {
        _varyLabel.text = @"评价";
        _varyLabel.textColor = UIColorFromRGB(0xc40000);
        _varyLabel.layer.borderWidth = 1;
        _varyLabel.layer.borderColor = [QTools colorWithRGB:223 :181 :183].CGColor;
        _varyLabel.backgroundColor = [QTools colorWithRGB:255 :255 :255];
        //_varyLabel.textAlignment = NSTextAlignmentCenter;
    }else if ([[_listModel.status stringValue] isEqualToString:@"1"]){
        _varyLabel.text = @"付款";
        _varyLabel.backgroundColor  =[QTools colorWithRGB:246 :91 :10];
        _varyLabel.textColor = [QTools colorWithRGB:255 :255 :255];
        _varyLabel.layer.borderWidth = 0.0;
        //_varyLabel.textAlignment = NSTextAlignmentCenter;
    }else if ([[_listModel.status stringValue] isEqualToString:@"4"]){
        _varyLabel.text = @"退单";
        _varyLabel.textColor = [UIColor grayColor];
        _varyLabel.backgroundColor = [QTools colorWithRGB:255 :255 :255];
        _varyLabel.layer.borderWidth = 0.0;
        //_varyLabel.textAlignment = NSTextAlignmentRight;
    }
    else if([[_listModel.status stringValue] isEqualToString:@"2"]){
        _varyLabel.text = @"未消费";
        _varyLabel.textColor = UIColorFromRGB(0xc40000);
        _varyLabel.backgroundColor = [QTools colorWithRGB:255 :255 :255];
        _varyLabel.layer.borderWidth = 0.0;
        //_varyLabel.textAlignment = NSTextAlignmentRight;
    }
    else if([[_listModel.status stringValue] isEqualToString:@"5"]){
        _varyLabel.text = @"已评价";
        _varyLabel.textColor = [UIColor grayColor];
        _varyLabel.backgroundColor = [QTools colorWithRGB:255 :255 :255];
        _varyLabel.layer.borderWidth = 0.0;
        //_varyLabel.textAlignment = NSTextAlignmentRight;
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
            m_checkImageView = [[UIImageView alloc] initWithImage:IMAGEOF(@"icon_collect_unselected")];
            m_checkImageView.userInteractionEnabled = YES;
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


- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
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
