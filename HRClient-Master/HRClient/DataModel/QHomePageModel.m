//
//  QHomePageModel.m
//  HRClient
//
//  Created by ekoo on 15/1/18.
//  Copyright (c) 2015年 panyj. All rights reserved.
//

#import "QHomePageModel.h"

@implementation QHomePageModel

+ (QHomePageModel *)getModelFromHomePage:(NSDictionary *)dic{
    QHomePageModel *model = [[QHomePageModel alloc] init];
    [model setValuesForKeysWithDictionary:dic];
    return model;
}

- (void)setValue:(id)value forUndefinedKey:(NSString *)key{
}

- (id)valueForUndefinedKey:(NSString *)key{
    return nil;
}

// we are being created based on what was archived earlier
- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super init];
    if (self)
    {
        if ([aDecoder containsValueForKey:@"companyName"]) {
            self.companyName = [aDecoder decodeObjectForKey:@"companyName"];
        }
        if ([aDecoder containsValueForKey:@"distance"]) {
            self.distance = [aDecoder decodeObjectForKey:@"distance"];
        }
        if ([aDecoder containsValueForKey:@"evaluateAvgScore"]) {
            self.evaluateAvgScore = [aDecoder decodeObjectForKey:@"evaluateAvgScore"];
        }
        if ([aDecoder containsValueForKey:@"guaranteePeriod"]) {
            self.guaranteePeriod = [aDecoder decodeObjectForKey:@"guaranteePeriod"];
        }
        if ([aDecoder containsValueForKey:@"ismember"]) {
            self.ismember = [aDecoder decodeObjectForKey:@"ismember"];
        }
        if ([aDecoder containsValueForKey:@"member_bidPrice"]) {
            self.member_bidPrice = [aDecoder decodeObjectForKey:@"member_bidPrice"];
        }
        if ([aDecoder containsValueForKey:@"minMemberPrice"]) {
            self.minMemberPrice = [aDecoder decodeObjectForKey:@"minMemberPrice"];
        }
        if ([aDecoder containsValueForKey:@"photoPath"]) {
            self.photoPath = [aDecoder decodeObjectForKey:@"photoPath"];
        }
        if ([aDecoder containsValueForKey:@"price"]) {
            self.price = [aDecoder decodeObjectForKey:@"price"];
        }
        if ([aDecoder containsValueForKey:@"productId"]) {
            self.productId = [aDecoder decodeObjectForKey:@"productId"];
        }
        if ([aDecoder containsValueForKey:@"regionId"]) {
            self.regionId = [aDecoder decodeObjectForKey:@"regionId"];
        }
        if ([aDecoder containsValueForKey:@"regionName"]) {
            self.regionName = [aDecoder decodeObjectForKey:@"regionName"];
        }
        if ([aDecoder containsValueForKey:@"salesVolume"]) {
            self.salesVolume = [aDecoder decodeObjectForKey:@"salesVolume"];
        }
        if ([aDecoder containsValueForKey:@"subject"]) {
            self.subject = [aDecoder decodeObjectForKey:@"subject"];
        }
    }
    return self;
}

// we are asked to be archived, encode all our data
- (void)encodeWithCoder:(NSCoder *)aCoder
{
    [aCoder encodeObject:_companyName forKey:@"companyName"];
    [aCoder encodeObject:_distance forKey:@"distance"];
    [aCoder encodeObject:_evaluateAvgScore forKey:@"evaluateAvgScore"];
    [aCoder encodeObject:_guaranteePeriod forKey:@"guaranteePeriod"];
    [aCoder encodeObject:_ismember forKey:@"ismember"];
    [aCoder encodeObject:_member_bidPrice forKey:@"member_bidPrice"];
    [aCoder encodeObject:_minMemberPrice forKey:@"minMemberPrice"];
    [aCoder encodeObject:_photoPath forKey:@"photoPath"];
    [aCoder encodeObject:_price forKey:@"price"];
    [aCoder encodeObject:_productId forKey:@"productId"];
    [aCoder encodeObject:_regionId forKey:@"regionId"];
    [aCoder encodeObject:_regionName forKey:@"regionName"];
    [aCoder encodeObject:_salesVolume forKey:@"salesVolume"];
    [aCoder encodeObject:_subject forKey:@"subject"];
}

@end

@implementation QProductModel

+ (QProductModel*)getModelFromDict:(NSDictionary *)dic
{
    QProductModel *model = [[QProductModel alloc] init];
    [model setValuesForKeysWithDictionary:dic];
    return model;
}

- (void)setValue:(id)value forUndefinedKey:(NSString *)key{
}

- (id)valueForUndefinedKey:(NSString *)key{
    return nil;
}

@end

