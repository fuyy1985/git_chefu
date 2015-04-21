//
//  QBusinessListModel.h
//  HRClient
//
//  Created by ekoo on 15/1/17.
//  Copyright (c) 2015年 panyj. All rights reserved.
//

#import <Foundation/Foundation.h>

//按照经纬度
@interface QBusinessListModel : NSObject
@property (nonatomic,strong)NSNumber *companyId;
@property (nonatomic,copy)NSString *companyName;
@property (nonatomic,copy)NSString *photoPath;
@property (nonatomic,copy)NSString *detailAddress;
@property (nonatomic,strong)NSNumber *distance;
@property (nonatomic,strong)NSNumber *grade;
@property (nonatomic,strong)NSNumber *commentCount;

+ (QBusinessListModel *)getModelFromBusinessList:(NSDictionary*)dic;

@end
