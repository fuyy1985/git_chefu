//
//  QProductDetail.h
//  HRClient
//
//  Created by ekoo on 15/1/17.
//  Copyright (c) 2015年 panyj. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "QProductDdtailComment.h"

@interface QProductDetail : NSObject

@property (nonatomic,strong)NSNumber *productId;
@property (nonatomic,strong)NSNumber *userId;
@property (nonatomic,strong)NSNumber *companyId;
@property (nonatomic,strong)NSNumber *categoryId;//类型
@property (nonatomic,assign)BOOL *isWash;//是不是洗车
@property (nonatomic,copy)NSString *subject;//商品名
@property (nonatomic,strong)NSNumber *price;//价格
@property (nonatomic,copy)NSString *purchaseNote;//购买须知
@property (nonatomic,copy)NSString *serviceDesc;//描述
@property (nonatomic,strong)NSNumber *guaranteePeriod;//质保期
//@property (nonatomic,strong)NSNumber *retureType;
@property (nonatomic,strong)NSNumber *startDate;
@property (nonatomic,strong)NSNumber *endDate;
@property (nonatomic,strong)NSArray *photoPaths;//图片
@property (nonatomic,strong)NSDictionary *company;//商家信息
@property (nonatomic,strong)NSDictionary *productBid;//key有bidType和bidPrice
@property (nonatomic,strong)NSDictionary *usrMbrPrice;//key有usrMbrPriceId和memberUnitPrice
@property (nonatomic,strong)NSNumber *sumPoints;//评分
@property (nonatomic,strong)QProductDdtailComment *commentResultList;//评论列表
//新添加的
@property (nonatomic,strong)NSNumber *salesVolume;
@property (nonatomic,strong)NSNumber *or_member;
@property (nonatomic,strong)NSNumber *returnNotSpending;
@property (nonatomic,strong)NSNumber *returnOverdue;
@property (nonatomic,strong)NSNumber *returnDissatisfied;
@property (nonatomic,copy)NSString *minMemberPrice;

+ (QProductDetail *)getModelFromProduct:(NSDictionary *)dic;

@end
