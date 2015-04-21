//
//  QMyListModel.m
//  HRClient
//
//  Created by ekoo on 15/1/7.
//  Copyright (c) 2015年 panyj. All rights reserved.
//

#import "QMyListModel.h"

@implementation QMyListModel

+ (QMyListModel *)getModelFromMyList:(NSDictionary *)dic{
    QMyListModel *model = [[QMyListModel alloc] init];
    [model setValuesForKeysWithDictionary:dic];
    return model;
}

- (void)setValue:(id)value forUndefinedKey:(NSString *)key{
    
}

- (id)valueForUndefinedKey:(NSString *)key{
    return nil;
}

@end
