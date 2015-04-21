//
//  QDataPaging.m
//  HRClient
//
//  Created by amy.fu on 15/3/28.
//  Copyright (c) 2015年 panyj. All rights reserved.
//

#import "QDataPaging.h"

@implementation QDataPaging

- (id)init
{
    self = [super init];
    if (self) {
        _nextPage = 1;
        _pageSize = 10;
        _mData = [[NSMutableArray alloc] initWithCapacity:0];
    }
    return self;
}

- (void)setMData:(NSMutableArray *)mData
{
    if (1 == _nextPage) {
        [_mData removeAllObjects];
    }
    [_mData addObjectsFromArray:mData];
}

@end
