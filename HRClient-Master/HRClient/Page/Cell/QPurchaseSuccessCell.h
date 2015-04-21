//
//  QPurchaseSuccessCell.h
//  HRClient
//
//  Created by ekoo on 14/12/31.
//  Copyright (c) 2014年 panyj. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface QPurchaseSuccessCell : UITableViewCell

@property (nonatomic,strong)UILabel *headLabel;
@property (nonatomic,strong)UILabel *backLabel;

- (void)configureCellToModel:(NSArray *)arr andPath:(NSIndexPath *)indexPath;


@end
