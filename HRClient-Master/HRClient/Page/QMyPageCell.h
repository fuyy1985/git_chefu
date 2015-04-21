//
//  QMyPageCell.h
//  HRClient
//
//  Created by ekoo on 14/12/15.
//  Copyright (c) 2014年 panyj. All rights reserved.
//

#import <UIKit/UIKit.h>

#define CellHeight          (45)

@interface QMyPageCell : UITableViewCell

- (void)configureModelForCell:(NSArray *)imageArr andTitle:(NSArray *)titleArr andIndexPath:(NSIndexPath*)indexPath;

@end
