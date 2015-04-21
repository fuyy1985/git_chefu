//
//  QVIPCardRechargeCell.h
//  HRClient
//
//  Created by ekoo on 14/12/16.
//  Copyright (c) 2014年 panyj. All rights reserved.
//

#import <UIKit/UIKit.h>


#define QVIPCardRechargeCellHeight (35)

@interface QVIPCardRechargeCell : UITableViewCell
@property (nonatomic,strong)UIImageView *agreeImageView;
@property (nonatomic,strong)UIImageView *sureImageView;
- (void)configureModelForCell:(NSArray *)arr andIndexPath:(NSIndexPath *)indexPath;
- (void)configureImage:(NSArray *)arr;

@end
