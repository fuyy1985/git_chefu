//
//  QMyFavoritedModel.h
//  HRClient
//
//  Created by ekoo on 15/1/25.
//  Copyright (c) 2015年 panyj. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface QMyFavoritedModel : NSObject

@property (nonatomic,copy)NSString *companyName;
@property (nonatomic,strong)NSNumber *regionId;
@property (nonatomic,copy)NSString *regionName;
@property (nonatomic,strong)NSNumber *distance;
@property (nonatomic,strong)NSNumber *productId;
@property (nonatomic,copy)NSString *photoPath;
@property (nonatomic,copy)NSString *subject;
@property (nonatomic,strong)NSNumber *guaranteePeriod;
@property (nonatomic,copy)NSString *minMemberPrice;
@property (nonatomic,strong)NSNumber *member_bidPrice;
@property (nonatomic,strong)NSNumber *price;
@property (nonatomic,strong)NSNumber *salesVolume;
@property (nonatomic,strong)NSNumber *evaluateAvgScore;
@property (nonatomic,strong)NSNumber *ismember;

+ (QMyFavoritedModel *)getModelFromMyFavorited:(NSDictionary *)dic;

@end
