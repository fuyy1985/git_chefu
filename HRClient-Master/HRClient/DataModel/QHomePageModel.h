//
//  QHomePageModel.h
//  HRClient
//
//  Created by ekoo on 15/1/18.
//  Copyright (c) 2015年 panyj. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface QHomePageModel : NSObject

@property (nonatomic,copy)NSString   *companyName;      //公司名
@property (nonatomic,strong)NSNumber *distance;         //距离
@property (nonatomic,strong)NSNumber *evaluateAvgScore; //平均分
@property (nonatomic,strong)NSNumber *guaranteePeriod;  //质保
@property (nonatomic,strong)NSNumber *ismember;         //是否是会员
@property (nonatomic,strong)NSNumber *member_bidPrice;  //会员价
@property (nonatomic,copy)NSString   *minMemberPrice;   //最低会员价
@property (nonatomic,copy)NSString   *photoPath;        //图片
@property (nonatomic,strong)NSNumber *price;            //原价
@property (nonatomic,strong)NSNumber *productId;        //产品ID
@property (nonatomic,strong)NSNumber *regionId;         //区域ID
@property (nonatomic,copy)NSString   *regionName;       //区域名
@property (nonatomic,strong)NSNumber *salesVolume;      //销量
@property (nonatomic,copy)NSString   *subject;          //标题


+ (QHomePageModel *)getModelFromHomePage:(NSDictionary *)dic;

@end

@interface QProductModel : NSObject

@property (nonatomic, strong) NSString *photoPath;
@property (nonatomic, strong) NSNumber *guaranteePeriod;   //int
@property (nonatomic, strong) NSNumber *member_bidPrice;  //double
@property (nonatomic, strong) NSNumber *longitude;   //double
@property (nonatomic, strong) NSNumber  *evaluateAvgScore;
@property (nonatomic, strong) NSNumber *regionId;    //int
@property (nonatomic, copy)NSString   *companyName;
@property (nonatomic, strong)NSString *detailAddress;
@property (nonatomic, strong) NSNumber *latitude;    //double
@property (nonatomic, strong) NSNumber *price;       //double
@property (nonatomic, strong) NSString *minMemberPrice;
@property (nonatomic, strong) NSNumber *distance;    //double
@property (nonatomic, strong) NSString *categoryPhotoPath;
@property (nonatomic, strong) NSNumber *ismember;    //bool
@property (nonatomic, strong) NSNumber *productId;   //long
@property (nonatomic, strong) NSString *subject;
@property (nonatomic, strong) NSString *regionName;
@property (nonatomic, strong) NSNumber *salesVolume; //int
@property (nonatomic, strong) NSNumber *categoryId;

+ (QProductModel*)getModelFromDict:(NSDictionary *)dic;

@end
