//
//  QMyCouponDetailModel.m
//  HRClient
//
//  Created by ekoo on 15/1/31.
//  Copyright (c) 2015年 panyj. All rights reserved.
//

#import "QMyCouponDetailModel.h"

@implementation QMyCouponDetailModel

+ (QMyCouponDetailModel *)getModelFromMyCouponDetail:(NSDictionary *)dic{
    QMyCouponDetailModel *model = [[QMyCouponDetailModel alloc] init];
    [model setValuesForKeysWithDictionary:dic];
    return model;
}
- (void)setValue:(id)value forUndefinedKey:(NSString *)key{
    
}
- (id)valueForUndefinedKey:(NSString *)key{
    return nil;
}

@end
