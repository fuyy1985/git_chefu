//
//  QOrderKeyCell.h
//  HRClient
//
//  Created by ekoo on 14/12/10.
//  Copyright (c) 2014年 panyj. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface QOrderKeyCell : UITableViewCell{
    BOOL m_checked;
}
@property (nonatomic,strong)UILabel     *topLabel;
@property (nonatomic,strong)UILabel     *backLabel;
@property (nonatomic,strong)UIImageView *m_checkImageView;

- (void)setChecked:(BOOL)checked;

- (void)transToCellDic:(NSArray*)arr andIndexPath:(NSInteger)indexPath;
- (void)sendModelToImage:(NSArray *)arr andRow:(NSInteger)row;

@end
