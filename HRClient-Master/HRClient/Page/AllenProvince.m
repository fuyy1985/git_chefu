//
//  AllenProvince.m
//  UITableView索引
//
//  Created by 黎跃春 on 14-9-16.
//  Copyright (c) 2014年 黎跃春. All rights reserved.
//

#import "AllenProvince.h"
#import "pinyin.h"

@implementation AllenProvince
@synthesize provinceName = _provinceName;
@synthesize cities = _cities;
@synthesize pinYin = _pinYin;


//工厂方法
+ (AllenProvince*)provinceWithName:(NSString*)name{
    
    AllenProvince *province = [[AllenProvince alloc] init];
    province.provinceName = name;
//    将汉字的第一个字符的拼音取出来，并且转换成大写，直接减32即可
//    多音字处理
    if ([province.provinceName isEqualToString:@"重庆"]) {
        province.pinYin = 'C';
    }else{
        province.pinYin = pinyinFirstLetter([province.provinceName characterAtIndex:0]) - 32;
    }
    
    return province;
}

@end








