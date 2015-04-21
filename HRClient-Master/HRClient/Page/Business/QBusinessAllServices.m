//
//  QBusinessDetailPage.m
//  HRClient
//
//  Created by chenyf on 14/12/5.
//  Copyright (c) 2014年 panyj. All rights reserved.
//  商家详情

#import "QBusinessAllServices.h"
#import "QViewController.h"
#import "QBussinessCell.h"
#import "QGroupBuyCell.h"
#import "QHttpMessageManager.h"
#import "UIImageView+WebCache.h"
#import "MJRefresh.h"

@interface QBusinessAllServices ()
{
    NSString *companyID;
    NSString *companyName;
    NSArray *dataArr;
}

@property (nonatomic) UITableView *tableView;

@end

@implementation QBusinessAllServices

#pragma mark - view

- (void)setActiveWithParams:(NSDictionary*)params
{
    if (!companyID) {
        companyID = [params objectForKey:@"companyID"];
        companyName = [params objectForKey:@"companyName"];
    }
}

- (void)pageEvent:(QPageEventType)eventType
{
    if (eventType == kPageEventWillShow)
    {
    }
    else if (eventType == kPageEventWillHide)
    {
    }
    else if (eventType == kPageEventViewDispose)
    {
        [[NSNotificationCenter defaultCenter] removeObserver:self];
        [ASRequestHUD dismiss];
    }
    else if (eventType == kPageEventViewCreate)
    {
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didGetFailedData:) name:kInterfaceFailed object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didGetCompanyProductList:)
                                                     name:kCompanyProduct object:nil];
        [_tableView.legendHeader beginRefreshing];
    }
}


- (UIView *)viewWithFrame:(CGRect)frame
{
    if ([super viewWithFrame:frame]) {
        
        // 商家详情
        _tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, frame.size.width, frame.size.height) style:UITableViewStylePlain];
        _tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
        _tableView.delegate = self;
        _tableView.dataSource = self;
        _tableView.backgroundColor = [QTools colorWithRGB:240 :239 :237];
        [_view addSubview:_tableView];
        
        [_tableView addLegendHeaderWithRefreshingTarget:self refreshingAction:@selector(headerRefresh)];
    }
    
    return _view;
}

- (NSString *)title
{
    return companyName;
}

#pragma mark - Private

- (void)headerRefresh
{
    [[QHttpMessageManager sharedHttpMessageManager] accessCompanyProduct:companyID andRegionID:[ASUserDefaults objectForKey:CurrentRegionID]];
}

#pragma mark - Notification

- (void)didGetFailedData:(NSNotification*)noti
{
    if (_tableView.legendHeader.isRefreshing)
        [_tableView.legendHeader endRefreshing];
}

- (void)didGetCompanyProductList:(NSNotification*)notify
{
    dataArr = notify.object;
    [_tableView reloadData];
    
    if (_tableView.legendHeader.isRefreshing)
        [_tableView.legendHeader endRefreshing];
}

#pragma mark - UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return dataArr.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return [QGroupBuyCell GetQGroupBuyCellHeight];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifierGroupBuy = @"Cell_Identifier_BusinessDetail_GroupBuy";
    QGroupBuyCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifierGroupBuy];
    if (nil == cell) {
        cell = [[QGroupBuyCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifierGroupBuy];
    }
    
    [cell configureCellForBusinPage:dataArr andIndexPath:indexPath];
    return cell;
}

#pragma mark - UITableViewDelegate
- (void)tableView:(UITableView *)tableView didHighlightRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    cell.contentView.backgroundColor = [QTools colorWithRGB:238 :238 :238];
}

- (void)tableView:(UITableView *)tableView didUnhighlightRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    cell.contentView.backgroundColor = [UIColor whiteColor];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (dataArr && dataArr.count > indexPath.row)
    {
        /* 商品详情页面 */
        QBusinessDetailResult *model = dataArr[indexPath.row];
        [QViewController gotoPage:@"QGroupBuyDetailPage" withParam:[NSDictionary dictionaryWithObjectsAndKeys:model.productId, @"ProductID", nil]];
    }
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

@end
