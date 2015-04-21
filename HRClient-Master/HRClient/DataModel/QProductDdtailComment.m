//
//  QProductDdtailComment.m
//  HRClient
//
//  Created by ekoo on 15/1/17.
//  Copyright (c) 2015年 panyj. All rights reserved.
//

#import "QProductDdtailComment.h"

@implementation QProductDdtailComment

+ (QProductDdtailComment *)getModelFromProductDetailComment:(NSDictionary *)dic{
    QProductDdtailComment *model = [[QProductDdtailComment alloc] init];
    [model setValuesForKeysWithDictionary:dic];
    return model;
}

- (void)setValue:(id)value forUndefinedKey:(NSString *)key{
        if ([key isEqualToString:@"description"]) {
            self.des = value;
        }
}

- (id)valueForUndefinedKey:(NSString *)key{
    return nil;
}

@end
