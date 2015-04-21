//
//  QBusinessPage.m
//  HRClient
//
//  Created by chenyf on 14/12/4.
//  Copyright (c) 2014年 panyj. All rights reserved.
//

#import "QBusinessPage.h"
#import "QBussinessCell.h"
#import "QViewController.h"
#import "QHttpMessageManager.h"
#import "QCategoryFilterView.h"
#import "QAreaFilterView.h"
#import "QThirdFilterView.h"
#import "QLocationManager.h"
#import "QDataPaging.h"
#import "QMapPage.h"
#import "MJRefresh.h"

@interface QBusinessPage ()<QCategoryFilterViewDelegate, QAreaFilterViewDelegate, QThirdFilterViewDelegate>
{
    QCategoryModel *_category;
    QCategorySubModel *_subCategory;
    QRegionModel *_areaModel;
    QFilterKeyModel *_keyModel;
    UIButton *_btnCategory;
    UIButton *_btnRegion;
    UIButton *_btnKey;
    
    UILabel *_lbLocaiton;
}
@property (nonatomic, strong) UIView *headFilterView;
@property (nonatomic) QCategoryFilterView *filterView1;
@property (nonatomic) QAreaFilterView *filterView2;
@property (nonatomic) QThirdFilterView *filterView3;

@property (nonatomic) UITableView *groupBuyTableView;
@property (nonatomic, strong) UIView *footerView;

@property (nonatomic, strong) QDataPaging *dataPage;
@end

@implementation QBusinessPage

#pragma mark - view

- (QCacheType)pageCacheType
{
    return kCacheTypeAlways;
}

- (void)pageEvent:(QPageEventType)eventType
{
    if (eventType == kPageEventWillShow)
    {
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(locationDone:) name:Noti_Location_Done object:nil];
        
        if ([QLocationManager sharedInstance].geoResult) {
            NSString *address = @"当前:";
            _lbLocaiton.text = [address stringByAppendingString:[QLocationManager sharedInstance].geoResult.address];
        }
        else {
            [[QLocationManager sharedInstance] startUserLocation];
        }
    }
    else if (eventType == kPageEventWillHide)
    {
        [[NSNotificationCenter defaultCenter] removeObserver:self name:Noti_Location_Done object:nil];
    }
    else if (eventType == kPageEventViewDispose)
    {
        [[NSNotificationCenter defaultCenter] removeObserver:self];
    }
    else if (eventType == kPageEventViewCreate)
    {
        _dataPage = [[QDataPaging alloc] init];
        _dataPage.pageSize = 10;
        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(getDataFailed:) name:kInterfaceFailed object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(getBusinessList:) name:kBusinessList object:nil];
        [_groupBuyTableView.legendHeader beginRefreshing];
    }
}

- (QBottomMenuType)bottomMenuType
{
    return kBottomMenuTypeNormal;
}

- (UIView *)viewWithFrame:(CGRect)frame
{
    if ([super viewWithFrame:frame]) {
        
        //数据初始化
        _category = [QCategoryModel nullCategory];
        _areaModel = [QRegionModel nullRegion];
        _keyModel = [QFilterKeyModel filterModelbyKey:kIntelligenceKey andListType:kDataBusinuessType];
        
        CGFloat h = self.headFilterView.deFrameBottom;
        [self updateHeaderFilterTitle];
        //位置信息
        UIView *headerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, frame.size.width, 34)];
        headerView.backgroundColor = [UIColor clearColor];
        
        UIButton *refreshLocationButton = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 40, 34)];
        [refreshLocationButton setImage:IMAGEOF(@"location_refresh") forState:UIControlStateNormal];
        refreshLocationButton.deFrameRight = headerView.frame.size.width - 10;
        [refreshLocationButton addTarget:self action:@selector(onBtnRefreshLocation:) forControlEvents:UIControlEventTouchUpInside];
        [headerView addSubview:refreshLocationButton];
        
        UILabel *locationLabel = [[UILabel alloc] initWithFrame:CGRectMake(10, 0, headerView.deFrameWidth - 50 - 10, headerView.deFrameHeight)];
        locationLabel.text = @"正在定位中...";
        locationLabel.font = [UIFont systemFontOfSize:12];
        locationLabel.textColor = [QTools colorWithRGB:135 :134 :132];
        [headerView addSubview:locationLabel];
        _lbLocaiton = locationLabel;
        
        UIView *lineView = [[UIView alloc] initWithFrame:CGRectMake(0, headerView.frame.size.height - .5f, headerView.frame.size.width, .5f)];
        lineView.backgroundColor = ColorLine;
        [headerView addSubview:lineView];
        
        // 团购列表
        _groupBuyTableView = [[UITableView alloc] initWithFrame:CGRectMake(0, h, frame.size.width, frame.size.height - h) style:UITableViewStylePlain];
        _groupBuyTableView.separatorStyle = UITableViewCellSeparatorStyleNone;
        _groupBuyTableView.delegate = self;
        _groupBuyTableView.dataSource = self;
        _groupBuyTableView.tableHeaderView = headerView;
        _groupBuyTableView.backgroundColor = [QTools colorWithRGB:238 :238 :238];
        [_view addSubview:_groupBuyTableView];
        
        [_groupBuyTableView addLegendHeaderWithRefreshingTarget:self refreshingAction:@selector(headerRereshing)];
    }
    
    return _view;
}
/* 暂时注释,以后可能有用
- (UIView *)titleViewWithFrame:(CGRect)frame{
    NSArray *items = [NSArray arrayWithObjects:@"更多商家",@"优惠商家",nil];
    UISegmentedControl *segmentControl = [[UISegmentedControl alloc] initWithItems:items];
    segmentControl.frame = CGRectMake((SCREEN_SIZE_WIDTH - 180)/2.0, 5, 180, 34);
    //        选中的颜色
    segmentControl.layer.borderWidth = 0.0;
    segmentControl.tintColor = [QTools colorWithRGB:255 :255 :255];
    segmentControl.selectedSegmentIndex = 0;
    //        字体大小
    NSDictionary *attributes = [NSDictionary dictionaryWithObjectsAndKeys:[UIFont systemFontOfSize:15],NSFontAttributeName,[QTools colorWithRGB:255 :255 :255], NSForegroundColorAttributeName, nil];
    [segmentControl setTitleTextAttributes:attributes forState:UIControlStateNormal];
    [segmentControl addTarget:self action:@selector(segmentedControl:) forControlEvents:UIControlEventValueChanged];
    [_view addSubview:segmentControl];
    return segmentControl;
}
*/
- (NSString *)title
{
    return @"商家列表";
}

- (UIBarButtonItem*)pageRightMenu{
    _view.backgroundColor = [QTools colorWithRGB:240 :239 :237];
    UIButton *editBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    editBtn.frame = CGRectMake(0, 0, 40, 10);
    [editBtn setImage:[UIImage imageNamed:@"search2.png"] forState:UIControlStateNormal];
    [editBtn setTitleColor:[QTools colorWithRGB:255 :255 :255] forState:UIControlStateNormal];
    editBtn.titleLabel.font = [UIFont boldSystemFontOfSize:18];
    [editBtn addTarget:self action:@selector(setEditig) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem *editItem = [[UIBarButtonItem alloc] initWithCustomView:editBtn];
    return editItem;
}

- (UIBarButtonItem *)pageLeftMenu{
    UIButton *editBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    editBtn.frame = CGRectMake(0, 0, 40, 10);
    [editBtn setImage:[UIImage imageNamed:@"map.png"] forState:UIControlStateNormal];
    [editBtn setTitleColor:[QTools colorWithRGB:255 :255 :255] forState:UIControlStateNormal];
    editBtn.titleLabel.font = [UIFont boldSystemFontOfSize:18];
    [editBtn addTarget:self action:@selector(setLoacrion) forControlEvents:UIControlEventTouchUpInside];
    //editBtn.backgroundColor = [UIColor yellowColor];
    UIBarButtonItem *editItem = [[UIBarButtonItem alloc] initWithCustomView:editBtn];
    return editItem;
}

- (UIView*)footerView
{
    if (!_footerView) {
        _footerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, _groupBuyTableView.deFrameWidth, _groupBuyTableView.deFrameHeight - 38)];
        _footerView.backgroundColor = [UIColor clearColor];
        
        UIImageView *imageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"icon_no_data"]];
        [_footerView addSubview:imageView];
        imageView.center = CGPointMake(_footerView.center.x, _footerView.center.y - 20);
        
        UILabel *label = [[UILabel alloc] init];
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

- (void)headerRereshing
{
    _dataPage.nextPage = 1;
    [self tryGetBusinessList];
}

- (void)footerLoading
{
    [self tryGetBusinessList];
}

#pragma mark - Action
- (void)buttonTapped:(UIButton *)sender
{
    QBaseFilterView *view = nil;
    switch (sender.tag) {
        case 1: // 类别
        {
            if (!_filterView1) {
                _filterView1 = [[QCategoryFilterView alloc] initWithFrame:CGRectMake(0, self.headFilterView.deFrameBottom, _groupBuyTableView.deFrameWidth, _groupBuyTableView.deFrameHeight)];
                _filterView1.delegate = self;
                [_view addSubview:_filterView1];
            }
            
            view = _filterView1;
        }
            break;
        case 2: // 城区
        {
            if (!_filterView2) {
                _filterView2 = [[QAreaFilterView alloc] initWithFrame:CGRectMake(0, self.headFilterView.deFrameBottom, _groupBuyTableView.deFrameWidth, _groupBuyTableView.deFrameHeight)];
                _filterView2.delegate = self;
                [_view addSubview:_filterView2];
            }
        }
            
            view = _filterView2;
            break;
        case 3:
        {
            if (!_filterView3) {
                _filterView3 = [[QThirdFilterView alloc] initWithFrame:CGRectMake(0, self.headFilterView.deFrameBottom, _groupBuyTableView.deFrameWidth, _groupBuyTableView.deFrameHeight) andListType:kDataBusinuessType];
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

- (void)setEditig{
    [QViewController gotoPage:@"QTitleSearch" withParam:nil];
}

- (void)setLoacrion
{
    [QViewController gotoPage:@"QMapPage" withParam:[[NSDictionary alloc] initWithObjectsAndKeys:[NSNumber numberWithInt:kMapTypeProduct], @"MapType", nil]];
}

- (void)onBtnRefreshLocation:(UIButton *)sender
{
    _lbLocaiton.text = @"正在定位中...";
    [[QLocationManager sharedInstance] startUserLocation];
}


#pragma mark - Notification

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

- (void)tryGetBusinessList
{
    NSNumber *regionID;
    if (_areaModel.regionId)
        regionID = _areaModel.regionId;     //当前城市,指定区域
    else
        regionID = [ASUserDefaults objectForKey:CurrentRegionID]; //当前城市,全城
    
    NSNumber *categoryID;
    if (_subCategory)
        categoryID = _subCategory.categoryId;
    else if (_category)
        categoryID = _category.categoryId;

    if (kNearestKey == _keyModel.keyType)
    {
        CLLocationCoordinate2D point = [QLocationManager sharedInstance].geoPoint;
        NSNumber *longtitude = point.longitude ? [NSNumber numberWithDouble:point.longitude] : nil;
        NSNumber *latitude = point.latitude ? [NSNumber numberWithDouble:point.latitude] : nil;
        [[QHttpMessageManager sharedHttpMessageManager] accessBusinessListThourghLocation:NSString_No_Nil([regionID stringValue])
                                                                              andCategory:NSString_No_Nil([categoryID stringValue])
                                                                             andLongitude:longtitude
                                                                              andLatitude:latitude
                                                                           andCurrentPage:INTTOSTRING(_dataPage.nextPage)
                                                                              andPageSize:INTTOSTRING(_dataPage.pageSize)];
    }
    else
    {
        [[QHttpMessageManager sharedHttpMessageManager] accessBusinessListThourghLocation:NSString_No_Nil([regionID stringValue])
                                                                              andCategory:NSString_No_Nil([categoryID stringValue])
                                                                             andLongitude:nil
                                                                              andLatitude:nil
                                                                           andCurrentPage:INTTOSTRING(_dataPage.nextPage)
                                                                              andPageSize:INTTOSTRING(_dataPage.pageSize)];
    }
}

- (void)getDataFailed:(NSNotification*)notify
{
    if (_groupBuyTableView.legendHeader.isRefreshing)
        [_groupBuyTableView.legendHeader endRefreshing];
    if (_groupBuyTableView.legendFooter.isRefreshing)
        [_groupBuyTableView.legendFooter endRefreshing];
}

- (void)getBusinessList:(NSNotification*)notify
{    
    //数据处理
    [_dataPage setMData:notify.object];
    _dataPage.nextPage++;
    
    //tableview刷新
    if (_groupBuyTableView.legendHeader.isRefreshing)
        [_groupBuyTableView.legendHeader endRefreshing];
    if (_groupBuyTableView.legendFooter.isRefreshing)
        [_groupBuyTableView.legendFooter endRefreshing];
    
    if(_dataPage.mData.count < (_dataPage.nextPage - 1) * _dataPage.pageSize) //表示不需要loading
        [_groupBuyTableView removeFooter];
    else
    {
        if (!_groupBuyTableView.legendFooter)
            [_groupBuyTableView addLegendFooterWithRefreshingTarget:self refreshingAction:@selector(footerLoading)];
    }
    
    if (_dataPage.mData.count < 1)
        _groupBuyTableView.tableFooterView = self.footerView;
    else
        _groupBuyTableView.tableFooterView = nil;
    
    [_groupBuyTableView reloadData];
}

#pragma mark - UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return _dataPage.mData.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 89;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell_Identifier_Business";
    QBussinessCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (nil == cell) {
        cell = [[QBussinessCell alloc] initWithStyle:UITableViewCellStyleDefault
                                    reuseIdentifier:CellIdentifier];
    }
    [cell configureCellForHomePage:_dataPage.mData andIndexPath:indexPath];
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
    QBusinessListModel *model = _dataPage.mData[indexPath.row];
    [QViewController gotoPage:@"QBusinessDetailPage"
                    withParam:[NSDictionary dictionaryWithObjectsAndKeys:model.companyId, @"companyID", nil]];
}


#pragma mark - QCategoryFilterViewDelegate
- (void)didChangeCategory:(QCategoryModel *)model sub:(QCategorySubModel *)subModel
{
    _category = model;
    _subCategory = subModel;
    
    [self updateHeaderFilterTitle];
    
    _dataPage.nextPage = 1;
    [_groupBuyTableView.legendHeader beginRefreshing];
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
    [_groupBuyTableView.legendHeader beginRefreshing];
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
    [_groupBuyTableView.legendHeader beginRefreshing];
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
