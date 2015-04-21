//
//  QCityChangeeCell.h
//  HRClient
//
//  Created by ekoo on 14/12/30.
//  Copyright (c) 2014年 panyj. All rights reserved.
//

#import <UIKit/UIKit.h>

@class QCityChangeeCell;

@protocol QCityChangeeCellDelegate <NSObject>
@optional
/* 城市选中*/
- (void)citySelected:(QCityChangeeCell*)cell andCityIndex:(NSUInteger)index;
@end

@interface QCityChangeeCell : UITableViewCell
@property (nonatomic, weak) id<QCityChangeeCellDelegate> delegate;

- (void)configureCellForTableView:(NSArray *)localArr andRecent:(NSArray *)recentArr andHot:(NSArray *)hotArr andIndexPath:(NSIndexPath *)indexPath;

@end
