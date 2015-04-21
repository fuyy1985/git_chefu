//
//  QCardDetailModel.m
//  HRClient
//
//  Created by panyj on 15/3/23.
//  Copyright (c) 2015年 panyj. All rights reserved.
//

#import "QCardDetailModel.h"

@implementation QCardDetailModel

+ (QCardDetailModel *)getModelFromDic:(NSDictionary *)dic
{
    QCardDetailModel *model = [[QCardDetailModel alloc] init];
    [model setValuesForKeysWithDictionary:dic];
    return model;
}
- (void)setValue:(id)value forUndefinedKey:(NSString *)key{
    
}
- (id)valueForUndefinedKey:(NSString *)key{
    return nil;
}

+ (NSMutableArray*)defaultCardDetailsModel
{
    return [QConfigration readConfigForKey:@"CardDetailsModel"];
}

+ (void)setCardDetailsModel:(NSArray*)models
{
    [QConfigration writeFileConfig:models forKey:@"CardDetailsModel"];
}

@end
