//
//  QGroupBuyWashingCarPage.m
//  HRClient
//
//  Created by chenyf on 14/12/10.
//  Copyright (c) 2014年 panyj. All rights reserved.
//  洗车团购列表页面

#import "QGroupBuyWashingCarPage.h"
#import "QGroupBuyWashingCarCell.h"
#import "QViewController.h"
#import "QBaseFilterView.h"
#import "QCategoryFilterView.h"
#import "QAreaFilterView.h"
#import "QThirdFilterView.h"
#import "QFootPrintFilterView.h"
#import "QHttpMessageManager.h"
#import "QHomePageModel.h"
#import "QCategoryView.h"
#import "QCarWashModel.h"
#import "QLocationManager.h"
#import "QRegularHelp.h"
#import "QDataPaging.h"
#import "MJRefresh.h"

@interface QGroupBuyWashingCarPage ()<QCategoryFilterViewDelegate, QAreaFilterViewDelegate, QThirdFilterViewDelegate>
{
    QCategoryModel *_category;
    QCategorySubModel *_subCategory;
    QRegionModel *_areaModel;
    QFilterKeyModel *_keyModel;
    UIButton *_btnCategory;
    UIButton *_btnRegion;
    UIButton *_btnKey;
    UILabel *_lbTitle;
    UILabel *_lbLocaiton;
}
@property (nonatomic, strong) UIView *headFilterView;
@property (nonatomic) QCategoryFilterView *filterView1;
@property (nonatomic) QAreaFilterView *filterView2;
@property (nonatomic) QThirdFilterView *filterView3;
@property (nonatomic) UITableView *groupBuyWashingCarTableView;
@property (nonatomic) NSMutableArray *groupBuyWashingCarList;

@property (nonatomic,strong)UITableViewHeaderFooterView *headerView;
@property (nonatomic, strong) UIView *footerView;

@property (nonatomic, strong) QDataPaging *dataPage;
@end

@implementation QGroupBuyWashingCarPage

#pragma mark - view

- (void)setActiveWithParams:(NSDictionary *)params
{
    if (params)
    {
        _category = [params objectForKey:@"QCategoryModel"];
        _subCategory = [params objectForKey:@"QCategorySubModel"];
        _keyModel = [params objectForKey:@"QFilterKeyModel"];
    }
}

- (NSString *)categoryTitle
{
    NSString *title = @"";
    if (_subCategory){
        title = NSString_No_Nil(_subCategory.categoryName);
    }
    else if (_category) {
        title = NSString_No_Nil(_category.categoryName);
    }
    return title;
}

- (UIView*)titleViewWithFrame:(CGRect)frame
{
    UILabel * titleView = [[UILabel alloc] initWithFrame:frame];
    titleView.textAlignment = NSTextAlignmentCenter;
    titleView.font = [UIFont boldSystemFontOfSize:18];
    titleView.text = [self categoryTitle];
    titleView.textColor = [UIColor whiteColor];
    titleView.backgroundColor = [UIColor clearColor];
    
    _lbTitle = titleView;
    
    return titleView;
}

- (void)pageEvent:(QPageEventType)eventType
{
    if (eventType == kPageEventViewCreate)
    {
        //数据初始化
        _dataPage = [[QDataPaging alloc] init];
        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(getDataFailed:) name:kInterfaceFailed object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(locationDone:) name:Noti_Location_Done object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(acquireWashInfro:) name:kCarWashList object:nil];
        
        if ([QLocationManager sharedInstance].geoResult) {
            NSString *address = @"当前:";
            _lbLocaiton.text = [address stringByAppendingString:[QLocationManager sharedInstance].geoResult.address];
        }
        else {
            [[QLocationManager sharedInstance] startUserLocation];
        }
        
        [_groupBuyWashingCarTableView.legendHeader beginRefreshing];
    }
    else if (eventType == kPageEventViewDispose)
    {
        [[NSNotificationCenter defaultCenter] removeObserver:self];
    }
}

- (UIView *)viewWithFrame:(CGRect)frame
{
    if ([super viewWithFrame:frame]) {
        
        self.headFilterView.backgroundColor = [UIColor whiteColor];
        [self updateHeaderFilterTitle];
        
        CGFloat top = self.headFilterView.deFrameBottom;
        #pragma mark -- 位置信息
        UIView *headerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, frame.size.width, 34)];
        headerView.backgroundColor = [UIColor clearColor];

        UILabel *locationLabel = [[UILabel alloc] initWithFrame:CGRectMake(15, 0, headerView.frame.size.width - 15 - 45, headerView.frame.size.height)];
        locationLabel.backgroundColor = [UIColor clearColor];
        locationLabel.text = @"正在定位中...";
        locationLabel.font = [UIFont systemFontOfSize:12];
        locationLabel.textColor = [QTools colorWithRGB:135 :134 :132];
        [headerView addSubview:locationLabel];
        _lbLocaiton = locationLabel;
        
        UIButton *refreshLocationButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [refreshLocationButton setImage:IMAGEOF(@"location_refresh") forState:UIControlStateNormal];
        [refreshLocationButton sizeToFit];
        refreshLocationButton.deFrameTop = 8;
        refreshLocationButton.deFrameRight = headerView.frame.size.width - 15;
        [refreshLocationButton addTarget:self action:@selector(onBtnRefreshLocation:) forControlEvents:UIControlEventTouchUpInside];
        [headerView addSubview:refreshLocationButton];
        
        UIView *lineView = [[UIView alloc] initWithFrame:CGRectMake(0, headerView.frame.size.height - .5f, headerView.frame.size.width, .5)];
        lineView.backgroundColor = ColorLine;
        [headerView addSubview:lineView];
        
        #pragma mark -- 团购列表
        _groupBuyWashingCarTableView = [[UITableView alloc] initWithFrame:CGRectMake(0, top, frame.size.width, frame.size.height - top) style:UITableViewStylePlain];
        _groupBuyWashingCarTableView.separatorStyle = UITableViewCellSeparatorStyleNone;
        _groupBuyWashingCarTableView.delegate = self;
        _groupBuyWashingCarTableView.dataSource = self;
        _groupBuyWashingCarTableView.tableHeaderView = headerView;
        _groupBuyWashingCarTableView.backgroundColor = [QTools colorWithRGB:238 :238 :238];
        [_view addSubview:_groupBuyWashingCarTableView];
        
        [_groupBuyWashingCarTableView addLegendHeaderWithRefreshingTarget:self refreshingAction:@selector(headerRereshing)];
    }
    
    return _view;
}

- (NSArray*)pageRightMenus
{
    UIButton *editBtn = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 40, 10)];
    [editBtn setImage:[UIImage imageNamed:@"search2"] forState:UIControlStateNormal];
    [editBtn addTarget:self action:@selector(onSearch:) forControlEvents:UIControlEventTouchUpInside];
    [editBtn sizeToFit];
    UIBarButtonItem *editItem = [[UIBarButtonItem alloc] initWithCustomView:editBtn];
    
    UIButton *editBtn2 = [UIButton buttonWithType:UIButtonTypeCustom];
    [editBtn2 setImage:[UIImage imageNamed:@"map.png"] forState:UIControlStateNormal];
    [editBtn2 addTarget:self action:@selector(onMap:) forControlEvents:UIControlEventTouchUpInside];
    [editBtn2 sizeToFit];
    UIBarButtonItem *editItem2 = [[UIBarButtonItem alloc] initWithCustomView:editBtn2];
    
    return [NSArray arrayWithObjects:editItem,editItem2, nil];
}


#pragma mark - Private

- (UIView*)headFilterView
{
    if (!_headFilterView) {
        
        CGFloat w = _view.deFrameWidth / 3;
        CGFloat h = 38;
        
        _headFilterView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, _view.deFrameWidth, h)];
        [_view addSubview:_headFilterView];
        
        UIButton *button = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, w, h)];
        button.backgroundColor = [UIColor whiteColor];
        button.titleLabel.font = [UIFont systemFontOfSize:12.f];
        [button setTitleColor:[QTools colorWithRGB:107 :107 :109] forState:UIControlStateNormal];
        [button setImage:IMAGEOF(@"arrow") forState:UIControlStateNormal];
        [button addTarget:self action:@selector(buttonTapped:) forControlEvents:UIControlEventTouchUpInside];
        button.tag = 1;
        [_headFilterView addSubview:button];
        _btnCategory = button;
        
        UIView *lineView = [[UIView alloc] initWithFrame:CGRectMake(button.deFrameRight - .5, 9, .5, 20)];
        lineView.backgroundColor = ColorLine;
        [_headFilterView addSubview:lineView];
        
        button = [[UIButton alloc] initWithFrame:CGRectMake(button.deFrameRight, 0, w, h)];
        button.backgroundColor = [UIColor whiteColor];
        button.titleLabel.font = [UIFont systemFontOfSize:12.f];
        [button setTitleColor:[QTools colorWithRGB:107 :107 :109] forState:UIControlStateNormal];
        [button setImage:IMAGEOF(@"arrow") forState:UIControlStateNormal];
        [button setImageEdgeInsets:UIEdgeInsetsMake(0, 65, 0, 0)];
        [button setTitleEdgeInsets:UIEdgeInsetsMake(0, 5, 0, 15)];
        [button addTarget:self action:@selector(buttonTapped:) forControlEvents:UIControlEventTouchUpInside];
        button.tag = 2;
        [_headFilterView addSubview:button];
        _btnRegion = button;
        
        lineView = [[UIView alloc] initWithFrame:CGRectMake(button.deFrameRight - .5, 5, .5, h - 2*5)];
        lineView.backgroundColor = ColorLine;
        [_headFilterView addSubview:lineView];
        
        button = [[UIButton alloc] initWithFrame:CGRectMake(button.deFrameRight, 0, w, h)];
        button.backgroundColor = [UIColor whiteColor];
        button.titleLabel.font = [UIFont systemFontOfSize:12.f];
        [button setTitleColor:[QTools colorWithRGB:107 :107 :109] forState:UIControlStateNormal];
        [button setImage:IMAGEOF(@"arrow") forState:UIControlStateNormal];
        [button setImageEdgeInsets:UIEdgeInsetsMake(0, 65, 0, 0)];
        [button setTitleEdgeInsets:UIEdgeInsetsMake(0, 5, 0, 15)];
        [button addTarget:self action:@selector(buttonTapped:) forControlEvents:UIControlEventTouchUpInside];
        button.tag = 3;
        [_headFilterView addSubview:button];
        _btnKey = button;
        
        lineView = [[UIView alloc] initWithFrame:CGRectMake(button.deFrameRight - .5, 5, .5, h - 2*5)];
        lineView.backgroundColor = [QTools colorWithRGB:241 :241 :241];
        [_headFilterView addSubview:lineView];
        
        lineView = [[UIView alloc] initWithFrame:CGRectMake(0, h - 0.5, _headFilterView.deFrameWidth, 0.5)];
        lineView.backgroundColor = ColorLine;
        [_headFilterView addSubview:lineView];
    }
    return _headFilterView;
}

- (void)updateHeaderFilterTitle
{
    NSString *categoryName = @"";
    if (_subCategory) {
        categoryName = _subCategory.categoryName;
    }
    else {
        categoryName = _category.categoryName;
    }
    
    _lbTitle.text = categoryName;
    
    [_btnCategory setTitle:categoryName forState:UIControlStateNormal];
    CGSize textSize = [categoryName sizeWithFont:[UIFont systemFontOfSize:12]];
    [_btnCategory setImageEdgeInsets:UIEdgeInsetsMake(0, textSize.width + 5, 0, - (textSize.width + 5))];
    [_btnCategory setTitleEdgeInsets:UIEdgeInsetsMake(0, 5, 0, 15)];
    
    NSString *areaName = @"全城";
    if (_areaModel) {
        areaName = _areaModel.regionName;
    }
    [_btnRegion setTitle:areaName forState:UIControlStateNormal];
    textSize = [areaName sizeWithFont:[UIFont systemFontOfSize:12]];
    [_btnRegion setImageEdgeInsets:UIEdgeInsetsMake(0, textSize.width + 5, 0, - (textSize.width + 5))];
    [_btnRegion setTitleEdgeInsets:UIEdgeInsetsMake(0, 5, 0, 15)];
    
    NSString *keyName = _keyModel.keyName;
    [_btnKey setTitle:keyName forState:UIControlStateNormal];
    textSize = [keyName sizeWithFont:[UIFont systemFontOfSize:12]];
    [_btnKey setImageEdgeInsets:UIEdgeInsetsMake(0, textSize.width + 5, 0, - (textSize.width + 5))];
    [_btnKey setTitleEdgeInsets:UIEdgeInsetsMake(0, 5, 0, 15)];
}

- (UIView*)footerView
{
    if (!_footerView) {
        _footerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, _groupBuyWashingCarTableView.deFrameWidth, _groupBuyWashingCarTableView.deFrameHeight - 38)];
        _footerView.backgroundColor = [UIColor clearColor];
        
        UIImageView *imageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"icon_no_data"]];
        [_footerView addSubview:imageView];
        imageView.center = CGPointMake(_footerView.center.x, _footerView.center.y - 20);
        
        UILabel *label = [[UILabel alloc] init];
        label.backgroundColor = [UIColor clearColor];
        label.textColor = ColorDarkGray;
        label.font = [UIFont systemFontOfSize:13];
        label.text = @"商家挖掘中...";
        [label sizeToFit];
        [_footerView addSubview:label];
        
        label.deFrameTop = imageView.deFrameBottom;
        label.center = CGPointMake(imageView.center.x, label.center.y);
    }
    return _footerView;
}

- (void)headerRereshing
{
    if (_groupBuyWashingCarTableView.legendFooter.isRefreshing)
        return;
    
    _dataPage.nextPage = 1;
    [self tryGetProductbyLongitude];
}

- (void)footerLoading
{
    if (_groupBuyWashingCarTableView.legendHeader.isRefreshing)
        return;
    
    [self tryGetProductbyLongitude];
}

- (void)tryGetProductbyLongitude
{
    CLLocationCoordinate2D point = [QLocationManager sharedInstance].geoPoint;
    NSString *longitude = point.longitude ? [[NSNumber numberWithDouble:point.longitude] stringValue] : nil;
    NSString *latitude = point.latitude ? [[NSNumber numberWithDouble:point.latitude] stringValue] : nil;
    
    NSNumber *regionID = (_areaModel && _areaModel.regionId) ? _areaModel.regionId : [ASUserDefaults objectForKey:CurrentRegionID];
    NSNumber *categoryID = (_subCategory) ? _subCategory.categoryId : _category.categoryId;
    NSString *key = [NSString stringWithFormat:@"%d", _keyModel.keyType];
    
    [[QHttpMessageManager sharedHttpMessageManager] accessCarWashList:NSString_No_Nil([regionID stringValue])
                                                        andCategoryId:NSString_No_Nil([categoryID stringValue])
                                                         andLongitude:longitude
                                                          andLatitude:latitude
                                                               andKey:key
                                                       andCurrentPage:INTTOSTRING(_dataPage.nextPage)
                                                          andPageSize:INTTOSTRING(_dataPage.pageSize)];
}

#pragma mark - Action

- (void)buttonTapped:(UIButton *)sender
{
    QBaseFilterView *view = nil;
    switch (sender.tag) {
        case 1: // 类别
        {
            if (!_filterView1) {
                _filterView1 = [[QCategoryFilterView alloc] initWithFrame:CGRectMake(0, self.headFilterView.deFrameBottom, _groupBuyWashingCarTableView.deFrameWidth, _groupBuyWashingCarTableView.deFrameHeight)];
                _filterView1.delegate = self;
                [_view addSubview:_filterView1];
            }
            
            view = _filterView1;
        }
            break;
        case 2: // 城区
        {
            if (!_filterView2) {
                _filterView2 = [[QAreaFilterView alloc] initWithFrame:CGRectMake(0, self.headFilterView.deFrameBottom, _groupBuyWashingCarTableView.deFrameWidth, _groupBuyWashingCarTableView.deFrameHeight)];
                _filterView2.delegate = self;
                [_view addSubview:_filterView2];
            }
        }
            
            view = _filterView2;
            break;
        case 3:
        {
            if (!_filterView3) {
                _filterView3 = [[QThirdFilterView alloc] initWithFrame:CGRectMake(0, self.headFilterView.deFrameBottom, _groupBuyWashingCarTableView.deFrameWidth, _groupBuyWashingCarTableView.deFrameHeight) andListType:kDataProductType];
                _filterView3.delegate = self;
                [_view addSubview:_filterView3];
            }
        }
            view = _filterView3;
            break;
        default:
            break;
    }
    
    if (0 == view.deFrameWidth) {
        [view toggleMenu];
        sender.imageView.transform = CGAffineTransformRotate(sender.imageView.transform, M_PI);
    }
    else {
        [view hideMenu];
    }
    
    if (![view isEqual:_filterView1])
        [_filterView1 hideMenu];
    if (![view isEqual:_filterView2])
        [_filterView2 hideMenu];
    if (![view isEqual:_filterView3])
        [_filterView3 hideMenu];
}

- (void)onBtnRefreshLocation:(UIButton *)sender
{
    _lbLocaiton.text = @"正在定位中...";
    [[QLocationManager sharedInstance] startUserLocation];
}

- (void)onSearch:(id)sender
{
    [QViewController gotoPage:@"QTitleSearch" withParam:nil];
}

- (void)onMap:(id)sender
{
    [QViewController gotoPage:@"QMapPage" withParam:nil];
}

#pragma mark - Notification

- (void)getDataFailed:(NSNotification*)noti
{
    if (_groupBuyWashingCarTableView.legendHeader.isRefreshing)
        [_groupBuyWashingCarTableView.legendHeader endRefreshing];
    if (_groupBuyWashingCarTableView.legendFooter.isRefreshing)
        [_groupBuyWashingCarTableView.legendFooter endRefreshing];
}

- (void)locationDone:(NSNotification*)noti
{
    BOOL ret = [noti.object boolValue];
    if (ret) {
        NSString *address = @"当前:";
        _lbLocaiton.text = [address stringByAppendingString:[QLocationManager sharedInstance].geoResult.address];
    }
    else {
        _lbLocaiton.text = @"无法定位当前位置,请稍后再试";
    }
}

//数据下载成功
- (void)acquireWashInfro:(NSNotification *)noti
{
    [_dataPage setMData:noti.object];
    _dataPage.nextPage++;
    
    if (_groupBuyWashingCarTableView.legendHeader.isRefreshing)
        [_groupBuyWashingCarTableView.legendHeader endRefreshing];
    if (_groupBuyWashingCarTableView.legendFooter.isRefreshing)
        [_groupBuyWashingCarTableView.legendFooter endRefreshing];
    
    if(_dataPage.mData.count < (_dataPage.nextPage - 1) * _dataPage.pageSize) //表示不需要loading
        [_groupBuyWashingCarTableView removeFooter];
    else
    {
        if (!_groupBuyWashingCarTableView.legendFooter)
            [_groupBuyWashingCarTableView addLegendFooterWithRefreshingTarget:self refreshingAction:@selector(footerLoading)];
    }
    
    if (_dataPage.mData.count < 1)
        self.groupBuyWashingCarTableView.tableFooterView = self.footerView;
    else
        self.groupBuyWashingCarTableView.tableFooterView = nil;
    
    [_groupBuyWashingCarTableView reloadData];
}


#pragma mark - UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return _dataPage.mData.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 1 + 1; // footer view
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 35;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.row == [self tableView:tableView numberOfRowsInSection:indexPath.section] - 1) {
        return 10;
    }
    return 86;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    static NSString *HeaderIdentifier = @"HeaderIdentifier";
    QGroupBuyCellHeadView *headerView = [tableView dequeueReusableHeaderFooterViewWithIdentifier:HeaderIdentifier];
    if (!headerView)
    {
        headerView = [[QGroupBuyCellHeadView alloc] initWithReuseIdentifier:HeaderIdentifier andRect:CGRectMake(0, 0, tableView.deFrameWidth, 35)];
    }
    
    if (_dataPage.mData.count <= section) {
        return headerView;
    }
    QProductModel *model = [_dataPage.mData objectAtIndex:section];
    [headerView setCompanyName:model.companyName andRegionName:model.regionName andDistance:model.distance];
    
    return headerView;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{

    if (indexPath.row == [self tableView:tableView numberOfRowsInSection:indexPath.section] - 1)
    {
        static NSString *CellIdentifier = @"Cell_Identifier_Empty";
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
        if (nil == cell) {
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault
                                          reuseIdentifier:CellIdentifier];
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
            cell.backgroundColor = [QTools colorWithRGB:240 :239 :237];
        }
        return cell;
    }

    static NSString *CellIdentifier = @"Cell_Identifier_GroupBuyList";
    QGroupBuyWashingCarCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (nil == cell) {
        cell = [[QGroupBuyWashingCarCell alloc] initWithStyle:UITableViewCellStyleDefault
                                    reuseIdentifier:CellIdentifier];
    }
    [cell configureCellForWash:_dataPage.mData andIndexPath:indexPath];
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
    if (indexPath.row == [tableView numberOfRowsInSection:indexPath.section] - 1)
    {
        ;
    }
    else
    {
        UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
        cell.contentView.backgroundColor = [UIColor whiteColor];
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.row != [self tableView:tableView numberOfRowsInSection:indexPath.section] - 1)
    {
        QProductModel *model = _dataPage.mData[indexPath.section];
        [QViewController gotoPage:@"QGroupBuyDetailPage" withParam:[NSDictionary dictionaryWithObjectsAndKeys:model.productId, @"ProductID", nil]];
    }
}

#pragma mark - QCategoryFilterViewDelegate
- (void)didChangeCategory:(QCategoryModel *)model sub:(QCategorySubModel *)subModel
{
    _category = model;
    _subCategory = subModel;
    
    [self updateHeaderFilterTitle];
    
    _dataPage.nextPage = 1;
    [_groupBuyWashingCarTableView.legendHeader beginRefreshing];
}

- (void)didHideCategoryView
{
    _btnCategory.imageView.transform = CGAffineTransformRotate(_btnCategory.imageView.transform, M_PI);
    [self performSelector:@selector(removeCategoryView) withObject:nil afterDelay:0.02];
}

- (void)removeCategoryView
{
    [_filterView1 removeFromSuperview];
    _filterView1 = nil;
}

#pragma mark - QAreaFilterViewDelegate
- (void)didChangeArea:(QRegionModel*)model
{
    _areaModel = model;
    
    [self updateHeaderFilterTitle];
    
    _dataPage.nextPage = 1;
    [_groupBuyWashingCarTableView.legendHeader beginRefreshing];
}

- (void)didHideAreaView
{
    _btnRegion.imageView.transform = CGAffineTransformRotate(_btnRegion.imageView.transform, M_PI);
    [self performSelector:@selector(removeAreaView) withObject:nil afterDelay:0.02];
}

- (void)removeAreaView
{
    [_filterView2 removeFromSuperview];
    _filterView2 = nil;
}

#pragma mark - QThirdFilterViewDelegate
- (void)didChangeKey:(QFilterKeyModel*)model;
{
    _keyModel = model;
    
    [self updateHeaderFilterTitle];
    
    _dataPage.nextPage = 1;
    [_groupBuyWashingCarTableView.legendHeader beginRefreshing];
}

- (void)didHideThirdFilterView
{
    _btnKey.imageView.transform = CGAffineTransformRotate(_btnKey.imageView.transform, M_PI);
    [self performSelector:@selector(removeThirdView) withObject:nil afterDelay:0.02];
}

- (void)removeThirdView
{
    [_filterView3 removeFromSuperview];
    _filterView3 = nil;
}

@end
