//
//  QCategoryView.m
//  HRClient
//
//  Created by chenyf on 14/12/2.
//  Copyright (c) 2014年 panyj. All rights reserved.
//

#import "QCategoryView.h"

@interface QCategoryView ()
{
    NSString *kCellID;
}
@property (nonatomic) UICollectionView *contentCollection;
@property (nonatomic) NSArray *categorys;
@end

@implementation QCategoryView

- (id)initWithFrame:(CGRect)frame
{
    if (self = [super initWithFrame:frame])
    {
        kCellID = @"Collection_Cell_Identifier_Category";
        self.categorys = [QCategoryModel loadHomeCategory];
        self.backgroundColor = [UIColor whiteColor];
        
        CGRect contentFrame = CGRectMake(0, 0, frame.size.width, frame.size.height);
        UICollectionViewFlowLayout *flowLayout = [[UICollectionViewFlowLayout alloc] init];
        [flowLayout setItemSize:CGSizeMake(frame.size.width/4, 80)];
        [flowLayout setScrollDirection:UICollectionViewScrollDirectionHorizontal];
        [flowLayout setMinimumInteritemSpacing:0];
        [flowLayout setMinimumLineSpacing:0];
        _contentCollection = [[UICollectionView alloc] initWithFrame:contentFrame collectionViewLayout:flowLayout];
        _contentCollection.dataSource = self;
        _contentCollection.delegate = self;
        _contentCollection.backgroundColor = [UIColor clearColor];
        [_contentCollection registerClass:[UICollectionViewCell class] forCellWithReuseIdentifier:kCellID];
        [self addSubview:_contentCollection];
        
    }
    return self;
}

#pragma mark - UICollectionView

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView
{
    return 1;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return self.categorys.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    UICollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:kCellID forIndexPath:indexPath];
    
    cell.tag = indexPath.row;
    
    // custom the cell.
    QCategoryModel *curCategory = self.categorys[indexPath.row];
    
    UIImageView *img = [[UIImageView alloc] initWithFrame:CGRectMake((self.frame.size.width/4 - 40) / 2, 10, 40, 40)];
    img.image = IMAGEOF(curCategory.photoPath);
    [cell.contentView addSubview:img];
    
    UILabel *lbText = [[UILabel alloc]initWithFrame:CGRectMake(0, 52, self.frame.size.width/4, 21)];
    lbText.backgroundColor = [UIColor clearColor];
    lbText.text = _T(curCategory.categoryName);
    lbText.textColor = ColorDarkGray;
    lbText.font = [UIFont systemFontOfSize:12];
    lbText.textAlignment = NSTextAlignmentCenter;
    [cell.contentView addSubview:lbText];
    
    cell.contentView.backgroundColor = [UIColor whiteColor];
    
    return cell;
}

- (void)collectionView:(UICollectionView *)collectionView didHighlightItemAtIndexPath:(NSIndexPath *)indexPath
{
    UICollectionViewCell *cell = [collectionView cellForItemAtIndexPath:indexPath];
    cell.contentView.backgroundColor = [QTools colorWithRGB:238 :238 :238];
}

- (void)collectionView:(UICollectionView *)collectionView didUnhighlightItemAtIndexPath:(NSIndexPath *)indexPath
{
    UICollectionViewCell *cell = [collectionView cellForItemAtIndexPath:indexPath];
    cell.contentView.backgroundColor = [UIColor whiteColor];
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    QCategoryModel *curCategory = self.categorys[indexPath.row];
    
    if (_delegate) {
        [_delegate category:self selected:curCategory];
    }
}

@end
