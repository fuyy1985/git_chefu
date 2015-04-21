//
//  QMyCollectCell.h
//  HRClient
//
//  Created by ekoo on 14/12/17.
//  Copyright (c) 2014年 panyj. All rights reserved.
//

#import <UIKit/UIKit.h>

@class dataModel;
@class QMyCollectCell;

@protocol QMyCollectCellDelegate <NSObject>
@optional
/* 选中删除 */
- (void)setSelectforDelete:(QMyCollectCell*)cell delete:(BOOL)isDelete;

@end

@interface QMyCollectCell : UITableViewCell{
    
@public
    UIImageView*	m_checkImageView;
}

@property (nonatomic, weak) id<QMyCollectCellDelegate> delegate;
@property (nonatomic, strong)dataModel *cellData;
@property (nonatomic, assign)BOOL isChecked;

- (void)configureCellWithData:(NSArray *)arr andIndexPath:(NSIndexPath *)indexPath;

@end
