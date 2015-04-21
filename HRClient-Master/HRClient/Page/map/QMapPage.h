//
//  QMapPage.h
//  HRClient
//
//  Created by ekoo on 14/12/30.
//  Copyright (c) 2014年 panyj. All rights reserved.
//

#import "QPage.h"
#import "BMapKit.h"


typedef NS_ENUM(NSInteger, QMapType)
{
    kMapTypeProduct,     //商品
    kMapTypeBusiness,    //商家
};


@interface QMapPage : QPage<BMKMapViewDelegate,BMKPoiSearchDelegate,BMKLocationServiceDelegate>
{
    BMKMapView *_mapView;
}

@end
