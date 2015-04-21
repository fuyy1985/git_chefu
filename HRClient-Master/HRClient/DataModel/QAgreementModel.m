//
//  QAgreementModel.m
//  HRClient
//
//  Created by panyj on 15/3/23.
//  Copyright (c) 2015年 panyj. All rights reserved.
//

#import "QAgreementModel.h"

@implementation QAgreementModel

+ (QAgreementModel *)getModelFromDic:(NSDictionary *)dic{
    QAgreementModel *model = [[QAgreementModel alloc] init];
    [model setValuesForKeysWithDictionary:dic];
    return model;
}

-(void)setValue:(id)value forUndefinedKey:(NSString *)key
{
}

-(id)valueForUndefinedKey:(NSString *)key
{
    return nil;
}


@end
