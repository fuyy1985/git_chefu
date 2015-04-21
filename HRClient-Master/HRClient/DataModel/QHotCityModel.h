//
//  QHotCityModel.h
//  HRClient
//
//  Created by ekoo on 15/1/4.
//  Copyright (c) 2015年 panyj. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface QHotCityModel : NSObject
@property (nonatomic,strong)NSNumber *regionId;
@property (nonatomic,copy)NSString *regionCode;
@property (nonatomic,copy)NSString *regionName;
@property (nonatomic,strong)NSNumber *indNo;
@property (nonatomic,strong)NSNumber *parentId;
@property (nonatomic,copy)NSString *gmtCreate;
@property (nonatomic,copy)NSString *gmtModified;
@property (nonatomic,copy)NSString *createUser;
@property (nonatomic,copy)NSString *modifiedUser;

+ (QHotCityModel *)getModelFromDic:(NSDictionary *)dic;


@end

@interface QRegionModel : NSObject

@property (nonatomic, strong) NSNumber *regionId;
@property (nonatomic, strong) NSNumber *parentId;
@property (nonatomic, copy) NSString *regionName;

+ (QRegionModel*)defaultRegionModel;
+ (QRegionModel*)getModelFromDic:(NSDictionary*)dic;
+ (QRegionModel*)nullRegion;
+ (NSArray*)getSecLevelRegion;
+ (void)setSecLevelRegion:(NSArray*)regions;
+ (NSMutableDictionary*)getThirdLevelRegion;
+ (void)setThirdLevelRegion:(NSMutableDictionary*)regionsDict;

@end
