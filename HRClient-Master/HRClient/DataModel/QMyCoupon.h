//
//  QMyCoupon.h
//  HRClient
//
//  Created by ekoo on 15/1/31.
//  Copyright (c) 2015年 panyj. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface QMyCoupon : NSObject
@property (nonatomic,copy)NSString *subject;
@property (nonatomic,copy)NSString *expireDate;
@property (nonatomic,strong)NSNumber *payId;
@property (nonatomic,strong)NSNumber *orderListId;

+ (QMyCoupon *)getModelFromMyCoupon:(NSDictionary *)dic;

@end
