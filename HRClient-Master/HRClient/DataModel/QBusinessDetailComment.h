//
//  QBusinessDetailComment.h
//  HRClient
//
//  Created by ekoo on 15/1/17.
//  Copyright (c) 2015年 panyj. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface QDetailComment : NSObject
@property (nonatomic,strong)NSNumber *commentType;
@property (nonatomic,copy)NSString *content;
@property (nonatomic,copy)NSString *createDate;
@property (nonatomic,strong)NSNumber *environment;
@property (nonatomic,copy)NSString *nick;
@property (nonatomic,strong)NSNumber *parentId;
@property (nonatomic,strong)NSNumber *quality;
@property (nonatomic,strong)NSNumber *reply;
@property (nonatomic,strong)NSNumber *serviceAttitude;
@property (nonatomic,strong)NSNumber *totalPoints;
@property (nonatomic,strong)NSNumber *des;

@end

@interface QBusinessDetailComment : QDetailComment

+ (QBusinessDetailComment *)getModelFromBusinessDetailComment:(NSDictionary *)dic;

@end
