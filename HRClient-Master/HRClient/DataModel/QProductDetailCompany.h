//
//  QProductDetailCompany.h
//  HRClient
//
//  Created by ekoo on 15/1/17.
//  Copyright (c) 2015年 panyj. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface QProductDetailCompany : NSObject

@property (nonatomic,copy)NSString *companyName;
@property (nonatomic,copy)NSString *companyTel;
@property (nonatomic,strong)NSNumber *regionId;
@property (nonatomic,copy)NSString *detailAddress;
@property (nonatomic,strong)NSNumber *distance;

+ (QProductDetailCompany *)getModelFromProductDetailCompany:(NSDictionary *)dic;

@end
