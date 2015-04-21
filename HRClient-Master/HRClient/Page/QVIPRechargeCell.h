//
//  QVIPRechargeCell.h
//  HRClient
//
//  Created by ekoo on 14/12/8.
//  Copyright (c) 2014年 panyj. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface QVIPRechargeCell : UITableViewCell
@property (nonatomic,strong)UIImageView *selectImageView;

- (void)cofigureModelToCell:(NSArray *)arr andIndexPath:(NSIndexPath *)indexPath;
- (void)sendModelToImage1:(NSArray *)arr andRow:(NSInteger)row;

@end
