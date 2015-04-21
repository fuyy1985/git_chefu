//
//  QCarWashModel.m
//  HRClient
//
//  Created by ekoo on 15/1/25.
//  Copyright (c) 2015年 panyj. All rights reserved.
//

#import "QCarWashModel.h"

@implementation QCarWashModel

+ (QCarWashModel *)getModelFromCarWash:(NSDictionary *)dic{
    QCarWashModel *model = [[QCarWashModel alloc] init];
    [model setValuesForKeysWithDictionary:dic];
    return model;
}

- (void)setValue:(id)value forUndefinedKey:(NSString *)key{
    
}

- (id)valueForUndefinedKey:(NSString *)key{
    return nil;
}

@end


@implementation QCategoryModel

+ (QCategoryModel *)getModelFromCategory:(NSDictionary *)dic
{
    QCategoryModel *model = [[QCategoryModel alloc] init];
    [model setValuesForKeysWithDictionary:dic];
    return model;
}

- (void)setValue:(id)value forUndefinedKey:(NSString *)key{
    
}

- (id)valueForUndefinedKey:(NSString *)key{
    return nil;
}

+ (NSArray *)loadHomeCategory
{
    NSMutableArray * allCategorys = [[NSMutableArray alloc] initWithCapacity:8];
    
    NSArray *categorys = [QConfigration readConfigForKey:@"HomeCategory"];
    
    for (NSDictionary *item in categorys) {
 
        QCategoryModel *newCategory = [[QCategoryModel alloc] init];
        newCategory.categoryId = [NSNumber numberWithInt:[[item objectForKey:@"categoryOrder"] intValue]];
        newCategory.categoryName = [item objectForKey:@"categoryName"];
        newCategory.photoPath = [item objectForKey:@"categoryIcon"];
        [allCategorys addObject:newCategory];
    }
    return allCategorys;
}

+ (NSArray*)getCategory
{
    return [QConfigration readConfigForKey:CategoryService];
}

+ (void)setCategory:(NSArray*)categorys
{
    return [QConfigration writeRuntimeConfig:categorys forKey:CategoryService];
}

+ (QCategoryModel*)nullCategory
{
    QCategoryModel *model = [[QCategoryModel alloc] init];
    model.categoryId = nil;
    model.categoryName = @"全部服务";
    return model;
}

+ (NSArray*)defaultCategorys
{
    NSMutableArray *array = [[NSMutableArray alloc] initWithCapacity:0];
    
    QCategoryModel *model = [[QCategoryModel alloc] init];
    model.categoryId = [NSNumber numberWithInt:1];
    model.categoryName = @"洗车";
    [array addObject:model];
    
    model = [[QCategoryModel alloc] init];
    model.categoryId = [NSNumber numberWithInt:6];
    model.categoryName = @"保养";
    [array addObject:model];
    
    model = [[QCategoryModel alloc] init];
    model.categoryId = [NSNumber numberWithInt:10];
    model.categoryName = @"抛光美容";
    [array addObject:model];
    
    model = [[QCategoryModel alloc] init];
    model.categoryId = [NSNumber numberWithInt:18];
    model.categoryName = @"油漆";
    [array addObject:model];
    
    model = [[QCategoryModel alloc] init];
    model.categoryId = [NSNumber numberWithInt:45];
    model.categoryName = @"轮胎服务";
    [array addObject:model];
    
    model = [[QCategoryModel alloc] init];
    model.categoryId = [NSNumber numberWithInt:52];
    model.categoryName = @"新胎";
    [array addObject:model];
    
    model = [[QCategoryModel alloc] init];
    model.categoryId = [NSNumber numberWithInt:23];
    model.categoryName = @"装潢改装";
    [array addObject:model];
    
    model = [[QCategoryModel alloc] init];
    model.categoryId = [NSNumber numberWithInt:36];
    model.categoryName = @"维修服务";
    [array addObject:model];
    
    model = [[QCategoryModel alloc] init];
    model.categoryId = [NSNumber numberWithInt:74];
    model.categoryName = @"相关服务";
    [array addObject:model];
    
    return array;
}

@end

@implementation QCategorySubModel

+ (QCategorySubModel *)getModelFromCategorySub:(NSDictionary *)dic
{
    QCategorySubModel *model = [[QCategorySubModel alloc] init];
    [model setValuesForKeysWithDictionary:dic];
    return model;
}

- (void)setValue:(id)value forUndefinedKey:(NSString *)key{
    
}

- (id)valueForUndefinedKey:(NSString *)key{
    return nil;
}

@end
