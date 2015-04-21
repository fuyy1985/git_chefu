//
//  QGroupBuyDetailVIPPriceCell.m
//  HRClient
//
//  Created by chenyf on 14/12/28.
//  Copyright (c) 2014年 panyj. All rights reserved.
//  团购详细页 会员价格Cell

#import "QGroupBuyDetailVIPPriceCell.h"
#import "QVIPCardRechargeCell.h"
#import "QCardDetailModel.h"
#import "QHttpMessageManager.h"
#import "QViewController.h"

@interface QGroupBuyDetailVIPPriceCell ()

@end

@implementation QGroupBuyDetailVIPPriceCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        [self awakeFromNib];
        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(successGetCardDetails:) name:kCardDetails object:nil];
        
        _cardDetails = [QCardDetailModel defaultCardDetailsModel];
        if (_cardDetails && _cardDetails.count)
        {
            
        }
        else
        {
            [[QHttpMessageManager sharedHttpMessageManager] accessCardDetails];
        }
    }
    return self;
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self name:kCardDetails object:nil];
}

- (void)awakeFromNib {
    // Initialization code
    
    self.selectionStyle = UITableViewCellSelectionStyleNone;
    
    UITableView *listTableView = [[UITableView alloc] initWithFrame:CGRectMake(10, 0, SCREEN_SIZE_WIDTH - 10 * 2, 0) style:UITableViewStylePlain];
    listTableView.dataSource = self;
    listTableView.delegate = self;
    listTableView.scrollEnabled = NO;
    listTableView.layer.borderColor = [[QTools colorWithRGB:203 :203 :203] CGColor];
    listTableView.layer.borderWidth = .5;
    [self.contentView addSubview:listTableView];
    _listTableView = listTableView;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

#pragma mark - Notification
- (void)successGetCardDetails:(NSNotification*)noti
{
     _cardDetails = noti.object;
    [QCardDetailModel setCardDetailsModel:noti.object];
    
    if (self.delegate && [self.delegate respondsToSelector:@selector(reloadVIPPriceCell)]) {
        [self.delegate reloadVIPPriceCell];
    }
}

#pragma mark - UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return _cardDetails ? (_cardDetails.count+1) : 1;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return QVIPCardRechargeCellHeight;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    static NSString *listID = @"list_ID";
    QVIPCardRechargeCell * cell = [tableView dequeueReusableCellWithIdentifier:listID];
    if (cell == nil) {
        cell = [[QVIPCardRechargeCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:listID];
        cell.agreeImageView.image = nil;
    }
    if (indexPath.row == 0) {
        cell.userInteractionEnabled = NO;
    }
    
    [cell configureModelForCell:_cardDetails andIndexPath:indexPath];
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    //没有登录直接到快捷登录
    if (![QUser sharedQUser].isLogin)
    {
        QCardDetailModel *model = _cardDetails[indexPath.row - 1];
        
        [QViewController gotoPage:@"QNoAccountLogin" withParam:[[NSDictionary alloc] initWithObjectsAndKeys:
                                                                model,@"cardModel",
                                                                [NSNumber numberWithInt:1],@"buy_type",nil]];
    }
    //跳转到会员充值页面
    else if ([QUser sharedQUser].isVIP)
    {
        [QViewController gotoPage:@"QMyVIPCard" withParam:nil];
    }
    //购买界面
    else
    {
        if (indexPath.row < _cardDetails.count)
        {
            //直接到充值页面
            QCardDetailModel *model = _cardDetails[indexPath.row - 1];
            
            [QViewController gotoPage:@"QVIPCardChong" withParam:[[NSDictionary alloc]
                                                                  initWithObjectsAndKeys:model, @"cardModel",
                                                                  [NSNumber numberWithInteger:BuyType_vipCard],@"buy_type", nil]];
        }
    }
}


@end
