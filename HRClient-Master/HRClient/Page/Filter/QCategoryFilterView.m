//
//  QCategoryFilterView.m
//  HRClient
//
//  Created by chenyf on 14/12/27.
//  Copyright (c) 2014年 panyj. All rights reserved.
//  分类 下拉选择

#import "QCategoryFilterView.h"
#import "QViewController.h"
#import "QPersistentBackgroundLabel.h"
#import "QHttpMessageManager.h"
#import "QCarWashModel.h"

@interface QCategoryFilterView ()
@property (nonatomic) UITableView *parentCategoryTableView;
@property (nonatomic) UITableView *subCategoryTableView;
@property (nonatomic) NSInteger parentIndex;
@property (nonatomic) NSMutableArray *dataArr;
@property (nonatomic) NSMutableArray *infroArr;
@end

@implementation QCategoryFilterView

- (void)dealloc
{
    [ASRequestHUD dismiss];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:kCategoryList object:nil];
}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self)
    {
        _parentIndex = 0;
        
        CGFloat menuHeight = 285;
        CGFloat parentW = 160;
        CGFloat subW = 160;
        parentW = frame.size.width * parentW / (parentW + subW);
        subW = frame.size.width - parentW;
        
        self.menuView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, frame.size.width, menuHeight)];
        [self addSubview:self.menuView];
        
        // parent category
        _parentCategoryTableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, parentW , menuHeight) style:UITableViewStylePlain];
        _parentCategoryTableView.separatorStyle = UITableViewCellSeparatorStyleNone;
        _parentCategoryTableView.delegate = self;
        _parentCategoryTableView.dataSource = self;
        _parentCategoryTableView.backgroundColor = [QTools colorWithRGB:238 :238 :238];
        [self.menuView addSubview:_parentCategoryTableView];
        
        // sub category
        _subCategoryTableView = [[UITableView alloc] initWithFrame:CGRectMake(_parentCategoryTableView.deFrameRight, 0, subW, menuHeight) style:UITableViewStylePlain];
        _subCategoryTableView.separatorStyle = UITableViewCellSeparatorStyleNone;
        _subCategoryTableView.delegate = self;
        _subCategoryTableView.dataSource = self;
        _subCategoryTableView.backgroundColor = [QTools colorWithRGB:0xf0 :0xef :0xed];
        [self.menuView addSubview:_subCategoryTableView];
        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(acquireCategorySubList:) name:kCategoryList object:nil];
        
        //先从本地获取,若没有则从服务器取
        QCategoryModel *categoryAllModel = [QCategoryModel nullCategory];
        categoryAllModel.photoPath = @"icon_list_all";
        
        _dataArr = [[NSMutableArray alloc] initWithCapacity:0];
        [_dataArr addObject:categoryAllModel];
        [_dataArr addObjectsFromArray:[QCategoryModel getCategory]];
        if (_dataArr.count < 2) {
            [[QHttpMessageManager sharedHttpMessageManager] accessCategorySubList];
            [ASRequestHUD show];
        }
        else {
            //直接刷新UI
            [self reloadTableView];
        }
    }
    return self;
}

/*
 洗车 1
 
 保养 6
 
 抛光美容 10
 
 油漆 18
 
 轮胎服务 45
 
 新胎 52
 
 装潢改装 23
 
 维修服务 36
 
 相关服务 74
 
 */

- (NSString*)iconbyCategoryID:(NSNumber*)categoryID
{
    NSString *icon = @"";
    switch ([categoryID intValue]) {
        case 1:
            icon = @"icon_list_xiche";
            break;
        case 6:
            icon = @"icon_list_baoyang";
            break;
        case 10:
            icon = @"icon_list_paoguang";
            break;
        case 18:
            icon = @"icon_list_youqi";
            break;
        case 45:
            icon = @"icon_list_luntai";
            break;
        case 52:
            icon = @"icon_list_xintai";
            break;
        case 23:
            icon = @"icon_list_zhuanghuang";
            break;
        case 36:
            icon = @"icon_list_weixiu";
            break;
        case 74:
            icon = @"icon_list_xiangguang";
            break;
        default:
            break;
    }
    return icon;
}

- (void)acquireCategorySubList:(NSNotification *)noti{
    
    [ASRequestHUD dismiss];
    
    [_dataArr removeAllObjects];
    
    for (QCategoryModel *model in noti.object)
    {
        model.photoPath = [self iconbyCategoryID:model.categoryId];
    }
    QCategoryModel *categoryAllModel = [QCategoryModel nullCategory];
    categoryAllModel.photoPath = @"icon_list_all";
    
    [_dataArr addObject:categoryAllModel];
    [_dataArr addObjectsFromArray:noti.object];

    [self reloadTableView];
}

#pragma mark - Super

- (void)showMenu
{
    [super showMenu];
}

- (void)hideMenu
{
    [super hideMenu];
    
    if (self.delegate && [self.delegate respondsToSelector:@selector(didHideCategoryView)]) {
        [self.delegate didHideCategoryView];
    }
}

#pragma mark - Private
- (void)reloadTableView
{
    //刷新UI
    [_parentCategoryTableView reloadData];
    [_subCategoryTableView reloadData];
}

- (void)didSelectNewCategory:(QCategoryModel*)model sub:(QCategorySubModel*)subModel
{
    if (self.delegate && [self.delegate respondsToSelector:@selector(didChangeCategory:sub:)]) {
        [self.delegate didChangeCategory:model sub:subModel];
    }
    [self reloadTableView];
}

#pragma mark - UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (tableView == _parentCategoryTableView) {
        return _dataArr.count;
    }
    else {
        QCategoryModel *parentModel = [_dataArr objectAtIndex:_parentIndex];
        NSInteger subCount = parentModel.subList.count;
        if (subCount) {
            subCount++;
        }
        return subCount;
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 30;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (tableView == _parentCategoryTableView)
    {
        static NSString *CellIdentifier = @"Cell_Identifier_filter_parent";
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
        if (nil == cell) {
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault
                                          reuseIdentifier:CellIdentifier];
            
            UIView *selectedBackgroundView = [[UIView alloc] initWithFrame:cell.frame];
            selectedBackgroundView.backgroundColor = [QTools colorWithRGB:0xf0 :0xef :0xed];
            cell.selectedBackgroundView = selectedBackgroundView;
        }
        
        [cell.contentView.subviews makeObjectsPerformSelector:@selector(removeFromSuperview)];
        
        QCategoryModel *parentModel = [_dataArr objectAtIndex:indexPath.row];
        
        if (parentModel.subList && parentModel.subList.count) {
            cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        }
        else {
            cell.accessoryType = UITableViewCellAccessoryNone;
        }
        
        UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake(5, 5, 20, 20)];
        imageView.image = IMAGEOF(parentModel.photoPath);
        [cell.contentView addSubview:imageView];
        
        UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(imageView.deFrameRight + 5, 0, tableView.deFrameWidth - imageView.deFrameRight - 15, 30)];
        label.text = parentModel.categoryName;
        label.font = [UIFont systemFontOfSize:13];
        label.textColor = [QTools colorWithRGB:107 :107 :107];
        [cell.contentView addSubview:label];
        
        UIView *separatorLineView = [[UIView alloc] initWithFrame:CGRectMake(0, [self tableView:tableView heightForRowAtIndexPath:indexPath] - 0.5, tableView.deFrameWidth, 0.5)];
        separatorLineView.backgroundColor = [QTools colorWithRGB:229 :229 :229];
        [cell.contentView addSubview:separatorLineView];
        
        if (indexPath.row == _parentIndex) {
            [tableView selectRowAtIndexPath:indexPath
                                   animated:NO
                             scrollPosition:UITableViewScrollPositionMiddle];
        }
        
        return cell;
    }
    else
    {
        static NSString *CellIdentifier = @"Cell_Identifier_filter_sub";
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
        if (nil == cell) {
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault
                                          reuseIdentifier:CellIdentifier];
            cell.backgroundColor = [QTools colorWithRGB:240 :240 :240];
            
            cell.textLabel.font = [UIFont systemFontOfSize:12];
            cell.textLabel.textColor = [QTools colorWithRGB:107 :107 :107];
        }
        for (id subView in cell.contentView.subviews) {
            [subView removeFromSuperview];
        }
        
        QCategoryModel *parentModel = [_dataArr objectAtIndex:_parentIndex];
        if (indexPath.row == 0)
        {
            cell.textLabel.text = @"全部";
        }
        else
        {
            QCategorySubModel *subModel = [parentModel.subList objectAtIndex:indexPath.row - 1];
            cell.textLabel.text = subModel.categoryName;
        }

        UIView *separatorLineView = [[UIView alloc] initWithFrame:CGRectMake(0, [self tableView:tableView heightForRowAtIndexPath:indexPath] - 0.5, tableView.deFrameWidth, 0.5)];
        separatorLineView.backgroundColor = [QTools colorWithRGB:229 :229 :229];
        [cell.contentView addSubview:separatorLineView];
        
        return cell;
    }
}

#pragma mark - UITableViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (tableView == _parentCategoryTableView) {
        _parentIndex = indexPath.row;
        
        QCategoryModel *parentModel = [_dataArr objectAtIndex:indexPath.row];
        
        if (parentModel.subList.count == 0) {
            [self didSelectNewCategory:parentModel sub:nil];
            [self hideMenu];
        }
        else {
            [_subCategoryTableView reloadData];
        }
    }
    else
    {
        QCategoryModel *parentModel = [_dataArr objectAtIndex:_parentIndex];
        if (indexPath.row == 0)
        {
            [self didSelectNewCategory:parentModel sub:nil];
        }
        else
        {
            [self didSelectNewCategory:parentModel sub:[parentModel.subList objectAtIndex:indexPath.row - 1]];
        }
        [self hideMenu];
    }
}

@end
