//
//  QDifStatusListQtyModel.m
//  HRClient
//
//  Created by ekoo on 15/1/10.
//  Copyright (c) 2015年 panyj. All rights reserved.
//

#import "QDifStatusListQtyModel.h"

@implementation QDifStatusListQtyModel

+ (QDifStatusListQtyModel *)backToDifStatusListQty:(NSDictionary *)dic{
    QDifStatusListQtyModel *model = [[QDifStatusListQtyModel alloc] init];
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
