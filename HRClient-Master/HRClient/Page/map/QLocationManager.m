//
//  QLocationManager.m
//  HRClient
//
//  Created by amy.fu on 15/3/28.
//  Copyright (c) 2015年 panyj. All rights reserved.
//

#import "QLocationManager.h"


static QLocationManager *sharedInstance = nil;

@interface QLocationManager ()
{
    CLLocationManager *_locationManager;
}

@end

@implementation QLocationManager

+ (QLocationManager *)sharedInstance
{
    @synchronized(self) {
        if (sharedInstance == nil) {
            sharedInstance = [[QLocationManager alloc] init];
        }
    }
    return sharedInstance;
}

- (QLocationManager *)init
{
    self = [super init];
    if (self)
    {
        _geoCoder = [[BMKGeoCodeSearch alloc]init];
        _geoCoder.delegate = self;
        _localService = [[BMKLocationService alloc]init];
        _localService.delegate = self;
        
        NSDictionary *dict = [QConfigration readConfigForKey:LocationPoint];
        _geoPoint.longitude = [[dict objectForKey:@"longitude"] doubleValue];
        _geoPoint.latitude = [[dict objectForKey:@"latitude"] doubleValue];
        
        _locationManager = [[CLLocationManager alloc] init];
        _locationManager.delegate = self;
        _locationManager.desiredAccuracy = kCLLocationAccuracyBest;
        _locationManager.distanceFilter = 1000.0f;
    }
    return self;
}

- (void)dealloc
{
    _geoCoder.delegate = nil;
    _localService.delegate = nil;
}

- (void)startUserLocation
{
    if ([self canStartLocation])
    {
        [_localService startUserLocationService];
    }
}

- (BOOL)canStartLocation
{
    //定位服务是否可用
    BOOL enable = [CLLocationManager locationServicesEnabled];
    //是否具有定位权限
    int status = [CLLocationManager authorizationStatus];
    BOOL canStartLocation = !(!enable || status<3);
    if(!canStartLocation){
        //请求权限
        
        if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 8.0) {
        [_locationManager requestWhenInUseAuthorization];
        }
        
        [[NSNotificationCenter defaultCenter] postNotificationName:Noti_Location_Done object:[NSNumber numberWithBool:NO]];
        self.geoResult = nil;
    }
    return canStartLocation;
}

#pragma mark - BMKLocationServiceDelegate

- (void)willStartLocatingUser
{
}

- (void)didUpdateUserHeading:(BMKUserLocation *)userLocation
{
}

- (void)didUpdateBMKUserLocation:(BMKUserLocation *)userLocation
{
    debug_NSLog(@"latitude: %f, longitude: %f", userLocation.location.coordinate.latitude, userLocation.location.coordinate.longitude);
    
    //初始定位
    if (!((_geoPoint.latitude == 0) && (_geoPoint.longitude == 0))) {
        if ((fabs(userLocation.location.coordinate.latitude - _geoPoint.latitude) < 0.00001)
            && (fabs(userLocation.location.coordinate.longitude - _geoPoint.longitude < 0.00001))) {
            
            [_localService stopUserLocationService];
        }
    }
    
    _geoPoint = userLocation.location.coordinate;
    //保存经纬度
    [QConfigration writeFileConfig:[[NSDictionary alloc] initWithObjectsAndKeys:[NSNumber numberWithDouble:_geoPoint.longitude], @"longitude", [NSNumber numberWithDouble:_geoPoint.latitude], @"latitude", nil] forKey:LocationPoint];
    
    //定位
    BMKReverseGeoCodeOption *geoCode = [[BMKReverseGeoCodeOption alloc] init];
    geoCode.reverseGeoPoint = userLocation.location.coordinate;
    [_geoCoder reverseGeoCode:geoCode];
}

- (void)didStopLocatingUser
{
}

- (void)didFailToLocateUserWithError:(NSError *)error
{
    debug_NSLog(@"%s", __func__);
    [[NSNotificationCenter defaultCenter] postNotificationName:Noti_Location_Done object:[NSNumber numberWithBool:NO]];
}

#pragma mark - BMKGeoCodeSearchDelegate
- (void)onGetReverseGeoCodeResult:(BMKGeoCodeSearch *)searcher result:(BMKReverseGeoCodeResult *)result errorCode:(BMKSearchErrorCode)error
{
    if (BMK_SEARCH_NO_ERROR == error)
    {
        debug_NSLog(@"%@", result.address);
        _geoResult = result;
        
        [[NSNotificationCenter defaultCenter] postNotificationName:Noti_Location_Done object:[NSNumber numberWithBool:YES]];
    }
}

@end
