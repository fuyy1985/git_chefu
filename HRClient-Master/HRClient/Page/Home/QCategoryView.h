//
//  QCategoryView.h
//  HRClient
//
//  Created by chenyf on 14/12/2.
//  Copyright (c) 2014年 panyj. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "QCarWashModel.h"

@class QCategoryView;

@protocol QCategoryDelegate <NSObject>
- (void)category:(QCategoryView *)categoryView selected:(QCategoryModel *)category;
@end

@interface QCategoryView : UIView<UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout>
@property (nonatomic,weak) id<QCategoryDelegate> delegate;
@end
