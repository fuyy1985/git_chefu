//
//  DHPage.h
//  DSSClient
//
//  Created by panyj on 14-9-15.
//  Copyright (c) 2014年 panyj. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "QDefine.h"

typedef NS_ENUM(NSInteger, QCacheType)
{
    kCacheTypeNone,//不缓存
    kCacheTypeCommon,//缓存,页面
    kCacheTypeAlways,//总是缓存
};

typedef NS_ENUM(NSInteger, QNavigationType)
{
    kNavigationTypeNone,     //没有导航栏
    kNavigationTypeNormal,   //普通导航栏
};

typedef NS_ENUM(NSInteger, QBottomMenuType)
{
    kBottomMenuTypeNone,     //没有导航栏
    kBottomMenuTypeNormal,   //普通导航栏
};

typedef NS_ENUM(NSInteger, QPageEventType)
{
    kPageEventViewCreate,//页面创建
    kPageEventViewDispose,//页面销毁或内存不足时,view析构事件
    kPageEventWillShow,
    kPageEventWillHide,
    kPageEventMainMenuExpand,//主菜单展开
    kPageEventMainMenuFold,//主菜单关闭
    kPageEventWillEnterFullScreenMode,//进入全屏竖屏模式
    kPageEventWillLeaveFullScreenMode,//取消全屏竖屏模式
};

@protocol QPage
- (UIView*)titleViewWithFrame:(CGRect)frame;
- (UIView*)viewWithFrame:(CGRect)frame;

- (QCacheType)pageCacheType;
- (QNavigationType)navigationType;
- (QBottomMenuType)bottomMenuType;

- (UIBarButtonItem*)pageLeftMenu;
- (UIBarButtonItem*)pageRightMenu;//右侧菜单
- (NSArray*)pageRightMenus;//右侧菜单(可多个目前限制2个)

- (void)setPageViewFrame:(CGRect)frame;
- (void)pageEvent:(QPageEventType)eventType;
- (BOOL)pageShouldAutorotate;
- (NSUInteger)pageSupportedInterfaceOrientations;
- (void)pageWillRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation
                                    duration:(NSTimeInterval)duration;

- (void)setActiveWithParams:(NSDictionary*)params;//方便页面激活时接收参数
#pragma mark -
#pragma mark touch event

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event;
- (void)touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event;
- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event;
- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event;

- (void)viewDidAppear:(BOOL)animated;
- (void)viewDidDisappear:(BOOL)animated;
- (void)viewDidLayoutSubviews;

@end

@interface PageView : UIView

@end

@interface QPage : NSObject<QPage>{
@public
    PageView   * _view;
}

@property (nonatomic,readonly) PageView  * view;

+ (id)createPage:(NSDictionary*)params;
- (BOOL)showOnTop;
- (NSString*)pageID;
@end
