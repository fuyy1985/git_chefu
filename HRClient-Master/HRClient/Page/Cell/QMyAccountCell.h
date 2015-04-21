//
//  QMyAccountCell.h
//  HRClient
//
//  Created by ekoo on 14/12/23.
//  Copyright (c) 2014年 panyj. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface QMyAccountCell : UITableViewCell
@property (nonatomic,strong)UILabel *nameLabel;
@property (nonatomic,strong)UILabel *moneyLabel;

- (void)configureCellToModel:(NSArray *)arr andIndexPath:(NSIndexPath *)indexPath;

@end
