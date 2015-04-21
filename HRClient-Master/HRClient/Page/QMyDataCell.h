//
//  QMyDataCell.h
//  HRClient
//
//  Created by ekoo on 14/12/10.
//  Copyright (c) 2014年 panyj. All rights reserved.
//

#import <UIKit/UIKit.h>


@class QMyDataCell;

@protocol QMyDataCellDelegate <NSObject>
@optional
/* 昵称修改 */
- (void)setNick:(NSString*)nick;

@end

@interface QMyDataCell : UITableViewCell<UITextFieldDelegate>

@property (nonatomic, weak) id<QMyDataCellDelegate> delegate;

- (void)configurationCellWithModel:(NSArray*)arr andIndexPath:(NSIndexPath*)indexPath andPayPwd:(NSString *)myPayPwd;
- (void)beginEditNickName;

@end
