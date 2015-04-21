//
//  QProductDetail.m
//  HRClient
//
//  Created by ekoo on 15/1/17.
//  Copyright (c) 2015年 panyj. All rights reserved.
//

#import "QProductDetail.h"

@implementation QProductDetail

+ (QProductDetail *)getModelFromProduct:(NSDictionary *)dic{
    QProductDetail *model = [[QProductDetail alloc] init];
    [model setValuesForKeysWithDictionary:dic];
    return model;
}

- (void)setValue:(id)value forUndefinedKey:(NSString *)key{

}

- (id)valueForUndefinedKey:(NSString *)key{
    return nil;
}

@end
