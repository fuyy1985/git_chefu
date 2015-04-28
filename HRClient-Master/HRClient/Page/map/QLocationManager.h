//
//  QLocationManager.h
//  HRClient
//
//  Created by amy.fu on 15/3/28.
//  Copyright (c) 2015年 panyj. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "BMapKit.h"

#define Noti_Location_Done  @"Location_Done"

@interface QLocationManager : NSObject<BMKLocationServiceDelegate,
                                        BMKGeoCodeSearchDelegate,
                                        CLLocationManagerDelegate>

@property (nonatomic, strong) BMKLocationService *localService;
@property (nonatomic, strong) BMKGeoCodeSearch *geoCoder;
@property (nonatomic, assign) CLLocationCoordinate2D geoPoint;
@property (nonatomic, strong) BMKReverseGeoCodeResult *geoResult;

+ (QLocationManager *)sharedInstance;
- (BOOL)canStartLocation;
- (void)startUserLocation;

@end
