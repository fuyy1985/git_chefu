//
//  QGroupBuyDetailVIPPriceCell.h
//  HRClient
//
//  Created by chenyf on 14/12/28.
//  Copyright (c) 2014年 panyj. All rights reserved.
//

#import <UIKit/UIKit.h>

@class QGroupBuyDetailVIPPriceCell;
@protocol QGroupBuyDetailVIPPriceCellDelegate <NSObject>
- (void)QGroupBuyDetailVIPPriceCell:(QGroupBuyDetailVIPPriceCell *)categoryView didSelectRowAtIndexPath:(NSIndexPath *)indexPath;
- (void)reloadVIPPriceCell;
@end


@interface QGroupBuyDetailVIPPriceCell : UITableViewCell<UITableViewDelegate, UITableViewDataSource>
@property (nonatomic,weak) id<QGroupBuyDetailVIPPriceCellDelegate> delegate;
@property (nonatomic, strong) UITableView *listTableView;
@property (nonatomic, strong) NSArray *cardDetails;
@end
