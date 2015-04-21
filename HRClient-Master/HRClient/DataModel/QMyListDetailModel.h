//
//  QMyListDetailModel.h
//  HRClient
//
//  Created by ekoo on 15/1/13.
//  Copyright (c) 2015年 panyj. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef enum{
    kOrderStatusUnPayed = 1,//1未付款
    kOrderStatusUnUsed,//2未消费
    kOrderStatusNeedRemark,//3待评价
    kOrderStatusRefund,//4退货单
    kOrderStatusRemarked,//5评级完
}OrderStatus;

@interface QMyListDetailModel : NSObject

@property (nonatomic,strong)NSNumber *orderListId;
@property (nonatomic,strong)NSNumber *productId;
@property (nonatomic,strong)NSNumber *companyId;
@property (nonatomic,strong)NSNumber *total;
@property (nonatomic,strong)NSNumber *quantity;
@property (nonatomic,copy)NSString *photo;
@property (nonatomic,copy)NSString *subject;
@property (nonatomic,strong)NSNumber *status;
@property (nonatomic,strong)NSNumber *gmtCreate;
@property (nonatomic,strong)NSNumber *phone;
@property (nonatomic,strong)NSString *orderListNo;
@property (nonatomic,strong)NSNumber *retureType;
@property (nonatomic,copy)NSString *payNo;
@property (nonatomic,strong)NSNumber *expireDate;
@property (nonatomic,copy)NSString *verificationCode;
@property (nonatomic,strong)NSNumber *returnNotSpending;
@property (nonatomic,strong)NSNumber *returnOverdue;
@property (nonatomic,strong)NSNumber *returnDissatisfied;
@property (nonatomic,strong)NSNumber *or_member;
@property (nonatomic,strong)NSNumber *payId;


+ (QMyListDetailModel *)getModelFromMyListDetail:(NSDictionary *)dic;

@end
