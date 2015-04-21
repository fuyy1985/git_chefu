//
//  QMyListModel.h
//  HRClient
//
//  Created by ekoo on 15/1/7.
//  Copyright (c) 2015年 panyj. All rights reserved.
//

#import <Foundation/Foundation.h>

//订单模型

@interface QMyListModel : NSObject

@property (nonatomic,strong)NSNumber *categoryId;
@property (nonatomic,strong)NSNumber *companyId;
@property (nonatomic,strong)NSNumber *createUser;
@property (nonatomic,strong)NSNumber *customerId;
@property (nonatomic,strong)NSNumber *gmtCreate;
@property (nonatomic,strong)NSNumber *gmtModified;
@property (nonatomic,strong)NSNumber *orderListId;
@property (nonatomic,strong)NSString *orderListNo;
@property (nonatomic,strong)NSNumber *orderType;
@property (nonatomic,strong)NSNumber *payType;
@property (nonatomic,strong)NSNumber *productBidId;
@property (nonatomic,strong)NSNumber *productId;
@property (nonatomic,strong)NSNumber *quantity;
@property (nonatomic,strong)NSNumber *status;
@property (nonatomic,strong)NSNumber *total; //double
@property (nonatomic,strong)NSNumber *userId;
@property (nonatomic,strong)NSNumber *wishListId;


+ (QMyListModel *)getModelFromMyList:(NSDictionary *)dic;

@end
