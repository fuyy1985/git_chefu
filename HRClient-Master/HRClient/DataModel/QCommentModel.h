//
//  QCommentModel.h
//  HRClient
//
//  Created by ekoo on 15/1/6.
//  Copyright (c) 2015年 panyj. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface QCommentModel : NSObject
@property (nonatomic,strong)NSNumber *commentId;
@property (nonatomic,copy)NSString *content;
@property (nonatomic,copy)NSString *createUser;
@property (nonatomic,copy)NSString *gmtCreate;

+ (QCommentModel *)getModelFromCommentDic:(NSDictionary *)dic;

@end
