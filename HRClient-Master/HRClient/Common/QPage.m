//
//  DHPage.m
//  DSSClient
//
//  Created by panyj on 14-9-15.
//  Copyright (c) 2014年 panyj. All rights reserved.
//

#import "QPage.h"

@implementation PageView

- (void)dealloc
{
    debug_NSLog(@"");
}

@end

@implementation QPage
@synthesize view = _view;

- (QCacheType)pageCacheType
{
    return kCacheTypeCommon;
}

- (QNavigationType)navigationType
{
    return kNavigationTypeNormal;
}

- (QBottomMenuType)bottomMenuType
{
    return kBottomMenuTypeNone;
}

- (UIBarButtonItem*)pageLeftMenu
{
    return nil;
}

- (UIBarButtonItem*)pageRightMenu
{
    return nil;
}

- (NSArray*)pageRightMenus
{
    return nil;
}

- (NSString*)pageID
{
    return NSStringFromClass([self class]);
}

- (NSString*)title
{
    return @"页 面";
}

- (UIView*)titleViewWithFrame:(CGRect)frame
{
    UILabel * titleView = [[UILabel alloc] initWithFrame:frame];
    titleView.textAlignment = NSTextAlignmentCenter;
    titleView.font = [UIFont boldSystemFontOfSize:18];
    titleView.text = [self title];
    titleView.textColor = [UIColor whiteColor];
    titleView.backgroundColor = [UIColor clearColor];
    return titleView;
}


+ (id)createPage:(NSDictionary*)params
{
    return [[self alloc] init];
}

- (void)pageEvent:(QPageEventType)eventType
{
    
}

- (BOOL)pageShouldAutorotate
{
    return YES;
}

- (NSUInteger)pageSupportedInterfaceOrientations
{
   return UIInterfaceOrientationMaskPortrait | UIInterfaceOrientationMaskPortraitUpsideDown;
}

- (void)pageWillRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation
                                    duration:(NSTimeInterval)duration
{
   
}

- (BOOL)onBack
{
    return YES;
}


- (void)private_viewWithFrame:(CGRect)frame
{
    CGRect viewFrame = CGRectMake(0, 0, frame.size.width, frame.size.height);
    if((_view = [self viewWithFrame:viewFrame]))
    {
        [self pageEvent:kPageEventViewCreate];
        [self setPageViewFrame:frame];
    }   
}

- (void)setPageViewFrame:(CGRect)frame
{
    _view.frame = frame;
}

- (void)private_disposeView
{
    [self pageEvent:kPageEventViewDispose];
    _view = nil;
}

- (id)viewWithFrame:(CGRect)frame
{
    if (_view == nil){
        _view = [[UIView alloc] initWithFrame:frame];
    }
    return _view;
}

- (void)setActiveWithParams:(NSDictionary*)params
{
    if (params) {
        NSLog(@"QPage activeWithParams:%@",params);
    }
}

- (BOOL)showOnTop
{
    return ([_view superview]!=nil);
}
#pragma mark -
#pragma mark touch event

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event{}
- (void)touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event{}
- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event{}
- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event{}

- (void)viewDidAppear:(BOOL)animated{}
- (void)viewDidDisappear:(BOOL)animated{}
- (void)viewDidLayoutSubviews{}

@end
