//
//  QLoginModel.m
//  HRClient
//
//  Created by ekoo on 15/1/4.
//  Copyright (c) 2015年 panyj. All rights reserved.
//

#import "QLoginModel.h"

@implementation QLoginModel

+ (QLoginModel *)getModelFromDic:(NSDictionary *)dic{
    QLoginModel *model = [[QLoginModel alloc] init];
    
    model.userId = [dic objectForKey:@"userId"];
    model.realName = [dic objectForKey:@"realName"];
    model.nick = [dic objectForKey:@"nick"];
    model.mail = [dic objectForKey:@"mail"];
    model.phone = [dic objectForKey:@"phone"];
    model.password = [dic objectForKey:@"password"];
    model.payPasswd = [dic objectForKey:@"payPasswd"];
    model.gmtCreate = [dic objectForKey:@"gmtCreate"];
    model.gmtModified = [dic objectForKey:@"gmtModified"];
    model.createUser = [dic objectForKey:@"createUser"];
    model.modifiedUser = [dic objectForKey:@"modifiedUser"];
    model.status = [dic objectForKey:@"status"];
    model.balance = [dic objectForKey:@"balance"];
    model.ticket = [dic objectForKey:@"ticket"];
    model.member = [dic objectForKey:@"member"];
    model.photoPath = [dic objectForKey:@"photoPath"];
    
    return model;
}

/**
 password:
        nil, 退出登录,清除账号信息
        @“”, 无密码快速登录,一次有效
        @“XXXXXX”, 正常登录,下一次启动,自动验证登录
 */

- (void)savetoLocal:(NSString*)password
{
    NSUserDefaults *usrDefaults = [NSUserDefaults standardUserDefaults];
//  加密
//  NSString *password = [DES3Util encrypt:loginMoedel.password];
    [usrDefaults setObject:self.realName forKey:@"realName"];
    [usrDefaults setObject:self.mail forKey:@"mail"];
    [usrDefaults setObject:self.phone forKey:@"phone"];
//  [usrDefaults setObject:loginMoedel.password forKey:@"password"];
    [usrDefaults setObject:self.gmtCreate forKey:@"gmtCreate"];
    [usrDefaults setObject:self.gmtModified forKey:@"gmtModified"];
//  [usrDefaults setObject:loginMoedel.createUser forKey:@"createUser"];
    [usrDefaults setObject:self.modifiedUser forKey:@"modifiedUser"];
    [usrDefaults setObject:self.status forKey:@"status"];
//  [usrDefaults setObject:loginMoedel.photoPath forKey:@"photoPath"];
    [usrDefaults synchronize];
    
    if (password && ![password isEqualToString:@""]) {
        [ASUserDefaults setBool:YES forKey:LoginIsAutoLogin];
    }
    else {
        [ASUserDefaults setBool:NO forKey:LoginIsAutoLogin];
    }
    
    [ASUserDefaults setObject:self.phone forKey:LoginUserPhone];
    [ASUserDefaults setObject:self.payPasswd forKey:AccountPayPasswd];
    [ASUserDefaults setObject:self.userId forKey:AccountUserID];
    [ASUserDefaults setObject:self.nick forKey:AccountNick];
    [ASUserDefaults setObject:self.ticket forKey:AccountTicket];
    [ASUserDefaults setObject:password forKey:LoginUserPassCode];
    [ASUserDefaults setObject:self.member forKey:AccountIsMember];
    [ASUserDefaults setObject:self.balance forKey:AccountBalance];         //普通账户余额
    
    [ASUserDefaults synchronize];
}


@end
