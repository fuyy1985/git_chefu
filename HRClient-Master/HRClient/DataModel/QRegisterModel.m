//
//  QRegisterModel.m
//  HRClient
//
//  Created by ekoo on 15/1/9.
//  Copyright (c) 2015年 panyj. All rights reserved.
//

#import "QRegisterModel.h"

@implementation QRegisterModel

+ (QRegisterModel *)getModelFromRegister:(NSDictionary *)dic{
    QRegisterModel *model = [[QRegisterModel alloc] init];
    [model setValuesForKeysWithDictionary:dic];
    return model;
}

-(void)setValue:(id)value forUndefinedKey:(NSString *)key
{
    //    if ([key isEqualToString:@"id"]) {
    //        self.id000 = value;
    //    }
}
-(id)valueForUndefinedKey:(NSString *)key
{
    return nil;
}

@end
