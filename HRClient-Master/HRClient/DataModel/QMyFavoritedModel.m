//
//  QMyFavoritedModel.m
//  HRClient
//
//  Created by ekoo on 15/1/25.
//  Copyright (c) 2015年 panyj. All rights reserved.
//

#import "QMyFavoritedModel.h"

@implementation QMyFavoritedModel

+ (QMyFavoritedModel *)getModelFromMyFavorited:(NSDictionary *)dic{
    
    if (!dic)
        return nil;
    
    QMyFavoritedModel *model = [[QMyFavoritedModel alloc] init];
    [model setValuesForKeysWithDictionary:dic];
    return model;
}

- (void)setValue:(id)value forUndefinedKey:(NSString *)key{

}
- (id)valueForUndefinedKey:(NSString *)key{
    return nil;
}

@end
