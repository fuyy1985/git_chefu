//
//  QSamplePage.m
//  DSSClient
//
//  Created by pany on 14-11-30.
//  Copyright (c) 2014年 SDK. All rights reserved.
//

#import "QSamplePage.h"
#import "QViewController.h"

@interface QSamplePage()
@property(nonatomic,strong)NSString *strInfo;
@end

@implementation QSamplePage

#pragma mark - view circle

- (void)pageEvent:(QPageEventType)eventType
{
    if (eventType == kPageEventWillShow)
    {
        //NOTE:页面的消息接口 同普通controller的 隐藏消失回调
    }
}

- (UIView*)viewWithFrame:(CGRect)frame
{
    if ([super viewWithFrame:frame])
    {
        //NOTE:页面布局初始化
        
        //ex:
        UILabel *lbText = [[UILabel alloc]initWithFrame:CGRectMake(0, 0, 100, 100)];
        lbText.center = _view.center;
        lbText.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin |
                                  UIViewAutoresizingFlexibleTopMargin |UIViewAutoresizingFlexibleBottomMargin;
        lbText.text = @"hello world";
        lbText.textAlignment = NSTextAlignmentCenter;
        lbText.font = [UIFont systemFontOfSize:20.0f];
        lbText.textColor = [UIColor blackColor];
        
        [_view addSubview:lbText];
        
    }
    
    return _view;
}

#pragma mark - view settings

- (NSString*)title //NOTE:页面标题
{
    return _T(@"Settings");
}

- (QCacheType)pageCacheType //NOTE:页面缓存方式
{
    return kCacheTypeCommon;
}

- (QNavigationType)navigationType //NOTE:导航栏是否存在
{
    return kNavigationTypeNormal;
}

- (UIBarButtonItem*)pageRightMenu //NOTE:右边导航栏
{
    UIBarButtonItem *item = [[UIBarButtonItem alloc] initWithTitle:_T(@"右边") style:UIBarButtonItemStyleBordered target:self action:@selector(test)];
    
    return item;
}

- (void)setActiveWithParams:(NSDictionary*)params //NOTE:方便页面激活时接收参数
{
    self.strInfo = [params valueForKey:@"test"];
}

#pragma mark -private metholds

- (NSString*)strInfo
{
    if (_strInfo == nil || [_strInfo isEqualToString:@""]) {
        _strInfo = @"no info";
    }
    
    return _strInfo;
}

- (void)test
{
    [QViewController showMessage:_strInfo];
}


#pragma mark - Rotate

- (BOOL)pageShouldAutorotate
{
    return YES;
}

- (NSUInteger)pageSupportedInterfaceOrientations
{
    return UIInterfaceOrientationMaskPortrait | UIInterfaceOrientationMaskPortraitUpsideDown;
}


@end
