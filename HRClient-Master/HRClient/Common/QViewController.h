//
//  QViewController.h
//  DSSClient
//
//  Created by panyj on 14-9-15.
//  Copyright (c) 2014年 panyj. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "QPage.h"
#import "QNavigationBar.h"

@interface QViewController : UIViewController<QNavigationBarDelegate,UIAlertViewDelegate>{
}

@property (nonatomic,readonly) QNavigationBar           *navigationBar;
@property (nonatomic,readonly) UIInterfaceOrientation   toInterfaceOrientation;

+ (QViewController *)shareController;

//page
+ (QPage*)gotoPage:(NSString*)pageName withParam:(NSDictionary*)param;
+ (QPage*)findPage:(NSString*)pageName;
+ (QPage*)backPageWithParam:(NSDictionary*)param;

//action
+ (void)showMessage:(NSString*)message;
+ (void)setNeedFullScreen:(BOOL)need;
+ (BOOL)pageOnTop:(QPage*)page;
+ (BOOL)pageOnTopWithName:(NSString*)pageName;
+ (QPage*)topPage;

+ (void)initAndEnterMain;

/** 增加显示/隐藏状态栏接口
 *  页面在强转时,没有更新系统状态的状态,导致状态不正确
 */
+ (void)showStautsBar:(BOOL)isShown;
+ (void)showMessage:(NSString*)message lastSecond:(NSTimeInterval)second;

@end
