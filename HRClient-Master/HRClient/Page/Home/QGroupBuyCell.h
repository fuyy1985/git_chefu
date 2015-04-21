//
//  QGroupBuyCell.h
//  HRClient
//
//  Created by chenyf on 14/12/4.
//  Copyright (c) 2014年 panyj. All rights reserved.
//  

#import <UIKit/UIKit.h>
#import "QHomePageModel.h"
#import "QBusinessDetailResult.h"

@interface QGroupBuyCell : UITableViewCell

- (void)configureCellForBusinPage:(NSArray *)model1 andIndexPath:(NSIndexPath *)indexPath;

+(float)GetQGroupBuyCellHeight;

@end
