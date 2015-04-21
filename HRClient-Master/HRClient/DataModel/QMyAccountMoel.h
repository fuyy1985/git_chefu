//
//  QMyAccountMoel.h
//  HRClient
//
//  Created by ekoo on 15/1/11.
//  Copyright (c) 2015年 panyj. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface QMyAccountMoel : NSObject

@property (nonatomic,strong)NSNumber *accountId;
@property (nonatomic,strong)NSNumber *userId;
@property (nonatomic,copy)NSString *accountName;
@property (nonatomic,strong)NSNumber *accountNo;
@property (nonatomic,strong)NSNumber *accountType;
@property (nonatomic,copy)NSString *password;
@property (nonatomic,strong)NSNumber *amount;
@property (nonatomic,strong)NSNumber *balance;
@property (nonatomic,strong)NSNumber *cost;
@property (nonatomic,strong)NSNumber *gmtCreate;
@property (nonatomic,strong)NSNumber *expireDate;
@property (nonatomic,strong)NSNumber *gmtModified;
@property (nonatomic,strong)NSNumber *createUser;
@property (nonatomic,strong)NSNumber *modifiedUser;
@property (nonatomic,strong)NSNumber *status;
+ (QMyAccountMoel *)getModelFromMyAccount:(NSDictionary *)dic;

@end

@interface QMemberCardDetail : NSObject
/*
:{"memberAccountId":11,"userId":113,"accountId":122,"vehicleTypeId":1,"vehicleTypeName":"汽车","memberTypeId":2,"memberTypeName":"经典卡","memberTypeStyle":2,"prepaidAble":"Y","regionId":1,"categoryId":1,"deadline":null,"memberUnitPrice":0.00,"expireDate":1460254647000,"gmtCreate":1428632247000,"gmtModified":1428632247000,"createUser":113,"modifiedUser":113,"status":1,"show":false,
    "account":{"accountId":122,"userId":113,"accountNo":1857666279,"accountName":"经典卡","accountType":3,"password":null,"amount":0.07,"balance":0.07,"cost":0.00,"gmtCreate":1427629794000,"gmtModified":1427718658000,"createUser":113,"modifiedUser":113,"status":1}
*/
@property (nonatomic, strong) NSString *memberTypeName;
@property (nonatomic, strong) NSNumber *expireDate;

@property (nonatomic, strong) NSNumber *show;
@property (nonatomic, strong) NSDictionary *account;

+ (QMemberCardDetail *)getModelFromDict:(NSDictionary *)dic;

@end
