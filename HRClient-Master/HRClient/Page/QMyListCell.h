//
//  QMyListCell.h
//  HRClient
//
//  Created by ekoo on 14/12/11.
//  Copyright (c) 2014年 panyj. All rights reserved.
//

#import <UIKit/UIKit.h>

#define ListCellHeight      (86)

@class QMyListCell;

@protocol QMyListCellDelegate <NSObject>
@optional
/* 选中删除 */
- (void)setSelectforDelete:(QMyListCell*)cell delete:(BOOL)isDelete;

@end
@interface QMyListCell : UITableViewCell{
    UIImageView*	m_checkImageView;
//  BOOL			m_checked;
}

@property (nonatomic, weak) id<QMyListCellDelegate> delegate;

@property (nonatomic,assign)BOOL isChecked;

- (void)configureModelForCell:(NSArray *)arr andInexPath:(NSIndexPath *)indexPath;

@end
