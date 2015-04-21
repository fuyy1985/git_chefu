//
//  QHotCityModel.m
//  HRClient
//
//  Created by ekoo on 15/1/4.
//  Copyright (c) 2015年 panyj. All rights reserved.
//

#import "QHotCityModel.h"

@implementation QHotCityModel


+ (QHotCityModel *)getModelFromDic:(NSDictionary *)dic{
    QHotCityModel *model = [[QHotCityModel alloc] init];
    [model setValuesForKeysWithDictionary:dic];
    return model;
}

-(void)setValue:(id)value forUndefinedKey:(NSString *)key
{
    //    if ([key isEqualToString:@"id"]) {
    //        self.id000 = value;
    //    }
}
-(id)valueForUndefinedKey:(NSString *)key
{
    return nil;
}


@end

@implementation QRegionModel

/* 默认城市*/
+ (QRegionModel*)defaultRegionModel
{
    NSNumber *regionID  = [ASUserDefaults objectForKey:CurrentRegionID];
    if (!regionID) {
        regionID = [NSNumber numberWithInt:1];
        [ASUserDefaults setObject:regionID forKey:CurrentRegionID];
    }
    NSString *regionName = [ASUserDefaults objectForKey:CurrentRegionName];
    if (!regionName) {
        regionName = [NSString stringWithFormat:@"杭州"];
        [ASUserDefaults setObject:@"杭州" forKey:CurrentRegionName];
    }
    
    QRegionModel *model = [[QRegionModel alloc] init];
    model.regionId = regionID;
    model.regionName = regionName;
    model.parentId = [NSNumber numberWithInt:0];
    
    return model;
}

+ (QRegionModel*)getModelFromDic:(NSDictionary*)dic
{
    QRegionModel *model = [[QRegionModel alloc] init];
    [model setValuesForKeysWithDictionary:dic];
    return model;
}

+ (QRegionModel*)nullRegion
{
    QRegionModel *model = [[QRegionModel alloc] init];
    model.regionName = @"全城";
    return model;
}

+ (NSArray*)getSecLevelRegion
{
    return [QConfigration readConfigForKey:@"secLevelRegion"];
}

+ (void)setSecLevelRegion:(NSArray*)regions
{
    return [QConfigration writeRuntimeConfig:regions forKey:@"secLevelRegion"];
}

+ (NSArray*)getThirdLevelRegion
{
    return [QConfigration readConfigForKey:@"ThirdLevelRegion"];
}

+ (void)setThirdLevelRegion:(NSDictionary*)regionsDict
{
    return [QConfigration writeRuntimeConfig:regionsDict forKey:@"ThirdLevelRegion"];
}

-(void)setValue:(id)value forUndefinedKey:(NSString *)key
{

}
-(id)valueForUndefinedKey:(NSString *)key
{
    return nil;
}

@end
