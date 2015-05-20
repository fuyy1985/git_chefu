//
//  QMapPage.m
//  HRClient
//
//  Created by ekoo on 14/12/30.
//  Copyright (c) 2014年 panyj. All rights reserved.
//

#import "QMapPage.h"
#import "QViewController.h"
#import "QLocationManager.h"
#import "QDataPaging.h"
#import "QCategoryFilterView.h"
#import "QHttpMessageManager.h"
#import "QHomePageModel.h"
#import "QBusinessListModel.h"
#import "CustomWindow.h"

@interface QMapListView : UIView<UITableViewDataSource, UITableViewDelegate,UIGestureRecognizerDelegate>

@property (nonatomic, strong) CustomWindow *selfWindow;
@property (nonatomic, strong) NSArray *subCategoryID;
@property (nonatomic, strong) NSArray *products;
@property (nonatomic, strong) UITableView *tableView;

@end

@implementation QMapListView

- (void)dealloc
{
}

- (UITableView*)tableView
{
    if (!_tableView) {
        _tableView = [[UITableView alloc] initWithFrame:self.bounds];
        _tableView.backgroundColor = [UIColor whiteColor];
        _tableView.dataSource = self;
        _tableView.delegate = self;
        [self addSubview:_tableView];
    }
    return _tableView;
}

+ (UIImage*)pointImage:(NSNumber*)categoryID andSubCategorys:(NSArray*)array
{
    int parentCategoryID = [categoryID intValue];
    for (QCategorySubModel *subModel in array)
    {
        if ([subModel.categoryId isEqualToNumber:categoryID])
        {
            parentCategoryID = [subModel.parentId intValue];
            break;
        }
    }
    
    NSString *icon = @"";
    switch (parentCategoryID) {
        case 1://洗车 1
            icon = @"icon_map_xiche";
            break;
        case 6://保养 6
            icon = @"icon_map_baoyang";
            break;
        case 10://抛光美容 10
            icon = @"icon_map_paoguang";
            break;
        case 18://油漆 18
            icon = @"icon_map_buqi";
            break;
        case 45://轮胎服务 45
            icon = @"icon_map_luntai";
            break;
        case 52://新胎 52
            icon = @"icon_map_xintai";
            break;
        case 23://装潢改装 23
            icon = @"icon_map_zhuanghuang";
            break;
        case 36://维修服务 36
            icon = @"icon_map_weixiu";
            break;
        case 74://相关服务 74
            icon = @"icon_map_xiangguang";
            break;
        default:
            break;
    }
    return [UIImage imageNamed:icon];
}

- (void)show
{
    UIViewController* avc = [[UIViewController alloc] init];
    avc.view.backgroundColor = [UIColor colorWithRed:0/255.0 green:0/255.0 blue:0/255.0 alpha:0.3];
    
    _selfWindow = [[CustomWindow alloc] initWithFrame:[UIApplication sharedApplication].keyWindow.bounds];
    _selfWindow.alpha = 0.0;
    _selfWindow.rootViewController = avc;
    [_selfWindow makeKeyAndVisible];
    
    [self.tableView reloadData];
    
    [UIView animateWithDuration:0.2 animations: ^{
        _selfWindow.alpha = 1;
    }];
    
    //取消手势
    UITapGestureRecognizer *gesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(onCancel:)];
    gesture.delegate = self;
    [avc.view addGestureRecognizer:gesture];
    
    CGRect frame = self.frame;
    frame.origin.y = CGRectGetHeight(_selfWindow.frame);
    self.frame = frame;
    [avc.view addSubview:self];
    
    [UIView animateWithDuration:0.2 animations: ^{
        CGRect frame = self.frame;
        frame.origin.y = (SCREEN_SIZE_HEIGHT - self.deFrameHeight)/2;
        self.frame = frame;
    }];
}

- (void)dismiss
{
    self.window.backgroundColor = [UIColor clearColor];
    self.window.alpha = 1;
    
    [UIView animateWithDuration: 0.2
                     animations: ^{
                         [self.window resignKeyWindow];
                         self.window.alpha = 0;
                     }
                     completion: ^(BOOL finished) {
                         _selfWindow = nil;
                     }];
    
    [UIView commitAnimations];
}

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch
{
    if ([touch.view.superview isKindOfClass:[UITableViewCell class]]) {
        return NO;
    }
    return YES;
}

- (void)onCancel:(UITapGestureRecognizer *)sender
{
    CGPoint point = [sender locationInView:[self superview]];
    if (point.y < self.deFrameTop || point.y > self.deFrameBottom) {
        [self dismiss];
    }
}

#pragma mark - UITableViewDataSource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.products.count;
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *idendifier = @"cell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:idendifier];
    if (!cell)
    {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:idendifier];
    }
    
    [cell.contentView.subviews makeObjectsPerformSelector:@selector(removeFromSuperview)];
    
    if (self.products.count <= indexPath.row)
        return cell;
    
    QProductModel *model = [self.products objectAtIndex:indexPath.row];
    
    UIImageView *imageView = [[UIImageView alloc] initWithImage:[QMapListView pointImage:model.categoryId andSubCategorys:self.subCategoryID]];
    [cell.contentView addSubview:imageView];
    imageView.deFrameLeft = 10;
    imageView.deFrameTop = (64 - imageView.deFrameHeight)/2;
    
    CGFloat left = imageView.deFrameRight + 5;
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(left, 5, tableView.deFrameWidth - left - 10, 20)];
    label.backgroundColor = [UIColor clearColor];
    label.font = [UIFont boldSystemFontOfSize:14];
    label.textColor = ColorDarkGray;
    label.text = model.companyName;
    [cell.contentView addSubview:label];
    
    label = [[UILabel alloc] initWithFrame:CGRectMake(label.deFrameLeft, label.deFrameBottom, label.deFrameWidth, 15)];
    label.font = [UIFont systemFontOfSize:12];
    label.backgroundColor = [UIColor clearColor];
    label.textColor = [QTools colorWithRGB:150 :150 : 150];
    label.text = model.subject;
    [cell.contentView addSubview:label];
    
    label = [[UILabel alloc] initWithFrame:CGRectMake(label.deFrameLeft, label.deFrameBottom, label.deFrameWidth, 15)];
    label.font = [UIFont systemFontOfSize:13];
    label.backgroundColor = [UIColor clearColor];
    label.textColor = ColorDarkGray;
    label.text = [NSString stringWithFormat:@"%.2f", [model.member_bidPrice doubleValue]];
    [cell.contentView addSubview:label];
    
    return cell;
}

#pragma mark - UITableViewDelegate

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 64;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (self.products.count <= indexPath.row)
        return ;
    
    [self dismiss];
    
    QProductModel *model = [self.products objectAtIndex:indexPath.row];
    
    [QViewController gotoPage:@"QGroupBuyDetailPage" withParam:[NSDictionary dictionaryWithObjectsAndKeys:model.productId, @"ProductID", nil]];
    [tableView deselectRowAtIndexPath:indexPath animated:NO];
}


@end

@interface QMapPage ()<QCategoryFilterViewDelegate>
{
    QMapType _type;
    BMKLocationService* _locService;
    QDataPaging *_dataPage;
    QCategoryModel *_category;
    QCategorySubModel *_subCategory;
    NSArray *_annotations;
    
    NSArray *_subCategoryID;
}

@property (nonatomic, strong) UIView *titleView;
@property (nonatomic, strong) UIButton *btnCategory;
@property (nonatomic, strong) UIButton *btnLocation;
@property (nonatomic, strong) UIButton *btnList;
@property (nonatomic, strong) QCategoryFilterView *cateFilterView;

@end

@implementation QMapPage

- (void)dealloc
{
    if (_mapView) {
        _mapView = nil;
    }
}

- (QNavigationType)navigationType
{
    return kNavigationTypeNone;
}

- (void)setActiveWithParams:(NSDictionary *)params
{
    _type = [[params objectForKey:@"MapType"] intValue];
}

- (void)pageEvent:(QPageEventType)eventType
{
    if (eventType == kPageEventViewCreate)
    {
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(successGetProducts:) name:kCarWashList object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(successGetBusiness:) name:kBusinessList object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(successGetSubCategoryIDList:) name:kCategorySubList object:nil];
        _dataPage = [[QDataPaging alloc] init];
        _dataPage.nextPage = 1;
        _dataPage.pageSize = 100;
        
        _locService = [[BMKLocationService alloc]init];
        
        //设置地图级别
        [_mapView setZoomLevel:7];
        _mapView.isSelectedAnnotationViewFront = YES;
        
        //定位服务是否可用
        BOOL enable = [CLLocationManager locationServicesEnabled];
        //是否具有定位权限
        int status = [CLLocationManager authorizationStatus];
        BOOL canStartLocation = !(!enable || status<3);
        if(!canStartLocation){
            UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"定位服务未开启"
                                                                message:@"请在系统设置中开启定位服务"
                                                               delegate:self
                                                      cancelButtonTitle:@"暂不"
                                                      otherButtonTitles:@"好", nil];
            [alertView show];
            return ;
        }
        
        [[QHttpMessageManager sharedHttpMessageManager] accessCategorySubList];
        [ASRequestHUD show];
        
    }
    else if (eventType == kPageEventWillShow)
    {
        [_mapView viewWillAppear];
        _mapView.delegate = self;
        _locService.delegate = self;
        
        [self onStartLocation:nil];
    }
    else if (eventType == kPageEventWillHide)
    {
        [_mapView viewWillDisappear];
        
        _mapView.delegate = nil;
        _locService.delegate = nil;
        
        [ASRequestHUD dismiss];
    }
    else if (eventType == kPageEventViewDispose)
    {
        [[NSNotificationCenter defaultCenter] removeObserver:self];
    }
}

- (UIView *)viewWithFrame:(CGRect)frame{
    if ([super viewWithFrame:frame]) {
        _mapView = [[BMKMapView alloc] initWithFrame:frame];
        
        [_mapView setMapType:BMKMapTypeStandard];
        [_view addSubview:_mapView];
        
        self.titleView.backgroundColor = [UIColor clearColor];
        [self.btnLocation setImage:[UIImage imageNamed:@"icon_map_dingwei"] forState:UIControlStateNormal];
        [self.btnList setImage:[UIImage imageNamed:@"icon_map_liebiao"] forState:UIControlStateNormal];
    }
    return _view;
}

- (UIView*)titleView
{
    if (!_titleView) {
        UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, _view.deFrameWidth, 45)];
        
        UIView *btnView = [[UIView alloc] initWithFrame:CGRectMake(10, 10, 160, 35)];
        btnView.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0.8f];
        btnView.layer.cornerRadius = 5;
        btnView.layer.masksToBounds = YES;
        [view addSubview:btnView];
        
        UIButton *button = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 60, 35)];
        button.titleLabel.font = [UIFont systemFontOfSize:14];
        [button setTitle:@"返回" forState:UIControlStateNormal];
        [button addTarget:self action:@selector(onBtnBack:) forControlEvents:UIControlEventTouchUpInside];
        [btnView addSubview:button];
        
        UIView *lineView = [[UIView alloc] initWithFrame:CGRectMake(60, 0, .5f, 35)];
        lineView.backgroundColor = [UIColor whiteColor];
        [btnView addSubview:lineView];
        
        button = [[UIButton alloc] initWithFrame:CGRectMake(60, 0, 100, 35)];
        [button setTitle:@"全部服务" forState:UIControlStateNormal];
        button.titleLabel.font = [UIFont systemFontOfSize:14];
        [button setImage:IMAGEOF(@"arrow") forState:UIControlStateNormal];
        CGSize textSize = [@"全部服务" sizeWithFont:[UIFont systemFontOfSize:12]];
        [button setImageEdgeInsets:UIEdgeInsetsMake(0, textSize.width + 15, 0, - (textSize.width + 15))];
        [button setTitleEdgeInsets:UIEdgeInsetsMake(0, 5, 0, 15)];
        [button addTarget:self action:@selector(onBtnCategory:) forControlEvents:UIControlEventTouchUpInside];
        [btnView addSubview:button];
        _btnCategory = button;
        
        button = [[UIButton alloc] initWithFrame:CGRectMake(_view.deFrameRight - 35 - 10, 10, 35, 35)];
        [button setImage:[UIImage imageNamed:@"icon_map_refresh"] forState:UIControlStateNormal];
        [button addTarget:self action:@selector(onBtnRefresh:) forControlEvents:UIControlEventTouchUpInside];
        [view addSubview:button];
        
        [_view addSubview:view];
        _titleView = view;
    }
    
    return _titleView;
}

- (UIButton*)btnLocation
{
    if (!_btnLocation) {
        _btnLocation = [[UIButton alloc] initWithFrame:CGRectMake(10, _view.deFrameBottom - 60 - 10, 35, 35)];
        [_btnLocation addTarget:self action:@selector(onStartLocation:) forControlEvents:UIControlEventTouchUpInside];
        [_view addSubview:_btnLocation];
    }
    return _btnLocation;
}

- (UIButton*)btnList
{
    if (!_btnList) {
        _btnList = [[UIButton alloc] initWithFrame:CGRectMake(_view.deFrameRight - 35 - 10, _view.deFrameBottom - 60 - 10, 35, 35)];
        [_btnList setImage:[UIImage imageNamed:@"icon_map_liebiao"] forState:UIControlStateNormal];
        [_btnList addTarget:self action:@selector(onList:) forControlEvents:UIControlEventTouchUpInside];
        [_view addSubview:_btnList];
    }
    return _btnList;
}

#pragma mark - Private

-(void)passLocationValue:(CLLocationCoordinate2D)centerCoordinate
{
    BMKCoordinateRegion viewRegion = BMKCoordinateRegionMake(centerCoordinate, BMKCoordinateSpanMake(0.02f,0.02f));
    BMKCoordinateRegion adjustedRegion = [_mapView regionThatFits:viewRegion];
    [_mapView setRegion:adjustedRegion animated:YES];
}

- (void)tryGetDatabyCategoryID:(NSString*)CategoryID
{
    CLLocationCoordinate2D point = [QLocationManager sharedInstance].geoPoint;
    //for test
    /*
    NSString *longitude = point.longitude ? [[NSNumber numberWithDouble:point.longitude] stringValue] : @"120.20000";
    NSString *latitude = point.latitude ? [[NSNumber numberWithDouble:point.latitude] stringValue] : @"30.26667";
    */
    NSString *longitude = point.longitude ? [[NSNumber numberWithDouble:point.longitude] stringValue] : @"";
    NSString *latitude = point.latitude ? [[NSNumber numberWithDouble:point.latitude] stringValue] : @"";
    
    NSNumber *regionId = [ASUserDefaults objectForKey:CurrentRegionID];
    
    if (_type == kMapTypeProduct)
    {
        [[QHttpMessageManager sharedHttpMessageManager] accessCarWashList:NSString_No_Nil([regionId stringValue])
                                                            andCategoryId:CategoryID
                                                             andLongitude:longitude
                                                              andLatitude:latitude
                                                                   andKey:@"2"  //离我最近
                                                           andCurrentPage:INTTOSTRING(_dataPage.nextPage)
                                                              andPageSize:INTTOSTRING(_dataPage.pageSize)];
    }
    else if (_type == kMapTypeBusiness)
    {
        [[QHttpMessageManager sharedHttpMessageManager] accessBusinessListThourghLocation:NSString_No_Nil([regionId stringValue])
                                                                              andCategory:NSString_No_Nil(CategoryID)
                                                                             andLongitude:[NSNumber numberWithDouble:point.longitude]
                                                                              andLatitude:[NSNumber numberWithDouble:point.latitude]
                                                                           andCurrentPage:INTTOSTRING(_dataPage.nextPage)
                                                                              andPageSize:INTTOSTRING(_dataPage.pageSize)];
    }
    
    [ASRequestHUD showWithMaskType:ASRequestHUDMaskTypeClear];
}

- (void)pointAnnotation:(NSArray*)array;
{
    [_mapView removeAnnotations:_annotations];
    
    NSMutableArray *mAnnotations  = [[NSMutableArray alloc] initWithCapacity:0];
    for (id object in array)
    {
        if ([object isKindOfClass:[QProductModel class]])
        {
            QProductModel *model = (QProductModel*)object;
            //PointAnnotation
            BMKPointAnnotation *annotation = [[BMKPointAnnotation alloc] init];
            CLLocationCoordinate2D coor;
            coor.latitude = [model.latitude doubleValue];
            coor.longitude = [model.longitude doubleValue];
            annotation.coordinate = coor;
            annotation.title = model.companyName;
            annotation.subtitle = model.subject;
            [mAnnotations addObject:annotation];
        }
    }
    
    _annotations = mAnnotations;
    [_mapView addAnnotations:mAnnotations];
}
#pragma mark - Action
- (void)onBtnBack:(id)sender
{
    [QViewController backPageWithParam:nil];
}

- (void)onBtnCategory:(id)sender
{
    if (!_cateFilterView) {
        _cateFilterView = [[QCategoryFilterView alloc] initWithFrame:CGRectMake(0, self.titleView.deFrameBottom, _view.deFrameWidth, _view.deFrameHeight)];
        _cateFilterView.delegate = self;
        [_view addSubview:_cateFilterView];
    }
    
    _btnCategory.imageView.transform = CGAffineTransformRotate(_btnCategory.imageView.transform, M_PI);
    [_cateFilterView toggleMenu];
}

- (void)onBtnRefresh:(id)sender
{
    NSString *ID = @"";
    if (_subCategory) {
        ID = [_subCategory.categoryId stringValue];
    }
    else if(_category) {
        ID = [_category.categoryId stringValue];
    }

    //数据
    [self tryGetDatabyCategoryID:ID];
}

- (void)onStartLocation:(id)sender
{
    [_locService startUserLocationService];
    _mapView.showsUserLocation = NO;//先关闭显示的定位图层
    _mapView.userTrackingMode = BMKUserTrackingModeNone;//设置定位的状态
    _mapView.showsUserLocation = YES;//显示定位图层
    _mapView.zoomEnabled = YES;
    _mapView.scrollEnabled = YES;
}

- (void)onList:(id)sender
{
    QMapListView *view = [[QMapListView alloc] initWithFrame:CGRectMake(10, 100, SCREEN_SIZE_WIDTH - 2*10, SCREEN_SIZE_HEIGHT - 2*100)];
    view.subCategoryID = _subCategoryID;
    view.products = _dataPage.mData;
    [view show];
}

#pragma mark - Notification
- (void)successGetProducts:(NSNotification*)noti
{
    [_dataPage setMData:noti.object];
    _dataPage.nextPage++;

    [self pointAnnotation:_dataPage.mData];
    [ASRequestHUD dismiss];
}

- (void)successGetBusiness:(NSNotification*)noti
{
    [_dataPage setMData:noti.object];
    _dataPage.nextPage++;
    
    [self pointAnnotation:_dataPage.mData];
    [ASRequestHUD dismiss];
}

- (void)successGetSubCategoryIDList:(NSNotification*)noti
{
    _subCategoryID = noti.object;
    [self tryGetDatabyCategoryID:@""];
}

#pragma mark - UIAlertViewDelegate
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
}

#pragma mark - QCategoryDelegaet
- (void)didChangeCategory:(QCategoryModel*)model sub:(QCategorySubModel*)subModel
{
    _category = model;
    _subCategory = subModel;
    
    _dataPage.nextPage = 1;
    
    NSString *ID = @"";
    NSString *title = @"";
    if (subModel) {
        ID = [subModel.categoryId stringValue];
        title = subModel.categoryName;
    }
    else if(model) {
        ID = [model.categoryId stringValue];
        title = model.categoryName;
    }
    //UI
    [_btnCategory setTitle:title forState:UIControlStateNormal];
    CGSize textSize = [title sizeWithFont:[UIFont systemFontOfSize:12]];
    [_btnCategory setImageEdgeInsets:UIEdgeInsetsMake(0, textSize.width + 15, 0, - (textSize.width + 15))];
    [_btnCategory setTitleEdgeInsets:UIEdgeInsetsMake(0, 5, 0, 15)];
    //数据
    [self tryGetDatabyCategoryID:ID];
}

- (void)didHideCategoryView
{
    _btnCategory.imageView.transform = CGAffineTransformRotate(_btnCategory.imageView.transform, M_PI);
    [self performSelector:@selector(removeCategoryView) withObject:nil afterDelay:0.02];

}

- (void)removeCategoryView
{
    [_cateFilterView removeFromSuperview];
    _cateFilterView = nil;
}

#pragma mark -
#pragma mark implement BMKMapViewDelegate

/**
 *根据anntation生成对应的View
 *@param mapView 地图View
 *@param annotation 指定的标注
 *@return 生成的标注View
 */
//加标注
- (BMKAnnotationView *)mapView:(BMKMapView *)mapView viewForAnnotation:(id<BMKAnnotation>)annotation
{
    // 生成重用标示identifier
    NSString *AnnotationViewID = @"xidanMark";
    
    // 检查是否有重用的缓存
    BMKAnnotationView* annotationView = [mapView dequeueReusableAnnotationViewWithIdentifier:AnnotationViewID];
    
    // 缓存没有命中，自己构造一个，一般首次添加annotation代码会运行到此处
    if (annotationView == nil) {
        annotationView = [[BMKPinAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:AnnotationViewID];
        ((BMKPinAnnotationView*)annotationView).pinColor = BMKPinAnnotationColorRed;
        // 设置重天上掉下的效果(annotation)
        ((BMKPinAnnotationView*)annotationView).animatesDrop = YES;
    }
    
    // 设置位置
    annotationView.centerOffset = CGPointMake(0, -(annotationView.frame.size.height * 0.5));
    annotationView.annotation = annotation;
    // 单击弹出泡泡，弹出泡泡前提annotation必须实现title属性
    annotationView.canShowCallout = YES;
    // 设置是否可以拖拽
    annotationView.draggable = NO;

    NSUInteger index = [_annotations indexOfObject:annotation];
    if (_dataPage.mData.count <= index)
        return nil;
    QProductModel *model = [_dataPage.mData objectAtIndex:index];
    annotationView.image = [QMapListView pointImage:model.categoryId andSubCategorys:_subCategoryID];
    UIImageView *leftView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"business_icon"]];
    annotationView.leftCalloutAccessoryView = leftView;
    /*
    UIView *view = [[UIView alloc] init];
    view.backgroundColor = [UIColor whiteColor];
    annotationView.paopaoView = [[BMKActionPaopaoView alloc] initWithCustomView:view];
    
    UIImageView *leftView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"business_icon"]];
    [view addSubview:leftView];
    
    UILabel *label = [[UILabel alloc] init];
    label.font = [UIFont systemFontOfSize:14];
    label.textColor = ColorDarkGray;
    label.text = model.subject;
    [view addSubview:label];
    
    [label sizeToFit];
    label.deFrameLeft = leftView.deFrameRight;
    label.deFrameHeight = leftView.deFrameHeight;
    view.deFrameWidth = label.deFrameRight;
    
    UIView *lineView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 0, 0.5f)];
    lineView.backgroundColor = ColorLine;
    lineView.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    [view addSubview:lineView];
    
    label = [[UILabel alloc] initWithFrame:CGRectMake(3, 0, view.deFrameWidth - 2*3, CGFLOAT_MAX)];
    label.numberOfLines = 0;
    label.font = [UIFont systemFontOfSize:12];
    label.textColor = [QTools colorWithRGB:221 :221 :221];
    label.text = @"123";
    [view addSubview:label];
    [label sizeToFit];
    
    label.deFrameTop = leftView.deFrameBottom;
    view.deFrameHeight = label.deFrameBottom;
    */
    return annotationView;
}


- (void)mapView:(BMKMapView *)mapView didSelectAnnotationView:(BMKAnnotationView *)view
{
    [mapView bringSubviewToFront:view];
    [mapView setNeedsDisplay];
}
- (void)mapView:(BMKMapView *)mapView didAddAnnotationViews:(NSArray *)views
{
}

- (void)mapView:(BMKMapView *)mapView annotationViewForBubble:(BMKAnnotationView *)view
{
    NSUInteger index = [_annotations indexOfObject:view.annotation];
    if (_dataPage.mData.count <= index)
        return ;
    QProductModel *model = [_dataPage.mData objectAtIndex:index];
    
    [QViewController gotoPage:@"QGroupBuyDetailPage" withParam:[NSDictionary dictionaryWithObjectsAndKeys:model.productId, @"ProductID", nil]];
}

#pragma mark -
#pragma mark implement BMKSearchDelegate
- (void)onGetPoiResult:(BMKPoiSearch *)searcher result:(BMKPoiResult*)result errorCode:(BMKSearchErrorCode)error
{
    // 清楚屏幕中所有的annotation
    NSArray* array = [NSArray arrayWithArray:_mapView.annotations];
    [_mapView removeAnnotations:array];
    
    if (error == BMK_SEARCH_NO_ERROR) {
        for (int i = 0; i < result.poiInfoList.count; i++) {
            BMKPoiInfo* poi = [result.poiInfoList objectAtIndex:i];
            BMKPointAnnotation* item = [[BMKPointAnnotation alloc]init];
            item.coordinate = poi.pt;
            item.title = poi.name;
            [_mapView addAnnotation:item];
            if(i == 0)
            {
                //将第一个点的坐标移到屏幕中央
                _mapView.centerCoordinate = poi.pt;
            }
        }
    }
    else if (error == BMK_SEARCH_AMBIGUOUS_ROURE_ADDR){
        //
    }
    else {
        // 各种情况的判断。。。
    }
}

#pragma mark - BMKLocationServiceDelegate
/**
 *在地图View将要启动定位时，会调用此函数
 *@param mapView 地图View
 */
- (void)willStartLocatingUser
{
}

/**
 *用户方向更新后，会调用此函数
 *@param userLocation 新的用户位置
 */
- (void)didUpdateUserHeading:(BMKUserLocation *)userLocation
{
    [_mapView updateLocationData:userLocation];
}

/**
 *用户位置更新后，会调用此函数
 *@param userLocation 新的用户位置
 */
- (void)didUpdateBMKUserLocation:(BMKUserLocation *)userLocation
{
    [_mapView updateLocationData:userLocation];
    [self passLocationValue:userLocation.location.coordinate];
    
    
    //初始定位
    if (!(([QLocationManager sharedInstance].geoPoint.latitude == 0) && ([QLocationManager sharedInstance].geoPoint.longitude == 0))) {
        if ((fabs(userLocation.location.coordinate.latitude - [QLocationManager sharedInstance].geoPoint.latitude) < 0.00001)
            && (fabs(userLocation.location.coordinate.longitude - [QLocationManager sharedInstance].geoPoint.longitude < 0.00001))) {
            
            [_locService stopUserLocationService];
        }
    }
    [QLocationManager sharedInstance].geoPoint = userLocation.location.coordinate;
}

/**
 *在地图View停止定位后，会调用此函数
 *@param mapView 地图View
 */
- (void)didStopLocatingUser
{
}

/**
 *定位失败后，会调用此函数
 *@param mapView 地图View
 *@param error 错误号，参考CLError.h中定义的错误号
 */
- (void)didFailToLocateUserWithError:(NSError *)error
{
}


@end
