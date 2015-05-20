//
//  QHomePage.m
//  HRClient
//
//  Created by chenyf on 14/12/2.
//  Copyright (c) 2014年 panyj. All rights reserved.
//

#import "QHomePage.h"
#import "QViewController.h"
#import "QCategoryView.h"
#import "QCategoryFilterView.h"
#import "QHttpMessageManager.h"
#import "QHotCityModel.h"
#import "QThirdFilterView.h"
#import "QLocationManager.h"
#import "QGroupBuyWashingCarCell.h"
#import "QMapPage.h"
#import "MJRefresh.h"
#import "QHomePageModel.h"

@interface QHomePage ()<QCategoryDelegate>
{
    QRegionModel *_currentRegionModel;
    BOOL _isCityChanged;
    
    UIButton *_btnCity;
}

@property (nonatomic) QCategoryView *categoryView;
@property (nonatomic,strong) UIView *footerView;
@property (nonatomic) UITableView *recommendTableView;
@property (nonatomic) NSMutableArray *recommendList;
@property (nonatomic)QCategoryFilterView *filterView1;
@property (nonatomic,strong)NSArray *infroArr;
@end

@implementation QHomePage

- (QCacheType)pageCacheType
{
    return kCacheTypeAlways;
}

- (QNavigationType)navigationType
{
    return kNavigationTypeNormal;
}

- (void)setActiveWithParams:(NSDictionary *)params
{
    NSNumber *CityChanged = [params objectForKey:@"CityChanged"];
    if (CityChanged && [CityChanged boolValue]) {
        _isCityChanged = YES;
        _currentRegionModel = [QRegionModel defaultRegionModel];
    }
}

- (void)pageEvent:(QPageEventType)eventType
{
    if (eventType == kPageEventWillShow)
    {
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(locationDone:) name:Noti_Location_Done object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(acquireHomeInfro:) name:kHomePage object:nil];
        if (_isCityChanged)
        {
            [_btnCity setTitle:_currentRegionModel.regionName forState:UIControlStateNormal];
            if (![QLocationManager sharedInstance].geoResult)
            {
                [[QLocationManager sharedInstance] startUserLocation];
            }
            
            CLLocationCoordinate2D point = [QLocationManager sharedInstance].geoPoint;
            [self tryGetHomeList:point.longitude andlatitude:point.latitude];
            [ASRequestHUD show];
        }
        
        _isCityChanged = NO;
    }
    else if (eventType == kPageEventWillHide)
    {
        [[NSNotificationCenter defaultCenter] removeObserver:self name:kHomePage object:nil];
        [[NSNotificationCenter defaultCenter] removeObserver:self name:Noti_Location_Done object:nil];
    }
    else if (eventType == kPageEventViewCreate)
    {
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(getDataFailed:) name:kInterfaceFailed object:nil];
        
        _isCityChanged = YES;
        _currentRegionModel = [QRegionModel defaultRegionModel];
        NSMutableArray *mArray = [[NSMutableArray alloc] initWithCapacity:0];
        for (NSDictionary *dict in [QConfigration readConfigForKey:HomeProducts])
        {
            QHomePageModel *model = [QHomePageModel getModelFromHomePage:dict];
            [mArray addObject:model];
        }
        _infroArr = mArray;
        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(successAutoLogin:) name:kLogin object:nil];
        
        [self loadData];
    }
    else if (eventType == kPageEventViewDispose)
    {
        [[NSNotificationCenter defaultCenter] removeObserver:self];
    }
}

- (UIBarButtonItem *)pageLeftMenu
{
    UIButton *cityBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    cityBtn.titleLabel.font = [UIFont systemFontOfSize:16.0f];
    [cityBtn sizeToFit];
    [cityBtn setTitle:_currentRegionModel.regionName forState:UIControlStateNormal];
    //[cityBtn setImage:IMAGEOF(@"push_down") forState:UIControlStateNormal];
    //[cityBtn setImageEdgeInsets:UIEdgeInsetsMake(0, 38, 0, 0)];
    //[cityBtn setTitleEdgeInsets:UIEdgeInsetsMake(0, -10, 0, 0)];
    [cityBtn addTarget:self action:@selector(gotoCityList:) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem *cityItem = [[UIBarButtonItem alloc] initWithCustomView:cityBtn];
    _btnCity = cityBtn;
    
    return cityItem;
}

- (UIBarButtonItem *)pageRightMenu
{
    UIButton *mapBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    mapBtn.frame = CGRectMake(0, 0, 44, 44);
    [mapBtn setImage:[UIImage imageNamed:@"map.png"] forState:UIControlStateNormal];
    [mapBtn addTarget:self action:@selector(gotoMap) forControlEvents:UIControlEventTouchUpInside];
    [mapBtn sizeToFit];
    UIBarButtonItem *mapItem = [[UIBarButtonItem alloc] initWithCustomView:mapBtn];
    return mapItem;
}

- (UIView*)titleViewWithFrame:(CGRect)frame
{
    UIView *titleView = [[UIView alloc] initWithFrame:CGRectMake(65, 9, SCREEN_SIZE_WIDTH - 2*65, 28)];
    titleView.backgroundColor = [UIColor whiteColor];
    [titleView sizeToFit];
    titleView.layer.masksToBounds = YES;
    titleView.layer.cornerRadius = 5.0;
    titleView.userInteractionEnabled = YES;
    
    //增加手势
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(gotoSearch)];
    [titleView addGestureRecognizer:tap];
    titleView.backgroundColor = [QTools colorWithRGB:255 :255 :255];
    
    //image
    UIImageView *searchImageView = [[UIImageView alloc] initWithFrame:CGRectMake(10, 5, 16, 16)];
    searchImageView.image = IMAGEOF(@"search_.png");
    [titleView addSubview:searchImageView];
    
    UILabel *titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(searchImageView.deFrameRight + 10, 0, titleView.deFrameRight - searchImageView.deFrameRight, titleView.deFrameHeight)];
    titleLabel.text = @"找商家";
    titleLabel.backgroundColor = [UIColor clearColor];
    titleLabel.font = [UIFont systemFontOfSize:14];
    titleLabel.textColor = [QTools colorWithRGB:194 :194 :194];
    [titleView addSubview:titleLabel];
    
    return titleView;
}

- (QBottomMenuType)bottomMenuType
{
    return kBottomMenuTypeNormal;
}

- (UIView *)viewWithFrame:(CGRect)frame
{
    if ([super viewWithFrame:frame]) {
        
        //菜单-8个类别
        QCategoryView *categoryView = [[QCategoryView alloc] initWithFrame:CGRectMake(0, 0, frame.size.width, 160)];
        categoryView.delegate = self;
        
        UIView *headerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, frame.size.width, 170)];
        headerView.backgroundColor = [QTools colorWithRGB:238 :238 :238];
        [headerView addSubview:categoryView];
        
        //团购推荐列表
        _recommendTableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, frame.size.width, frame.size.height) style:UITableViewStylePlain];
        _recommendTableView.separatorStyle = UITableViewCellSeparatorStyleNone;
        _recommendTableView.delegate = self;
        _recommendTableView.dataSource = self;
        _recommendTableView.tableHeaderView = headerView;
        _recommendTableView.backgroundColor = [QTools colorWithRGB:238 :238 :238];
        [_view addSubview:_recommendTableView];
        
        [_recommendTableView addLegendHeaderWithRefreshingTarget:self refreshingAction:@selector(headerRereshing)];
        
        //加载数据
        [self loadData];
    }
    
    return _view;
}

- (UIView*)footerView
{
    if (!_footerView) {
        _footerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, _recommendTableView.deFrameWidth, 40)];
        UIButton *moreButton = [UIButton buttonWithType:UIButtonTypeCustom];
        moreButton.frame = CGRectMake(10, 5, _footerView.deFrameWidth - 20, 30);
        moreButton.backgroundColor = UIColorFromRGB(0xc40000);
        moreButton.titleLabel.font = [UIFont systemFontOfSize:14];
        moreButton.layer.cornerRadius = 3.f;
        moreButton.layer.masksToBounds = YES;
        [moreButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [moreButton setTitle:@"点击查看全部服务" forState:UIControlStateNormal];
        [moreButton addTarget:self action:@selector(gotoMore) forControlEvents:UIControlEventTouchUpInside];
        [_footerView addSubview:moreButton];
    }
    return _footerView;
}

#pragma mark - Private

- (void)loadData
{
    //数据源
    self.recommendList = [[NSMutableArray alloc] initWithCapacity:10];
    [_recommendTableView reloadData];
}

- (void)tryGetHomeList:(double)longitude andlatitude:(double)latitude
{
    NSString *lon = longitude ? [[NSNumber numberWithDouble:latitude] stringValue] : @"";
    NSString *lat = latitude ? [[NSNumber numberWithDouble:longitude] stringValue] : @"";
    [[QHttpMessageManager sharedHttpMessageManager] accessHomePageList:[_currentRegionModel.regionId stringValue]
                                                          andLongitude:lon
                                                           andLatitude:lat
                                                        andCurrentPage:@"1"];
}

- (void)headerRereshing
{
    CLLocationCoordinate2D point = [QLocationManager sharedInstance].geoPoint;
    [self tryGetHomeList:point.longitude andlatitude:point.latitude];
}

#pragma mark - Action

- (void)gotoMap
{
    [QViewController gotoPage:@"QMapPage" withParam:[[NSDictionary alloc] initWithObjectsAndKeys:[NSNumber numberWithInt:kMapTypeProduct], @"MapType", nil]];
}

- (void)gotoSearch
{
    [QViewController gotoPage:@"QTitleSearch" withParam:nil];
}

- (void)gotoCityList:(UIButton *)sender
{
    [QViewController gotoPage:@"QCityChange" withParam:nil];
}

- (void)gotoMore
{
    NSMutableDictionary *dic = [[NSMutableDictionary alloc] initWithCapacity:0];
    [dic setObject:[QFilterKeyModel filterModelbyKey:kIntelligenceKey andListType:kDataProductType] forKey:@"QFilterKeyModel"];
    [dic setObject:[QCategoryModel nullCategory] forKey:@"QCategoryModel"];
    [QViewController gotoPage:@"QGroupBuyWashingCarPage" withParam:dic];
}

#pragma mark - Notification

- (void)getDataFailed:(NSNotification*)noti
{
    if (_recommendTableView.legendHeader.isRefreshing)
        [_recommendTableView.legendHeader endRefreshing];
}

- (void)acquireHomeInfro:(NSNotification *)noti
{
    _infroArr = noti.object;
    
    [ASRequestHUD dismiss];
    _recommendTableView.tableFooterView = self.footerView;
    [_recommendTableView reloadData];
    
    //自动登录
    BOOL isAutoLogin = [[ASUserDefaults objectForKey:LoginIsAutoLogin] boolValue];
    if (isAutoLogin && ![QUser sharedQUser].isLogin) {
        
        NSString *user = [ASUserDefaults objectForKey:LoginUserPhone];
        NSString *password = [ASUserDefaults objectForKey:LoginUserPassCode];
        [[QHttpMessageManager sharedHttpMessageManager] accessLogin:user andPassword:password];
    }
    
    if (_recommendTableView.legendHeader.isRefreshing)
        [_recommendTableView.legendHeader endRefreshing];
}

- (void)successAutoLogin:(NSNotification*)noti {
 
    QLoginModel *loginModel = noti.object;
    if (loginModel) {
        [QUser sharedQUser].isLogin = YES;
        [loginModel savetoLocal:[ASUserDefaults objectForKey:LoginUserPassCode]];
        [[QUser sharedQUser] updateUserInfo];
    }
    
    [[QUser sharedQUser] updateUserInfo]; //更新数据
}

- (void)locationDone:(NSNotification*)noti
{
    CLLocationCoordinate2D point = [QLocationManager sharedInstance].geoPoint;
    [self tryGetHomeList:point.longitude andlatitude:point.latitude];
}

#pragma mark - UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return _infroArr.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 1 + 1;
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
            cell.backgroundColor = [QTools colorWithRGB:238 :238 :238];
        }
        return cell;
    }
    
    static NSString *CellIdentifier = @"Cell_Identifier_GroupBuyList";
    QGroupBuyWashingCarCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (nil == cell) {
        cell = [[QGroupBuyWashingCarCell alloc] initWithStyle:UITableViewCellStyleDefault
                                              reuseIdentifier:CellIdentifier];
    }
    [cell configureCellForWash:_infroArr andIndexPath:indexPath];
    return cell;
}

#pragma mark - UITableViewDelegate

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 35;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    static NSString *HeaderIdentifier = @"HeaderIdentifier";
    QGroupBuyCellHeadView *headerView = [tableView dequeueReusableHeaderFooterViewWithIdentifier:HeaderIdentifier];
    if (!headerView)
    {
        headerView = [[QGroupBuyCellHeadView alloc] initWithReuseIdentifier:HeaderIdentifier andRect:CGRectMake(0, 0, tableView.deFrameWidth, 35)];
    }
    
    if (_infroArr.count <= section) {
        return headerView;
    }
    QHomePageModel *model = [_infroArr objectAtIndex:section];
    [headerView setCompanyName:model.companyName andRegionName:model.regionName andDistance:nil];
    
    return headerView;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.row == [self tableView:tableView numberOfRowsInSection:indexPath.section] - 1) {
        return 10;
    }
    return 100;
}

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
        QHomePageModel *model = _infroArr[indexPath.section];
        [QViewController gotoPage:@"QGroupBuyDetailPage" withParam:[NSDictionary dictionaryWithObjectsAndKeys:model.productId, @"ProductID", nil]];
    }
}

#pragma mark - QCategoryDelegate

- (void)category:(QCategoryView *)categoryView selected:(QCategoryModel *)category
{
    NSMutableDictionary *dic = [[NSMutableDictionary alloc] initWithCapacity:0];
    
    if ([category.categoryId intValue] == 0)
    {
        // 更多分类
        [QViewController gotoPage:@"QMoreCategoryPage" withParam:nil];
    }
    else if ([category.categoryId intValue] == 2)
    {
        //今日新单
        [dic setObject:[QFilterKeyModel filterModelbyKey:kNewestKey andListType:kDataProductType] forKey:@"QFilterKeyModel"];
        [dic setObject:[QCategoryModel nullCategory] forKey:@"QCategoryModel"];
        [QViewController gotoPage:@"QGroupBuyWashingCarPage" withParam:dic];
    }
    else if ([category.categoryId intValue] == 1)
    {
        // 洗车
        QCategoryModel *model = [[QCategoryModel alloc] init];
        model.categoryId = [NSNumber numberWithInt:1];  //隐含逻辑,点击洗车进入获取到得列表只包括普洗
        model.categoryName = @"普洗轿车";
        [dic setObject:[QFilterKeyModel filterModelbyKey:kIntelligenceKey andListType:kDataProductType] forKey:@"QFilterKeyModel"];
        [dic setObject:model forKey:@"QCategoryModel"];
        [QViewController gotoPage:@"QGroupBuyWashingCarPage" withParam:dic];
    }
    else
    {
        [dic setObject:[QFilterKeyModel filterModelbyKey:kIntelligenceKey andListType:kDataProductType] forKey:@"QFilterKeyModel"];
        [dic setObject:category forKey:@"QCategoryModel"];
        [QViewController gotoPage:@"QGroupBuyWashingCarPage" withParam:dic];
    }
}

@end
