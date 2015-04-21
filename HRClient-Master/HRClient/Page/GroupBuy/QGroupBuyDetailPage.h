//
//  QGroupBuyDetailPage.h
//  HRClient
//
//  Created by chenyf on 14/12/10.
//  Copyright (c) 2014年 panyj. All rights reserved.
//

#import "QPage.h"
#import "QProductDetail.h"
#import "QProductDdtailComment.h"
#import "QProductDetailCompany.h"

@interface QGroupBuyDetailPage : QPage<UITableViewDelegate, UITableViewDataSource, UIScrollViewDelegate, UIActionSheetDelegate>

@property(nonatomic,strong)QProductDetail *productDetail;
@property(nonatomic,strong)QProductDetailCompany *productCompany;
@property(nonatomic,strong)NSMutableArray *commentList;

@end
