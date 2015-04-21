//
//  QCarWashModel.h
//  HRClient
//
//  Created by ekoo on 15/1/25.
//  Copyright (c) 2015年 panyj. All rights reserved.
//

#import <Foundation/Foundation.h>

/*
 洗车 1
 
 保养 6
 
 抛光美容 10
 
 油漆 18
 
 轮胎服务 45
 
 新胎 52
 
 装潢改装 23
 
 维修服务 36
 
 相关服务 74
 
 */
@interface QCarWashModel : NSObject

@property (nonatomic,strong)NSNumber *categoryId;
@property (nonatomic,copy)NSString *categoryName;
@property (nonatomic,strong)NSNumber *categoryType;
@property (nonatomic,strong)NSNumber *indNo;
@property (nonatomic,strong)NSNumber *parentId;
@property (nonatomic,strong)NSNumber *gmtCreate;
@property (nonatomic,strong)NSNumber *gmtModified;
@property (nonatomic,strong)NSNumber *createUser;
@property (nonatomic,strong)NSNumber *modifiedUser;
@property (nonatomic,strong)NSNumber *status;
@property (nonatomic,strong)NSNumber *children;

+ (QCarWashModel *)getModelFromCarWash:(NSDictionary *)dic;

@end

@interface QCategoryModel : NSObject

@property (nonatomic, strong) NSNumber *categoryId;
@property (nonatomic, copy) NSString *categoryName;
@property (nonatomic, copy) NSString *photoPath;
@property (nonatomic, strong) NSArray *subList;

/*首页本地分类配置*/
+ (NSArray *)loadHomeCategory;
/*服务器获取的全分类信息*/
+ (NSArray*)getCategory;
+ (void)setCategory:(NSArray*)categorys;
+ (QCategoryModel*)nullCategory;
+ (NSArray*)defaultCategorys;
+ (QCategoryModel *)getModelFromCategory:(NSDictionary *)dic;

@end

@interface QCategorySubModel : NSObject
@property (nonatomic, strong) NSNumber *categoryId;
@property (nonatomic, copy) NSString *categoryName;
@property (nonatomic, strong) NSNumber *categoryType;
@property (nonatomic, strong) NSNumber *parentId;

+ (QCategorySubModel *)getModelFromCategorySub:(NSDictionary *)dic;


@end
