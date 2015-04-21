//
//  QBussinessCell.h
//  HRClient
//
//  Created by chenyf on 14/12/4.
//  Copyright (c) 2014年 panyj. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "QBusinessListModel.h"
#import "QBusinessDetailModel.h"

@interface QBussinessCell : UITableViewCell

- (void)configureCellForHomePage:(NSArray *)modelList andIndexPath:(NSIndexPath *)indexPath;
- (void)configureCellForBusinDetail:(QBusinessDetailModel *)model;

@end
