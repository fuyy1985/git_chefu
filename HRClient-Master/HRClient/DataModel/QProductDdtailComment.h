//
//  QProductDdtailComment.h
//  HRClient
//
//  Created by ekoo on 15/1/17.
//  Copyright (c) 2015年 panyj. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "QBusinessDetailComment.h"

@interface QProductDdtailComment : QDetailComment

+ (QProductDdtailComment *)getModelFromProductDetailComment:(NSDictionary *)dic;

@end
