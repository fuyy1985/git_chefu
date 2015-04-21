//
//  QThirdFilterView.h
//  HRClient
//
//  Created by chenyf on 14/12/29.
//  Copyright (c) 2014年 panyj. All rights reserved.
//

#import "QBaseFilterView.h"

typedef enum
{
    kIntelligenceKey = 1,   //智能排序
    kNearestKey,    //离我最近
    kCommentKey,    //好评优先
    kNewestKey,     //最新发布
    kSaleKey,       //销售量
    kPricedown,     //价格最高
    kPriceUp,       //价格最低
}FilterKeyType;

typedef enum
{
    kDataProductType,
    kDataBusinuessType,
}DataListType;

@interface QFilterKeyModel : NSObject
@property (nonatomic, assign) FilterKeyType keyType;
@property (nonatomic, strong) NSString *keyName;

+ (QFilterKeyModel*)filterModelbyKey:(FilterKeyType)keyType andListType:(DataListType)listType;
+ (NSArray*)defaultFilterKeyModels:(DataListType)listType;

@end

@class QThirdFilterView;

@protocol QThirdFilterViewDelegate <NSObject>
@optional
/* 切换 */
- (void)didChangeKey:(QFilterKeyModel*)model;
- (void)didHideThirdFilterView;

@end

@interface QThirdFilterView : QBaseFilterView<UITableViewDelegate, UITableViewDataSource>
@property (nonatomic, weak) id<QThirdFilterViewDelegate> delegate;

- (id)initWithFrame:(CGRect)frame andListType:(DataListType)listType;

@end
