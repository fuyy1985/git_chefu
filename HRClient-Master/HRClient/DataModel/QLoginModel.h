//
//  QLoginModel.h
//  HRClient
//
//  Created by ekoo on 15/1/4.
//  Copyright (c) 2015年 panyj. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface QLoginModel : NSObject

@property (nonatomic,strong)NSNumber *userId;
@property (nonatomic,copy)NSString *realName;
@property (nonatomic,copy)NSString *nick;
@property (nonatomic,copy)NSString *mail;
@property (nonatomic,copy)NSString *phone;
@property (nonatomic,copy)NSString *password;
@property (nonatomic,copy)NSString *payPasswd;
@property (nonatomic,strong)NSNumber *gmtCreate;
@property (nonatomic,strong)NSNumber *gmtModified;
@property (nonatomic,strong)NSNumber *createUser;
@property (nonatomic,strong)NSNumber *modifiedUser;
@property (nonatomic,strong)NSNumber *status;
@property (nonatomic,strong)NSNumber *ticket;
@property (nonatomic,strong)NSNumber *member;
@property (nonatomic,copy)NSString *photoPath;
@property (nonatomic,strong)NSNumber *balance;   //普通账户余额

+ (QLoginModel *)getModelFromDic:(NSDictionary *)dic;

- (void)savetoLocal:(NSString*)password;

@end
