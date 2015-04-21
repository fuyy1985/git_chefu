//
//  QBusinessDetailModel.h
//  HRClient
//
//  Created by ekoo on 15/1/17.
//  Copyright (c) 2015年 panyj. All rights reserved.
//

#import <Foundation/Foundation.h>
@interface QBusinessDetailModel : NSObject

@property (nonatomic,copy)NSString *photoPath;//图片
@property (nonatomic,copy)NSString *telphone;//商家电话
@property (nonatomic,copy)NSString *detailAddress;//商家地址
@property (nonatomic,strong)NSNumber *longitude;//经度
@property (nonatomic,strong)NSNumber *latitude;//纬度
@property (nonatomic,strong)NSNumber *grade;//商家评分
@property (nonatomic,strong)NSNumber *commentCount;//商家评论人数
@property (nonatomic,strong)NSArray *commentResult;//评论
@property (nonatomic,strong)NSArray *productListResult;//商品列表
@property (nonatomic,copy)NSString *companyName;

+ (QBusinessDetailModel *)getModelFromBusinessDetail:(NSDictionary *)dic;

@end
