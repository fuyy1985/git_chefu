//
//  QBusinessDetailResult.h
//  HRClient
//
//  Created by ekoo on 15/1/17.
//  Copyright (c) 2015年 panyj. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface QBusinessDetailResult : NSObject

@property (nonatomic,strong)NSNumber *productId;
@property (nonatomic,copy)NSString *subject;//名称
@property (nonatomic,copy)NSString *serviceDesc;//商品描述
@property (nonatomic,strong)NSNumber *price;//普通价格
@property (nonatomic,strong)NSNumber *bidPrice;//活动价格
@property (nonatomic,copy)NSString *photoPath;//商品图片
@property (nonatomic,strong)NSNumber *salesVolume;//已销售数量
@property (nonatomic,strong)NSNumber *guaranteePeriod;//质保,月份

+(QBusinessDetailResult *)getModelFromBusinessDetailResult:(NSDictionary *)dic;


@end
