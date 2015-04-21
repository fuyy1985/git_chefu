//
//  QNavigationBar.h
//  DSSClient
//
//  Created by panyj on 14-4-8.
//  Copyright (c) 2014年 panyj. All rights reserved.
//

#import <UIKit/UIKit.h>

@class QNavigationBar;

@protocol QNavigationBarDelegate
- (void)QNavigationBarLeftButtonTap:(QNavigationBar*)navigationBar;
@end


@interface QNavigationBar : UIView
{    
}

@property (nonatomic,assign)  id<QNavigationBarDelegate>   delegate;
@property (nonatomic,readonly)UIView                      *titleView;
@property (nonatomic,readonly)UIButton                    *leftButton;
@property (nonatomic,readonly)UIButton                    *rightButton;
@property (nonatomic,readonly)NSArray                     *rightButtons;

- (CGRect)titleViewFrame;

//inMenu:是否主菜单缓存页面，菜单缓存页面，最后一个页面左边是主菜单
- (void)resetContent:(NSArray*)items titleView:(UIView*)titleView ofMenu:(BOOL)inMenu;
@end
