//
//  QDifStatusListQtyModel.h
//  HRClient
//
//  Created by ekoo on 15/1/10.
//  Copyright (c) 2015年 panyj. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface QDifStatusListQtyModel : NSObject

@property (nonatomic,assign)int noPay;
@property (nonatomic,assign)int noConsumption;
@property (nonatomic,assign)int noEvaluate;
@property (nonatomic,assign)int backOrders;
@property (nonatomic,assign)int haveevaluate;

+ (QDifStatusListQtyModel *)backToDifStatusListQty:(NSDictionary*)dic;

@end
