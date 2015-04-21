//
//  QBusinessDetailModel.m
//  HRClient
//
//  Created by ekoo on 15/1/17.
//  Copyright (c) 2015年 panyj. All rights reserved.
//

#import "QBusinessDetailModel.h"

@implementation QBusinessDetailModel

+ (QBusinessDetailModel *)getModelFromBusinessDetail:(NSDictionary *)dic{
    QBusinessDetailModel *model = [[QBusinessDetailModel alloc] init];
    [model setValuesForKeysWithDictionary:dic];
    return model;
}

- (void)setValue:(id)value forUndefinedKey:(NSString *)key{

}

- (id)valueForUndefinedKey:(NSString *)key{
    return nil;
}

@end
