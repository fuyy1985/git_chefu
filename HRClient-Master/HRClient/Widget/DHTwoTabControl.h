//
//  DHTwoTabControl.h
//  iDSSClient
//
//  Created by panyj on 14-3-15.
//  Copyright (c) 2014年 mobile. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol DHTwoTabControlDelegate <NSObject>
- (void)onClinkAtTabIndex:(NSInteger)_index;
@end

@interface DHTwoTabControl : UIView
{
    UIButton *btnLeft_;
    UIButton *btnright_;
}

@property(nonatomic,assign)id<DHTwoTabControlDelegate> delegate;

/**设置左右背景图片（高亮和非高亮）**/
@property(nonatomic,strong)NSString *strLeftImage_n;
@property(nonatomic,strong)NSString *strLeftImage_h;
@property(nonatomic,strong)NSString *strRightImage_n;
@property(nonatomic,strong)NSString *strRightImage_h;

/**设置字体颜色（高亮和非高亮）**/
@property(nonatomic,strong)UIColor *hColor;
@property(nonatomic,strong)UIColor *nColor;

/**设置背景颜色图片**/
@property(nonatomic,strong)NSString *strBackImage;

//set CurIndex
@property(nonatomic,assign)int nCurIndex;

/**设置左右标题**/
- (void)SetLeftTitle:(NSString*)_lTitle andRightTitle:(NSString*)_rTitle;

@end
