//
//  QCategoryFilterView.h
//  HRClient
//
//  Created by chenyf on 14/12/27.
//  Copyright (c) 2014年 panyj. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "QBaseFilterView.h"
#import "QCarWashModel.h"

@class QCategoryFilterView;

@protocol QCategoryFilterViewDelegate <NSObject>
@optional
/* 分类切换 */
- (void)didChangeCategory:(QCategoryModel*)model sub:(QCategorySubModel*)subModel;
- (void)didHideCategoryView;

@end

@interface QCategoryFilterView : QBaseFilterView<UITableViewDelegate, UITableViewDataSource>
@property (nonatomic, weak) id<QCategoryFilterViewDelegate> delegate;

@end
