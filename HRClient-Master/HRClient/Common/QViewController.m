//
//  QViewController.m
//  DSSClient
//
//  Created by panyj on 14-9-15.
//  Copyright (c) 2014年 panyj. All rights reserved.
//

#import "QViewController.h"
#import "QDefine.h"
#import "QLoginPage.h"
#import "QConfigration.h"
#import "QNavigationBar.h"
#import <objc/runtime.h>
#import "QMainMenuView.h"
#import "UIDevice+Resolutions.h"
#import "QBottomMenuView.h"
#import "SYSafeCategory.h"
#import "QGuidepageController.h"

#define PAGEOF(X)   ([_shareViewController findPageInternal:X])
#define ANIMATION_EXPAND_MAINMENU    @"kAnimationExpandMainMenu"
#define ANIMATION_SWITCH_PAGE        @"kAnimationSwitchPage"
#define ANIMATION_FULLSCREEN         @"kAnimationFullScreen"

@interface QViewController ()<GuideViewDelegate>
{
    QGuidepageController *_guideViewController;
}
@property (nonatomic,strong) QMainMenuView        *mainMenu;
@property (nonatomic,strong) NSMutableArray       *pageStack;
@property (nonatomic,strong) NSMutableDictionary  *pageCache;       //永久缓存
@property (nonatomic,copy)   NSString             *mainMenuID;
@property (nonatomic,strong) UIControl            *maskView;        //在主菜单展开时,屏蔽对页面的操作,处理事件
@property (nonatomic,assign) BOOL                  enterMain;       //是否已经进入主菜单界面
@property (nonatomic,strong) UIView               *contentView;     //主视图
@property (nonatomic,strong) NSString             *presentAniKey;   //当前动画
@property (nonatomic,strong) QBottomMenuView      *btMenuView;      //底部菜单
@end

static QViewController * _shareViewController = nil;

@implementation QViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    [SYSafeCategory callSafeCategory];
    _pageCache = [[NSMutableDictionary alloc] initWithCapacity:16];//Page缓存
    // status bar
    CGFloat yOff = 0.0;
    if (IOSVERSION > 6.9)
    {
        yOff = SYS_STATUSBAR_HEIGHT;
        
        //状态栏背景
        CALayer * layer = [CALayer layer];
        layer.frame = CGRectMake(-MAINMENU_SIZE_WIDTH, 0, SCREEN_SIZE_WIDTH+MAINMENU_SIZE_WIDTH+120, SYS_STATUSBAR_HEIGHT);
        layer.backgroundColor = UIColorFromRGB(0xc40000).CGColor;
        [self.view.layer addSublayer:layer];
    }
    
    //不包含状态栏的区域视图
    _contentView = [[UIView alloc] initWithFrame:[self contentViewFrameOf:self.interfaceOrientation]];
    _contentView.backgroundColor = [QTools colorWithRGB:238 :238 :238];
    [self.view addSubview:_contentView];
    
    //navigationBar
    _navigationBar = [[QNavigationBar alloc] initWithFrame:CGRectMake(0, 0, SCREEN_SIZE_WIDTH, VIEW_NAVBAR_HEIGHT)];
    _navigationBar.delegate = self;
    _navigationBar.hidden = YES;
    [_contentView addSubview:_navigationBar];
    
    //底部菜单
    _btMenuView = [[QBottomMenuView alloc]initWithFrame:CGRectMake(0, _contentView.frame.size.height+100, SCREEN_SIZE_WIDTH, VIEW_NAVBAR_HEIGHT)];
    _btMenuView.delegate = (id<QBottomMenuDelegate>)self;
    [_contentView addSubview:_btMenuView];
    
    //左边弹出主菜单
    _mainMenu = [[QMainMenuView alloc] initWithFrame:CGRectMake(-MAINMENU_SIZE_WIDTH, yOff,
                                          MAINMENU_SIZE_WIDTH, SCREEN_SIZE_HEIGHT - yOff)];
    _mainMenu.delegate = self;
    
    //阻止页面上的事件发生当菜单展开的时候
    _maskView = [[UIControl alloc] initWithFrame:CGRectMake(0, VIEW_NAVBAR_HEIGHT,
                                            SCREEN_SIZE_WIDTH, SCREEN_SIZE_HEIGHT-VIEW_NAVBAR_HEIGHT)];
    _maskView.backgroundColor = [UIColor blackColor];
    _maskView.alpha = 0.0;
    [_maskView addTarget:self action:@selector(onMaskViewTouched:) forControlEvents:UIControlEventTouchUpInside];
    
    /* 目前暂时不需要 - 后续根据需求增加
    //add gesture
    UISwipeGestureRecognizer * swipeGesture = [[UISwipeGestureRecognizer alloc]
                                               initWithTarget:self action:@selector(onSwipForMainMenu:)];
    swipeGesture.direction = UISwipeGestureRecognizerDirectionLeft;
    [_navigationBar addGestureRecognizer:swipeGesture];
    
    swipeGesture = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(onSwipForMainMenu:)];
    swipeGesture.direction = UISwipeGestureRecognizerDirectionRight;
    [_navigationBar addGestureRecognizer:swipeGesture];*/
    
    // start
    [self performSelectorOnMainThread:@selector(launchStart) withObject:nil waitUntilDone:NO];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    
    // Dispose of any resources that can be recreated.
    NSArray * array = [_pageCache allValues];
    for (QPage * page in array)
    {
        [QViewController disposeViewOfPage:page];
    }
}

+ (QViewController*)shareController
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _shareViewController = [[QViewController alloc] init];
    });
    return _shareViewController;
}

- (CGRect)contentViewFrameOf:(UIInterfaceOrientation)orient
{
    CGFloat scrWidth = SCREEN_SIZE_WIDTH;
    CGFloat scrHeight= SCREEN_SIZE_HEIGHT;
    
    CGRect rectContent;
    
    //如果是横屏情况，则全屏显示
    if (UIInterfaceOrientationIsLandscape(orient))
    {
        rectContent = CGRectMake(0, 0, scrHeight, scrWidth);
    }
    else
    {
        CGFloat yOff = 0.0;
        if (IOSVERSION > 6.9) {
            yOff = SYS_STATUSBAR_HEIGHT;
        }
        rectContent = CGRectMake(0, yOff, scrWidth, scrHeight-SYS_STATUSBAR_HEIGHT);
    }
    return rectContent;
}

- (CGRect)pageViewFrameOf:(UIInterfaceOrientation)orient
{
    CGRect rectView = [self contentViewFrameOf:orient];//获取除状态栏的可视区域
    rectView.origin.y = 0.0;
    
    if (UIInterfaceOrientationIsPortrait(orient))
    {
        QPage *curPage = PAGEOF([_pageStack lastObject]);
        QNavigationType navType = [curPage navigationType];
        
        if (kNavigationTypeNormal == navType && _navigationBar.frame.origin.y>=0.0)
        {
            rectView.origin.y = VIEW_NAVBAR_HEIGHT;
            rectView.size.height -= VIEW_NAVBAR_HEIGHT;
        }
        
        QBottomMenuType btMenuType = [curPage bottomMenuType];
        if (btMenuType == kBottomMenuTypeNormal)
        {
            //再减去44
            rectView.origin.y = VIEW_NAVBAR_HEIGHT;
            rectView.size.height -= VIEW_NAVBAR_HEIGHT;
        }
    }
    return rectView;
}

#pragma mark - GuideView
- (void)showGuideView
{
    _guideViewController = [[QGuidepageController alloc] init];
    CGRect frame = _guideViewController.view.frame;
    frame.origin.y = 0;
    _guideViewController.view.frame = frame;
    _guideViewController.delegate = self;
    [self.view addSubview:_guideViewController.view];
}

- (void)closeGuideView
{
    if (_guideViewController && [_guideViewController isViewLoaded]) {
        [_guideViewController.view removeFromSuperview];
    }
    _guideViewController = nil;
}

#pragma mark Alert

+ (void)showMessage:(NSString*)message
{
    dispatch_async(dispatch_get_main_queue(),
        ^(){
            [ASRequestHUD showErrorWithStatus:message];
        });
}


- (void)dismissAlert:(UIAlertView*)alert
{
    [alert dismissWithClickedButtonIndex:0 animated:YES];
}

#pragma mark -
#pragma mark Page Operation

- (void)launchStart
{
    [_shareViewController exitMainMenu];
    [QViewController gotoPage:@"QHomePage" withParam:nil];
    
    NSDictionary *infoList = [[NSBundle mainBundle] infoDictionary];
    NSString *guideVersion = [infoList objectForKey:GuideViewVersion];
    NSString *guideShowVersion = [ASUserDefaults objectForKey:GuideViewVersion];
    if (guideShowVersion && [guideShowVersion compare:guideVersion options:NSNumericSearch] != NSOrderedAscending)
    {
        
    }
    else
    {
        [self showGuideView];
        [ASUserDefaults setObject:guideVersion forKey:GuideViewVersion];
    }
}

//将newPage放至堆栈顶部，对当前显示页做退出处理
- (void)navigateToPage:(NSString*)newPage
{
    //非由主菜单切换至当前页面,对当前页面做退出处理
    QPage * presentPage = nil;
    if (_pageStack.count > 0)
    {
        NSString * lastPage = [_pageStack lastObject];
       if ([newPage isEqualToString:lastPage]) {
           return;
       }
       presentPage = PAGEOF(lastPage);
    }
    
    if(presentPage)
    {
        QCacheType cacheType = [presentPage pageCacheType];
        if(cacheType == kCacheTypeNone)
        {//
            [self popPage];
        }
        else
        {
            [presentPage pageEvent:kPageEventWillHide];
            [presentPage.view removeFromSuperview];
        }
    }
    
    //将已经存在于内存里的相同缓存页面移至最后
    NSInteger nIndex = [self indexOfPage:newPage];
    if (nIndex == NSNotFound)//新加页面
    {
        [_pageStack addObject:newPage];
    }
    else
    {
        nIndex = _pageStack.count-1 - nIndex;
        while (nIndex>0)
        {
            [self internalRemoveLastPage];
            --nIndex;
        }
    }
    
    [self presentPage];
}


- (void)setStatusBarHide:(BOOL)toHide
{
    if (toHide) {
        [UIApplication sharedApplication].statusBarHidden = YES;
        
        if ([self respondsToSelector:@selector(setNeedsStatusBarAppearanceUpdate)])
        {//iOS7隐藏电池栏
            _toInterfaceOrientation = UIInterfaceOrientationLandscapeLeft;
            [self setNeedsStatusBarAppearanceUpdate];
        }
    }
    else
    {
        [UIApplication sharedApplication].statusBarHidden = NO;
        
        if ([self respondsToSelector:@selector(setNeedsStatusBarAppearanceUpdate)])
        {// iOS7显示状态栏
            _toInterfaceOrientation = UIInterfaceOrientationPortrait;
            [self setNeedsStatusBarAppearanceUpdate];
        }
    }
}

- (void)ifForceViewControllerRotate
{
    UIInterfaceOrientation orient = self.interfaceOrientation;
    
    if (UIInterfaceOrientationIsPortrait(orient))
    {//portrait are supported by all pages
        
        UIDeviceOrientation devOrient = [UIDevice currentDevice].orientation;
        if (UIDeviceOrientationIsLandscape(devOrient)) {
            QPage * newPage = PAGEOF([_pageStack lastObject]);
            NSUInteger orts = [newPage pageSupportedInterfaceOrientations];
            if (orts & (1 << UIInterfaceOrientationLandscapeLeft))//支持横屏
            {
                [UIViewController attemptRotationToDeviceOrientation];
                
                [self setStatusBarHide:YES];
            }
        }
        return;
    }
    
    [self setStatusBarHide:NO];
    //横屏状态下,不支持横屏的页面操作
    UIWindow * window = [UIApplication sharedApplication].keyWindow;
    
    window.rootViewController = nil;
    
    window.rootViewController = [QViewController shareController];    
}

//设置某一页面为激活状态
- (void)presentPage
{
    [self ifForceViewControllerRotate];

    QPage * newPage = PAGEOF([_pageStack lastObject]);
    if (newPage == nil) {
        NSAssert(newPage, @"Page where gone?");
        return;
    }
    
    //导航栏
    QNavigationType navType = [newPage navigationType];
    if (kNavigationTypeNormal == navType)
    {
        UINavigationItem * navItem = [[UINavigationItem alloc] initWithTitle:@""];
        UIBarButtonItem * leftButton = [newPage pageLeftMenu];
        if (leftButton) {
            navItem.leftBarButtonItem = leftButton;
        }
        
        UIBarButtonItem * rightButton = [newPage pageRightMenu];
        if (rightButton) {
            navItem.rightBarButtonItem = rightButton;
        }
        
        NSArray *rightButtons = [newPage pageRightMenus];
        if(rightButtons)
        {
            navItem.rightBarButtonItems = rightButtons;
        }
        
        NSArray * navItems = nil;
        if (_pageStack.count > 1)
        {
            UINavigationItem * tmpItem = [[UINavigationItem alloc] initWithTitle:@""];
            navItems = [NSArray arrayWithObjects:tmpItem,navItem, nil];
        }
        else
        {
            navItems = [NSArray arrayWithObjects:navItem, nil];
        }
        //title view
        CGRect frmTitle = [_navigationBar titleViewFrame];
        UIView * titleView = [newPage titleViewWithFrame:frmTitle];
        
        [_navigationBar resetContent:navItems titleView:titleView ofMenu:self.enterMain];
        
        if (UIInterfaceOrientationIsPortrait(self.interfaceOrientation))
        {
            _navigationBar.hidden = NO;
        }
    }
    else
    {
        _navigationBar.hidden = YES;
    }
    
    //底部菜单栏
    QBottomMenuType btMenuType = [newPage bottomMenuType];
    if (btMenuType == kBottomMenuTypeNormal)
    {
        [_contentView bringSubviewToFront:_btMenuView];
        _btMenuView.frame = CGRectMake(0, _contentView.frame.size.height - VIEW_NAVBAR_HEIGHT,
                                                                       SCREEN_SIZE_WIDTH, VIEW_NAVBAR_HEIGHT);
    }
    else
    {
        _btMenuView.frame = CGRectMake(0, _contentView.frame.size.height+100, SCREEN_SIZE_WIDTH, VIEW_NAVBAR_HEIGHT);
    }
    
    _contentView.frame = [self contentViewFrameOf:self.interfaceOrientation];
    
    //view
    CGRect rectView = [self pageViewFrameOf:self.interfaceOrientation];
    UIView * tempView = newPage.view;
    if (tempView == nil) {
        char  sMethodType[64] = "v@:";
        strcat(sMethodType, @encode(CGRect));
        
        NSMethodSignature * ms = [NSMethodSignature signatureWithObjCTypes:sMethodType];
        NSInvocation * inv = [NSInvocation invocationWithMethodSignature:ms];
        [inv setSelector:NSSelectorFromString(@"private_viewWithFrame:")];
        [inv setArgument:&rectView atIndex:2];
        [inv invokeWithTarget:newPage];
        
        tempView = newPage.view;
    }
    else
    {
        [newPage setPageViewFrame:rectView];
    }

    [_contentView addSubview:tempView];
    
    [newPage pageEvent:kPageEventWillShow];
}

//stack operation
- (void)popPage
{
    if ([_pageStack count] < 1)
    {
         NSLog(@"no page can be pop");
        return;
    }
    
    NSString * lastPage = [_pageStack lastObject];
    QPage * removePage = PAGEOF(lastPage);
    if (removePage)
    {
        [removePage pageEvent:kPageEventWillHide];
        [removePage.view removeFromSuperview];
        [self internalRemoveLastPage];
    }
}

- (void)goBack
{
    [self popPage];
    [self presentPage];
    [self addAnimation:NO];
}


//找出栈中的页面位置
- (NSUInteger)indexOfPage:(NSString * )page
{
    return [_pageStack indexOfObject:page];
}

- (QPage *)findPageInternal:(NSString*)pageName
{
    if (pageName != nil)
        return [_pageCache objectForKey:pageName];
    else
        return nil;
}

+ (QPage *)findPage:(NSString*)pageName
{
    return [_shareViewController findPageInternal:pageName];
}

- (void)internalRemoveLastPage
{
    NSString  * lastPage = [_pageStack lastObject];
    if (lastPage) {
        [_pageStack removeLastObject];
        //确认堆栈中没有引用此页面显示后，判断是否要从页面缓存里删除
        if (NSNotFound == [self indexOfPage:lastPage]) {
            QPage * page = [self findPageInternal:lastPage];
            QCacheType cacheType = [page pageCacheType];
            if (cacheType != kCacheTypeAlways) {
                [QViewController disposeViewOfPage:page];
                [_pageCache removeObjectForKey:lastPage];
            }
        }
    }
}


- (QPage*)backPageWithParamInteral:(NSDictionary*)param
{
    [self popPage];
    
    if (_pageStack.count == 0) {
        return nil;
    }
    
    QPage * page = PAGEOF([_pageStack lastObject]);
    [page setActiveWithParams:param];
    
    [self presentPage];
    [self addAnimation:NO];
    
    return page;
}

- (void)setNeedFullScreenInteral:(BOOL)need
{
    if (UIInterfaceOrientationIsLandscape(self.interfaceOrientation)) {
        return;
    }
    
    if (need)
    {
        //导航栏
        CGRect rect = _navigationBar.frame;
        rect.origin.y = -VIEW_NAVBAR_HEIGHT-SYS_STATUSBAR_HEIGHT;
        _navigationBar.frame = rect;
        
        //底部菜单栏
        _btMenuView.frame = CGRectMake(0, VIEW_NAVBAR_HEIGHT, SCREEN_SIZE_WIDTH, VIEW_NAVBAR_HEIGHT);
        
        QPage * page = PAGEOF([_pageStack lastObject]);
        [page pageEvent:kPageEventWillEnterFullScreenMode];
        [page setPageViewFrame:[self pageViewFrameOf:self.interfaceOrientation]];
    }
    else
    {
        //导航栏
        CGRect rect = _navigationBar.frame;
        rect.origin.y = 0;
        _navigationBar.frame = rect;
        
        //底部菜单栏
        _btMenuView.frame = CGRectMake(0, VIEW_NAVBAR_HEIGHT - VIEW_NAVBAR_HEIGHT, SCREEN_SIZE_WIDTH,
                                       VIEW_NAVBAR_HEIGHT);
        
        QPage * page = PAGEOF([_pageStack lastObject]);
        [page pageEvent:kPageEventWillLeaveFullScreenMode];
        [page setPageViewFrame:[self pageViewFrameOf:self.interfaceOrientation]];
    }
    
    CATransition * animation = [CATransition animation];
    animation.duration = 0.3;
    animation.type = kCATransitionFade;
    animation.subtype = need? kCATransitionFromTop:kCATransitionFromBottom;
    
    [_contentView.layer addAnimation:animation forKey:ANIMATION_FULLSCREEN];
    _presentAniKey = ANIMATION_FULLSCREEN;
}

- (QPage *)_pageOnTop
{
    return PAGEOF([_pageStack lastObject]);
}

#pragma mark -
#pragma mark - some functions


#pragma mark -
#pragma mark navigation bar
- (void)QNavigationBarLeftButtonTap:(QNavigationBar *)navigationBar
{
    if (_pageStack.count > 1) {
        [self goBack];
    }
    else//expandMenu
    {
        CGRect frameMenu = _mainMenu.frame;
        BOOL bExpandMenu = (frameMenu.origin.x>-1.0);
        [self expandMainMenu:!bExpandMenu];
    }
}


- (void)addAnimation:(BOOL)push
{
    CATransition * ani = [CATransition animation];
    ani.duration = 0.2;
    ani.type = kCATransitionPush;
    
    switch (self.interfaceOrientation) {
        case UIInterfaceOrientationPortrait:
        case UIInterfaceOrientationPortraitUpsideDown:
            ani.subtype = push?kCATransitionFromRight:kCATransitionFromLeft;
            break;
        case UIInterfaceOrientationLandscapeLeft:
            ani.subtype = push?kCATransitionFromBottom:kCATransitionFromTop;
            break;
        case UIInterfaceOrientationLandscapeRight:
            ani.subtype = push?kCATransitionFromTop:kCATransitionFromBottom;
            break;
        default:
            break;
    }
    [_contentView.layer addAnimation:ani forKey:ANIMATION_SWITCH_PAGE];
    _presentAniKey = ANIMATION_SWITCH_PAGE;
}

#pragma mark -
#pragma mark rotate
- (BOOL)shouldAutorotate
{
    if ([self mainMenuExpanded]) {
        return NO;
    }
    QPage * presentPage = PAGEOF([_pageStack lastObject]);
    return  [presentPage pageShouldAutorotate];
}

- (UIInterfaceOrientation)preferredInterfaceOrientationForPresentation
{
    return UIInterfaceOrientationPortrait;
}

- (NSUInteger)supportedInterfaceOrientations
{
    QPage *presentPage = PAGEOF([_pageStack lastObject]);
    return [presentPage pageSupportedInterfaceOrientations];
}

- (void)willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation
                                duration:(NSTimeInterval)duration
{
    if (toInterfaceOrientation == UIInterfaceOrientationLandscapeRight ||
        toInterfaceOrientation == UIInterfaceOrientationLandscapeLeft)
    {
        _navigationBar.hidden = YES;
        [UIApplication sharedApplication].statusBarHidden = YES;
    }
    else
    {
        _navigationBar.hidden = NO;
        [UIApplication sharedApplication].statusBarHidden = NO;
    }
    
    _contentView.frame = [self contentViewFrameOf:toInterfaceOrientation];
    
    QPage * presentPage = PAGEOF([_pageStack lastObject]);
    [presentPage setPageViewFrame:[self pageViewFrameOf:toInterfaceOrientation]];
    [presentPage pageWillRotateToInterfaceOrientation:toInterfaceOrientation duration:duration];
    
    _toInterfaceOrientation = toInterfaceOrientation;
    if ([self respondsToSelector:@selector(setNeedsStatusBarAppearanceUpdate)])
    {
        [self setNeedsStatusBarAppearanceUpdate];
    }
}

- (BOOL)prefersStatusBarHidden
{
    if (self.toInterfaceOrientation == UIInterfaceOrientationLandscapeLeft ||
        self.toInterfaceOrientation == UIInterfaceOrientationLandscapeRight)
    {
        return YES;
    }
    else
    {
        return NO;
    }
}

#pragma mark- MainMenu Delegate
- (QPage*)mainMenu:(QBottomMenuView*)mainMenu selected:(QBottomMenu*)menu
{
    BOOL bFirstEnterMain = NO;
    if (_enterMain == NO) {
        _enterMain = YES;
        bFirstEnterMain = YES;
    }
    
    if (![_mainMenuID isEqualToString:menu.pageID]) {//对当前栈清空
        [self clearCurrentStack];
        
        self.mainMenuID = menu.pageID;
        
        _pageStack = menu.pageStack;
        NSAssert(_pageStack.count == 0, @"pagestack not cleared");
        
        //查找当前主页面是否有缓存
        QPage * newPage = [QViewController createPageInternal:menu.pageID withParam:nil];
        [self navigateToPage:newPage.pageID];
        //[self addAnimation:YES];
    }
    
    return PAGEOF([_pageStack lastObject]);
}


- (void)clearCurrentStack
{
    if (_pageStack == nil) {
        return;
    }
    
    QPage * presentPage = PAGEOF([_pageStack lastObject]);
    if (presentPage)
    {
        [presentPage pageEvent:kPageEventWillHide];
        [presentPage.view removeFromSuperview];
    }
    
    while (_pageStack.count > 0) {
        [self internalRemoveLastPage];
    }
    
    self.mainMenuID = nil;
}

- (void)exitMainMenu
{
    [self clearCurrentStack];
    
    self.enterMain = NO;
    
    _pageStack = [NSMutableArray array];
}

- (void)onMaskViewTouched:(id)view
{
    [self expandMainMenu:NO];
}

- (BOOL)mainMenuExpanded
{
    CGRect frameMenu = _mainMenu.frame;
    return (frameMenu.origin.x>-1.0);
}

- (void)onSwipForMainMenu:(UISwipeGestureRecognizer*)swipeGesture
{
    BOOL bExpandMenu = [self mainMenuExpanded];
    
    if (swipeGesture.direction == UISwipeGestureRecognizerDirectionLeft) {
        if (bExpandMenu) {
            [self expandMainMenu:NO];
        }
    }
    else if(swipeGesture.direction == UISwipeGestureRecognizerDirectionRight)
    {
        if (!bExpandMenu) {
            [self expandMainMenu:YES];
        }
    }
}

- (void)expandMainMenu:(BOOL)expand
{
    //横屏状态下,禁止返回主菜单
    if (UIInterfaceOrientationIsLandscape(self.interfaceOrientation))
    {
        return ;
    }
    
    if (!_enterMain)//进主页面后才显示主菜单
    {
        return;
    }
    
    if ([_mainMenu superview] == nil) {
        [self.view addSubview:_mainMenu];
        [_contentView addSubview:_maskView];
    }
    
    CGRect frameMenu = _mainMenu.frame;    
    CGFloat offsetX = expand?0.0:-frameMenu.size.width;
    frameMenu.origin.x = offsetX;
    
    CGFloat menuRight = CGRectGetMaxX(frameMenu);
    CGRect rcTemp = _contentView.frame;
    rcTemp.origin.x = menuRight;
    
    [UIView animateWithDuration:0.2 delay:0.2 options:UIViewAnimationOptionCurveEaseInOut animations:^{
        _mainMenu.frame    = frameMenu;
        _contentView.frame = rcTemp;
        _maskView.alpha    = expand?0.2:0.0;
    } completion:^(BOOL finished) {
        if (expand) {
            _navigationBar.titleView.userInteractionEnabled = NO;
            //显示阴影
            [self.view bringSubviewToFront:_contentView];
            
            _contentView.layer.shadowOffset  = CGSizeMake(-3, 5);
            _contentView.layer.shadowOpacity = 0.5;
        }
        else
        {
            [_mainMenu removeFromSuperview];
            [_maskView removeFromSuperview];
            
            _navigationBar.titleView.userInteractionEnabled = YES;
            
            _contentView.layer.shadowOffset  = CGSizeMake(0, -3);
            _contentView.layer.shadowOpacity = 0.0;
        }
    }];
    
}

#pragma mark -
#pragma mark Animation delegate

- (void)animationDidStop:(CAAnimation *)anim finished:(BOOL)flag
{
    if ([ANIMATION_EXPAND_MAINMENU isEqualToString:_presentAniKey])
    {
        QPage * page = PAGEOF([_pageStack lastObject]);
        BOOL bExpand = [self mainMenuExpanded];
        if (!bExpand) {
            [_mainMenu removeFromSuperview];
            [_maskView removeFromSuperview];
            _navigationBar.titleView.hidden = NO;
            
            _contentView.layer.shadowOffset  = CGSizeMake(0, -3);
            _contentView.layer.shadowOpacity = 0.0;
        }
        else
        {
            [self.view bringSubviewToFront:_contentView];
            
            _contentView.layer.shadowOffset  = CGSizeMake(-3, 5);
            _contentView.layer.shadowOpacity = 0.5;
        }
        [page pageEvent:bExpand?kPageEventMainMenuExpand:kPageEventMainMenuFold];
    }
    _presentAniKey = nil;
}


#pragma mark -
#pragma mark page event

+ (QPage*)gotoPage:(NSString*)pageName withParam:(NSDictionary*)param
{
    BOOL needAnimation = YES;
    if ([pageName isEqualToString:@"QHomePage"] || [pageName isEqualToString:@"QBusinessPage"]
        || [pageName isEqualToString:@"QMyPage"] /*|| [pageName isEqualToString:@"QMorePage"]*/)
    {
        QBottomMenuView * mainMenu = [_shareViewController valueForKey:@"btMenuView"];
        return [mainMenu setMenuIndex:[mainMenu menuIndexForID:pageName]];
    }
    else if([pageName isEqualToString:@"QLoginPage"])
    {
        if (_shareViewController.enterMain) {
            [_shareViewController exitMainMenu];
        }
        needAnimation = NO;
    }
    
    QPage * page = [self createPageInternal:pageName withParam:param];
    if (page == nil) {
        NSLog(@"ERROR:Can't find page! (pageID:%@)",pageName);
        return nil;
    }
    
    [page setActiveWithParams:param];
    
    [_shareViewController navigateToPage:pageName];
    
    if (needAnimation) {
        [_shareViewController addAnimation:YES];
    }
    
    return page;
}

+ (QPage*)backPageWithParam:(NSDictionary*)param
{
    return [_shareViewController backPageWithParamInteral:param];
}

+ (QPage*)createPageInternal:(NSString*)pageName withParam:(NSDictionary*)param
{
    QPage * page = [self findPage:pageName];
    if (page == nil) {
        Class cls = NSClassFromString(pageName);
        if (cls == NULL) {
            NSString  * message = [NSString stringWithFormat:_T(@"ERROR:Page of type [%@] can't create!") ,pageName];
            NSLog(@"%@",message);
            return nil;
        }
        page = [cls createPage:param];
        [_shareViewController.pageCache setObject:page forKey:pageName];
    }
    return page;
}

+ (void)setNeedFullScreen:(BOOL)need
{
    [_shareViewController setNeedFullScreenInteral:need];
}

+ (BOOL)pageOnTop:(QPage*)page
{
    QPage * topPage = [_shareViewController _pageOnTop];
    return (topPage == page);
}

+ (BOOL)pageOnTopWithName:(NSString*)pageName
{
    if (pageName == nil) {
        return NO;
    }
    QPage * topPage = [_shareViewController _pageOnTop];
    return [topPage.pageID isEqualToString:pageName];
}

+ (QPage*)topPage
{
    return [_shareViewController _pageOnTop];
}

+ (void)disposeViewOfPage:(QPage*)page
{
    char  sMethodType[4] = "v@:";
    NSMethodSignature * ms = [NSMethodSignature signatureWithObjCTypes:sMethodType];
    NSInvocation * inv = [NSInvocation invocationWithMethodSignature:ms];
    [inv setSelector:NSSelectorFromString(@"private_disposeView")];
    [inv invokeWithTarget:page];
}

+ (void)initAndEnterMain
{
    dispatch_async(dispatch_get_main_queue(), ^{
        [self gotoPage:@"QMainPage" withParam:nil];
        [[QViewController shareController].mainMenu setMenuSelectedAtRow:0];
    });    
}

+ (void)showStautsBar:(BOOL)isShown;
{
    [UIApplication sharedApplication].statusBarHidden = !isShown;
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
}

+ (void)showMessage:(NSString*)message lastSecond:(NSTimeInterval)second
{
    dispatch_async(dispatch_get_main_queue(),
       ^(){
           UIAlertView * alert = [[UIAlertView alloc] initWithTitle:_T(@"Prompt")
                                                            message:message
                                                           delegate:nil
                                                  cancelButtonTitle:nil
                                                  otherButtonTitles:nil];
           [alert show];
           
           [_shareViewController performSelector:@selector(dismissAlert:)
                                      withObject:alert
                                      afterDelay:second];
       });
}
@end
