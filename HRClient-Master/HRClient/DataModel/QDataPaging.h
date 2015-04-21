//
//  QDataPaging.h
//  HRClient
//
//  Created by amy.fu on 15/3/28.
//  Copyright (c) 2015年 panyj. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface QDataPaging : NSObject
@property (nonatomic, assign) int nextPage;
@property (nonatomic, assign) int pageSize;
@property (nonatomic, strong) NSMutableArray *mData;


@end
