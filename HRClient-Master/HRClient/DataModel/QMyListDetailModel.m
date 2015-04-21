//
//  QMyListDetailModel.m
//  HRClient
//
//  Created by ekoo on 15/1/13.
//  Copyright (c) 2015年 panyj. All rights reserved.
//

#import "QMyListDetailModel.h"

@implementation QMyListDetailModel

+ (QMyListDetailModel *)getModelFromMyListDetail:(NSDictionary *)dic{
    QMyListDetailModel *model = [[QMyListDetailModel alloc] init];
    [model setValuesForKeysWithDictionary:dic];
    return model;
}

- (void)setValue:(id)value forUndefinedKey:(NSString *)key{

}

- (id)valueForUndefinedKey:(NSString *)key{
    return nil;
}

@end
