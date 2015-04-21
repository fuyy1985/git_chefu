//
//  QMyCouponDetailModel.h
//  HRClient
//
//  Created by ekoo on 15/1/31.
//  Copyright (c) 2015年 panyj. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface QMyCouponDetailModel : NSObject

@property (nonatomic,copy)NSString *subject;
@property (nonatomic,copy)NSString *verificationCode;
@property (nonatomic,copy)NSString *expireDate;

+ (QMyCouponDetailModel *)getModelFromMyCouponDetail:(NSDictionary *)dic;
@end
