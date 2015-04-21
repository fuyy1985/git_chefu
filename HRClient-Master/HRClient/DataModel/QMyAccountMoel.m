//
//  QMyAccountMoel.m
//  HRClient
//
//  Created by ekoo on 15/1/11.
//  Copyright (c) 2015年 panyj. All rights reserved.
//

#import "QMyAccountMoel.h"

@implementation QMyAccountMoel
+ (QMyAccountMoel *)getModelFromMyAccount:(NSDictionary *)dic{
    QMyAccountMoel *model = [[QMyAccountMoel alloc] init];
    [model setValuesForKeysWithDictionary:dic];
    return model;
}

- (void)setValue:(id)value forUndefinedKey:(NSString *)key{
    
}
- (id)valueForUndefinedKey:(NSString *)key{
    return nil;
}

@end

@implementation QMemberCardDetail

+ (QMemberCardDetail *)getModelFromDict:(NSDictionary *)dic
{
    QMemberCardDetail *model = [[QMemberCardDetail alloc] init];
    [model setValuesForKeysWithDictionary:dic];
    return model;
}

- (void)setValue:(id)value forUndefinedKey:(NSString *)key{
    
}
- (id)valueForUndefinedKey:(NSString *)key{
    return nil;
}

@end
