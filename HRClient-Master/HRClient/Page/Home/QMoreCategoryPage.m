//
//  QMoreCategoryPage.m
//  HRClient
//
//  Created by chenyf on 14/12/26.
//  Copyright (c) 2014年 panyj. All rights reserved.
//  更多分类

#import "QMoreCategoryPage.h"
#import "QViewController.h"
#import "QHttpMessageManager.h"
#import "QCarWashModel.h"
#import "UIImageView+WebCache.h"
#import "QThirdFilterView.h"
#import "QCarWashModel.h"

@interface QMoreCategoryPage ()
{
    NSString *kCellID;
    NSString *kHeaderID;
    NSString *kFooterID;
    NSMutableArray *dataArr;
}
@property (nonatomic) UICollectionView *contentCollection;
@property (nonatomic) NSArray *categorys;
@end

@implementation QMoreCategoryPage

- (NSString *)title
{
    return @"更多分类";
}

- (void)pageEvent:(QPageEventType)eventType
{
    if (eventType == kPageEventViewCreate)
    {
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(successGetCategorySublist:) name:kCategoryList object:nil];
        
        _categorys = [QCategoryModel getCategory];
        if (!_categorys) {
            [[QHttpMessageManager sharedHttpMessageManager] accessCategorySubList];
            [ASRequestHUD show];
        }
        else {
            [_contentCollection reloadData];
        }
    }
    else if (eventType == kPageEventViewDispose)
    {
        [[NSNotificationCenter defaultCenter] removeObserver:self name:kCategoryList object:nil];
    }
}

- (UIView *)viewWithFrame:(CGRect)frame
{
    if ([super viewWithFrame:frame]) {
        
        //
        kCellID = @"Collection_Cell_Identifier_Category";
        kHeaderID = @"HeaderView";
        kFooterID = @"FooterView";
        
        // headerview
        UIView *headerView = [[UIView alloc] initWithFrame:CGRectMake(0, -65, _view.deFrameWidth, 65)];
        UIButton *allCategoryButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
        allCategoryButton.frame = CGRectMake(11, 12, _view.deFrameWidth - 11 * 2, 36);
        allCategoryButton.layer.borderWidth = .5;
        allCategoryButton.layer.borderColor = [[QTools colorWithRGB:224 :224 :224] CGColor];
        allCategoryButton.titleLabel.font = [UIFont systemFontOfSize:15];
        [allCategoryButton setTitle:@"全部分类" forState:UIControlStateNormal];
        [allCategoryButton setTintColor:[QTools colorWithRGB:85 :85 :85]];
        [allCategoryButton addTarget:self action:@selector(allCategoryButtonTapped:) forControlEvents:UIControlEventTouchUpInside];
        [headerView addSubview:allCategoryButton];
        
        //
        UICollectionViewFlowLayout *flowLayout=[[UICollectionViewFlowLayout alloc] init];
        [flowLayout setScrollDirection:UICollectionViewScrollDirectionVertical];
        _contentCollection=[[UICollectionView alloc] initWithFrame:CGRectMake(0, 0, _view.deFrameWidth, _view.deFrameHeight) collectionViewLayout:flowLayout];
        _contentCollection.dataSource=self;
        _contentCollection.delegate=self;
        _contentCollection.contentInset = UIEdgeInsetsMake(65, 0, 0, 0);
        [_contentCollection addSubview:headerView];
        [_contentCollection setBackgroundColor:[UIColor whiteColor]];
        [_contentCollection registerClass:[UICollectionViewCell class] forCellWithReuseIdentifier:kCellID];
        [_contentCollection registerClass:[UICollectionReusableView class] forSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:kHeaderID];
        [_contentCollection registerClass:[UICollectionReusableView class] forSupplementaryViewOfKind:UICollectionElementKindSectionFooter withReuseIdentifier:kFooterID];
        [_view addSubview:_contentCollection];
    }
    
    return _view;
}


#pragma mark - Notification

- (void)successGetCategorySublist:(NSNotification*)noti
{
    [ASRequestHUD dismiss];
    
    _categorys = noti.object;
    [_contentCollection reloadData];
}

#pragma mark -- UICollectionViewDataSource

-(NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    if (_categorys.count <= section) {
        return 0;
    }
    QCategoryModel *model = [_categorys objectAtIndex:section];
    
    return model.subList.count;
}

-(NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView
{
    return self.categorys.count;
}

- (UICollectionReusableView *)collectionView:(UICollectionView *)collectionView viewForSupplementaryElementOfKind:(NSString *)kind atIndexPath:(NSIndexPath *)indexPath
{
    if (kind == UICollectionElementKindSectionHeader) {
        UICollectionReusableView *headerView = [collectionView dequeueReusableSupplementaryViewOfKind: UICollectionElementKindSectionHeader withReuseIdentifier:kHeaderID forIndexPath:indexPath];
        
        [headerView.subviews makeObjectsPerformSelector:@selector(removeFromSuperview)];
        //data
        if (_categorys.count <= indexPath.section) {
            return headerView;
        }
        QCategoryModel *model = [_categorys objectAtIndex:indexPath.section];
        
        // 图标
        UIImageView *img = [[UIImageView alloc] initWithFrame:CGRectMake(11, 0, 28, 28)];
        [img sd_setImageWithURL:[NSURL URLWithString:PICTUREHTTP(model.photoPath)]
                     placeholderImage:IMAGEOF(@"default_image")
                              options:SDWebImageRefreshCached];
        img.contentMode = UIViewContentModeScaleAspectFill;
        img.clipsToBounds = YES;
        img.layer.cornerRadius = 14;
        img.layer.masksToBounds = YES;
        [headerView addSubview:img];
        
        // 名称
        UILabel *lbText = [[UILabel alloc]initWithFrame:CGRectZero];
        lbText.backgroundColor = [UIColor clearColor];
        lbText.text = model.categoryName;
        lbText.textColor = ColorDarkGray;
        lbText.font = [UIFont boldSystemFontOfSize:15];
        lbText.textAlignment = NSTextAlignmentCenter;
        [lbText sizeToFit];
        lbText.center = img.center;
        lbText.deFrameLeft = img.deFrameRight + 6;
        [headerView addSubview:lbText];
        
        return headerView;
    }
    else {
        UICollectionReusableView *footerView = [collectionView dequeueReusableSupplementaryViewOfKind: UICollectionElementKindSectionFooter withReuseIdentifier:kFooterID forIndexPath:indexPath];
        return footerView;
    }
}

-(UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    UICollectionViewCell * cell = [collectionView dequeueReusableCellWithReuseIdentifier:kCellID forIndexPath:indexPath];
    
    [cell.contentView.subviews makeObjectsPerformSelector:@selector(removeFromSuperview)];
    
    QCategoryModel *model = [_categorys objectAtIndex:indexPath.section];
    QCategorySubModel *subModel = [model.subList objectAtIndex:indexPath.row];
    
    cell.layer.cornerRadius = 5;
    cell.layer.borderWidth = 0.5;
    cell.layer.borderColor = [ColorLine CGColor];

    UILabel *label = [[UILabel alloc] initWithFrame:CGRectZero];
    label.backgroundColor = [UIColor clearColor];
    label.textColor = [QTools colorWithRGB:85 :85 :85];
    label.font = [UIFont systemFontOfSize:12];
    label.text = subModel.categoryName;
    [label sizeToFit];
    label.center = cell.contentView.center;

    [cell.contentView addSubview:label];

    return cell;
}

#pragma mark UICollectionViewDelegateFlowLayout

//定义每个Item 的大小
- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath
{
    // 动态计算item size
    CGFloat padding = 11;
    CGFloat w = (collectionView.deFrameWidth - padding * 4) / 3;
    CGFloat h = 31;
    
    return CGSizeMake(w, h);
}

// header size
-(CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout referenceSizeForHeaderInSection:(NSInteger)section
{
    return CGSizeMake(collectionView.deFrameWidth, 28);
}

// footer size
-(CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout referenceSizeForFooterInSection:(NSInteger)section
{
    return CGSizeMake(collectionView.deFrameWidth, 28);
}

//定义每个UICollectionView 的 margin
-(UIEdgeInsets)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout insetForSectionAtIndex:(NSInteger)section
{
    return UIEdgeInsetsMake(8, 11, 0, 11);
}

#pragma mark UICollectionViewDelegate

- (BOOL)collectionView:(UICollectionView *)collectionView shouldHighlightItemAtIndexPath:(NSIndexPath *)indexPath
{
    return YES;
}
-(void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    QCategoryModel *model = [_categorys objectAtIndex:indexPath.section];
    QCategorySubModel *subModel = [model.subList objectAtIndex:indexPath.row];
    
    NSMutableDictionary *dic = [[NSMutableDictionary alloc] initWithCapacity:0];
    [dic setObject:[QFilterKeyModel filterModelbyKey:kIntelligenceKey andListType:kDataProductType] forKey:@"QFilterKeyModel"];
    [dic setObject:subModel forKey:@"QCategorySubModel"];
    [QViewController gotoPage:@"QGroupBuyWashingCarPage" withParam:dic];
}

-(BOOL)collectionView:(UICollectionView *)collectionView shouldSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    return YES;
}

#pragma mark - Private

- (void)allCategoryButtonTapped:(id)sender
{
    NSMutableDictionary *dic = [[NSMutableDictionary alloc] initWithCapacity:0];
    [dic setObject:[QFilterKeyModel filterModelbyKey:kIntelligenceKey andListType:kDataProductType] forKey:@"QFilterKeyModel"];
    [dic setObject:[QCategoryModel nullCategory] forKey:@"QCategoryModel"];
    [QViewController gotoPage:@"QGroupBuyWashingCarPage" withParam:dic];
}

@end
