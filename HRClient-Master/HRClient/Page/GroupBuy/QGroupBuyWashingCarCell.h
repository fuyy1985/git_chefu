//
//  QGroupBuyWashingCarCell.h
//  HRClient
//
//  Created by chenyf on 14/12/10.
//  Copyright (c) 2014年 panyj. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface QGroupBuyCellHeadView : UITableViewHeaderFooterView
- (instancetype)initWithReuseIdentifier:(NSString *)reuseIdentifier andRect:(CGRect)frame;
- (void)setCompanyName:(NSString*)companyName andRegionName:(NSString*)regionName andDistance:(NSNumber*)distance;

@end

@interface QGroupBuyWashingCarCell : UITableViewCell

- (void)configureCellForWash:(NSArray *)arr andIndexPath:(NSIndexPath *)indexPath;

@end
