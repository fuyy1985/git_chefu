//
//  AllenProvince.h
//  UITableView索引
//
//  Created by 黎跃春 on 14-9-16.
//  Copyright (c) 2014年 黎跃春. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface AllenProvince : NSObject
//省名字
@property (nonatomic,retain)NSString *provinceName;
//省下面的市
@property (nonatomic,retain)NSArray *cities;

//provinceName 第一个汉字的拼音
@property (nonatomic,assign)char pinYin;

//工厂方法
+ (AllenProvince*)provinceWithName:(NSString*)name;

@end









