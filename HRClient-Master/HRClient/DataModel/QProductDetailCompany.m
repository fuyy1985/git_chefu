//
//  QProductDetailCompany.m
//  HRClient
//
//  Created by ekoo on 15/1/17.
//  Copyright (c) 2015年 panyj. All rights reserved.
//

#import "QProductDetailCompany.h"

@implementation QProductDetailCompany

+ (QProductDetailCompany *)getModelFromProductDetailCompany:(NSDictionary *)dic{
    QProductDetailCompany *model = [[QProductDetailCompany alloc] init];
    [model setValuesForKeysWithDictionary:dic];
    return model;
}

- (void)setValue:(id)value forUndefinedKey:(NSString *)key{
    
}
- (id)valueForUndefinedKey:(NSString *)key{
    return nil;
}


@end
