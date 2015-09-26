//
//  QVIPRechargeCell.h
//  HRClient
//
//  Created by ekoo on 14/12/8.
//  Copyright (c) 2014年 panyj. All rights reserved.
//

#import <UIKit/UIKit.h>


typedef enum _payType {
    payType_none = -1,
    payType_member = 0,
    payType_balance = 1,
    payType_aliPay = 2,
    payType_wxPay = 3,
    payType_bank = 4,
} payType;

@interface QVIPRechargeCell : UITableViewCell
@property (nonatomic,strong)UIImageView *selectImageView;

- (void)cofigureModelToCell:(NSArray *)arr andIndexPath:(NSIndexPath *)indexPath;
- (void)sendModelToImage1:(NSArray *)arr andRow:(NSInteger)row;

@end
