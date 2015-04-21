//
//  QBusinessDetailComment.m
//  HRClient
//
//  Created by ekoo on 15/1/17.
//  Copyright (c) 2015年 panyj. All rights reserved.
//

#import "QBusinessDetailComment.h"


@implementation QDetailComment
@end

@implementation QBusinessDetailComment

+ (QBusinessDetailComment *)getModelFromBusinessDetailComment:(NSDictionary *)dic{
    QBusinessDetailComment *model = [[QBusinessDetailComment alloc] init];
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
