//
//  QCardDetailModel.h
//  HRClient
//
//  Created by panyj on 15/3/23.
//  Copyright (c) 2015年 panyj. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface QCardDetailModel : NSObject
@property (nonatomic, strong) NSNumber *memberTypeId;
@property (nonatomic, copy) NSString *memberTypeName;
@property (nonatomic, strong) NSArray *memberPrices;
@property (nonatomic, strong) NSNumber *amount;

+ (QCardDetailModel *)getModelFromDic:(NSDictionary *)dic;
+ (NSMutableArray*)defaultCardDetailsModel;
+ (void)setCardDetailsModel:(NSArray*)models;

@end
