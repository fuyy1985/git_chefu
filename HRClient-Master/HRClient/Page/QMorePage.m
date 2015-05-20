//
//  QMorePage.m
//  DSSClient
//
//  Created by pany on 14-4-18.
//  Copyright (c) 2014年 SDK. All rights reserved.
//

#import "QMorePage.h"
#import "QViewController.h"
#import "QGuidepageController.h"
#import "SDImageCache.h"
#import "UMSocialSnsService.h"
#import "UMSocialSnsPlatformManager.h"

@interface QMorePage()<UITableViewDataSource,UITableViewDelegate,UIAlertViewDelegate,UMSocialUIDelegate>
{
    UITableView *contentTable;
    NSArray *titleArray;
}

@end

@implementation QMorePage

typedef enum{
    moreType_givePrize = 0,
    moreType_response = 1,
    moreType_clearcach = 2,
    moreType_invitefriend = 3,
    moreType_aboutme = 4,
}moreType;


- (void)pageEvent:(QPageEventType)eventType
{
    if (eventType == kPageEventWillShow)
    {
        
    }
}

- (QNavigationType)navigationType
{
    return kNavigationTypeNormal;
}

- (QBottomMenuType)bottomMenuType
{
    return kBottomMenuTypeNormal;
}

- (UIView*)viewWithFrame:(CGRect)frame
{
    if ([super viewWithFrame:frame])
    {
        //数据源
        titleArray = @[/*@"节省流量",@"消息设置提醒",*/@"给我评价", @"用户反馈",/*@"分享设置",*/@"清除缓存",
                       @"邀请朋友使用", @"关于我们"];
        
        contentTable = [[UITableView alloc]initWithFrame:CGRectMake(0, 0, _view.deFrameWidth, _view.deFrameHeight)];
        contentTable.separatorStyle = UITableViewCellSeparatorStyleNone;
        contentTable.delegate = self;
        contentTable.dataSource = self;
        contentTable.backgroundColor = [UIColor whiteColor];
        
        [_view addSubview:contentTable];
    }
    
    return _view;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return titleArray.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 44;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    static NSString *myCellID = @"morePag";
    
    UITableViewCell *myCell = [tableView dequeueReusableCellWithIdentifier:myCellID];
    if (myCell == nil)
    {
        myCell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:myCellID];
        myCell.textLabel.font = [UIFont systemFontOfSize:14];
        myCell.textLabel.textColor = ColorDarkGray;
        
        UIView *lineView = [[UIView alloc] initWithFrame:CGRectMake(10, 44 - 0.5f, tableView.deFrameWidth - 2*10, 0.5f)];
        lineView.backgroundColor = ColorLine;
        [myCell.contentView addSubview:lineView];
    }
    
    myCell.textLabel.text = titleArray[indexPath.row];
    
    return myCell;
    
}

#pragma maek - UITalbeViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    switch (indexPath.row)
    {
        case moreType_givePrize:
        {
            [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"https://appsto.re/cn/q9L66.i"]];
        }
            break;
        case moreType_response:
        {
            [QViewController gotoPage:@"QSuggestRetroactionPage" withParam:nil];
        }
            break;
        case moreType_aboutme:
        {
            [QViewController gotoPage:@"QAboutUs" withParam:nil];
        }
            break;
        case moreType_clearcach:
        {
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"温馨提示" message:@"确认要清除缓存吗？" delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"确定", nil];
            alert.delegate  = self;
            [alert show];
        }
            break;
        case moreType_invitefriend:
        {
            [UMSocialSnsService presentSnsIconSheetView:[QViewController shareController]
                                              appKey:UMSocalAppKey
                                           shareText:@"随时随地养车，让服务离您更近，让您养车更省心、有保障更放心，一路都是为了您……"
                                          shareImage:[UIImage imageNamed:@"icon_share"]
                                     shareToSnsNames:[NSArray arrayWithObjects:UMShareToWechatSession,UMShareToWechatTimeline,nil]
                                            delegate:self];
        }
            break;
        default:
            break;
    }
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

#pragma mark - UIAlertView
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (buttonIndex == 0)
    {
        
    }
    else if(buttonIndex == 1)
    {
        [[SDImageCache sharedImageCache] clearDisk];
    }
}


#pragma mark - view circle

- (NSString*)title
{
    return _T(@"更多");
}

- (QCacheType)pageCacheType
{
    return kCacheTypeAlways;
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

-(void)didSelectSocialPlatform:(NSString *)platformName withSocialData:(UMSocialData *)socialData
{
    [UMSocialData defaultData].extConfig.wechatSessionData.title = @"车夫-您的全能养车小帮手";
    [UMSocialData defaultData].extConfig.wechatTimelineData.title = @"车夫-您的全能养车小帮手";
}

@end
