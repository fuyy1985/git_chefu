//
//  QBaseFilterView.h
//  HRClient
//
//  Created by chenyf on 14/12/28.
//  Copyright (c) 2014年 panyj. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface QBaseFilterView : UIView//UIGestureRecognizerDelegate

@property (nonatomic) UIView *menuView;
- (void) toggleMenu;
- (void) showMenu;
- (void) hideMenu;

@end
