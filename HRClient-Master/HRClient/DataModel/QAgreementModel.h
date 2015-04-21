//
//  QAgreementModel.h
//  HRClient
//
//  Created by panyj on 15/3/23.
//  Copyright (c) 2015年 panyj. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface QAgreementModel : NSObject

@property (nonatomic, strong) NSNumber *agreementType;
@property (nonatomic, copy) NSString *content;

+ (QAgreementModel *)getModelFromDic:(NSDictionary *)dic;

@end
