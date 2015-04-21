//
//  QAreaFilterView.h
//  HRClient
//
//  Created by chenyf on 14/12/29.
//  Copyright (c) 2014年 panyj. All rights reserved.
//

#import "QBaseFilterView.h"
#import "QHotCityModel.h"

@class QAreaFilterView;

@protocol QAreaFilterViewDelegate <NSObject>
@optional
/* 区域切换 */
- (void)didChangeArea:(QRegionModel*)model;
- (void)didHideAreaView;

@end

@interface QAreaFilterView : QBaseFilterView<UITableViewDelegate, UITableViewDataSource>
@property (nonatomic, weak) id<QAreaFilterViewDelegate> delegate;

@end
