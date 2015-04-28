//
//  QMyCollect.m
//  HRClient
//
//  Created by ekoo on 14/12/17.
//  Copyright (c) 2014年 panyj. All rights reserved.
//

#import "QMyCollect.h"
#import "QMyCollectCell.h"
#import "QHttpMessageManager.h"
#import "QMyFavoritedModel.h"
#import "QViewController.h"
#import "MJRefresh.h"
#import "QDataPaging.h"

@interface QMyCollect () <QMyCollectCellDelegate>
{
    UISegmentedControl *segmentControl;
    UITableView *collectTableView;
    UIButton *deletaBtn;
    NSMutableArray *deleteArr;
    
    UIView *bottomView;
    UIButton *editBtn;
}
@property (nonatomic, strong) QDataPaging *dataPage;

@end

@implementation QMyCollect


- (void)pageEvent:(QPageEventType)eventType
{
    if (eventType == kPageEventWillShow)
    {

    }
    else if (eventType == kPageEventWillHide)
    {
        [ASRequestHUD dismiss];

        [deleteArr removeAllObjects];
        [collectTableView reloadData];
    }
    else if (eventType == kPageEventViewCreate)
    {
        _dataPage = [[QDataPaging alloc] init];
        _dataPage.pageSize = 12;
        
        deleteArr = [[NSMutableArray alloc] initWithCapacity:0];
        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(successToGetMyFavoirty:) name:kMyFavority object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(successToDeleteMyFavoirty:) name:kDelectFavority object:nil];
        
        [collectTableView.legendHeader beginRefreshing];
    }
    else if (eventType == kPageEventViewDispose)
    {
        [[NSNotificationCenter defaultCenter] removeObserver:self name:kMyFavority object:nil];
        [[NSNotificationCenter defaultCenter] removeObserver:self name:kDelectFavority object:nil];
    }
}

- (UIBarButtonItem*)pageRightMenu{
    _view.backgroundColor = [QTools colorWithRGB:240 :239 :237];
    
    editBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    editBtn.titleLabel.font = [UIFont systemFontOfSize:14];
    editBtn.frame = CGRectMake(0, 0, 40, 10);
    [editBtn setTitle:@"编辑" forState:UIControlStateNormal];
    [editBtn setTitleColor:[QTools colorWithRGB:255 :255 :255] forState:UIControlStateNormal];
    [editBtn addTarget:self action:@selector(setEditig:animattted:) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem *editItem = [[UIBarButtonItem alloc] initWithCustomView:editBtn];
    return editItem;
}

- (NSString *)title{
    return @"我的收藏";
}

- (UIView *)viewWithFrame:(CGRect)frame{
    if ([super viewWithFrame:frame]) {

        collectTableView = [[UITableView alloc] initWithFrame:frame style:UITableViewStylePlain];
        //collectTableView.rowHeight = (iPhone6 || iPhone6Plus) ? 60 : 50;
        collectTableView.delegate = self;
        collectTableView.dataSource = self;
        collectTableView.backgroundColor = [QTools colorWithRGB:240 :239 :237];
        collectTableView.separatorStyle = UITableViewCellSeparatorStyleNone;
        [_view addSubview:collectTableView];
        [collectTableView addLegendHeaderWithRefreshingTarget:self refreshingAction:@selector(headerRefresh)];
        
        //创建删除按钮
        bottomView = [[UIView alloc] initWithFrame:CGRectMake(0, _view.frame.size.height, _view.frame.size.width, 50)];
        bottomView.backgroundColor = [QTools colorWithRGB:240 :239 :237];
        [_view addSubview:bottomView];

        deletaBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [deletaBtn setBackgroundImage:[QTools createImageWithColor:ColorTheme] forState:UIControlStateNormal];
        [deletaBtn addTarget:self action:@selector(deleteActon) forControlEvents:UIControlEventTouchUpInside];
        [deletaBtn setTitleColor:[QTools colorWithRGB:255 :255 :255] forState:UIControlStateNormal];
        deletaBtn.frame = CGRectMake((frame.size.width - 115)/2, 10, 115, 30);
        [deletaBtn setTitle:@"删除" forState:UIControlStateNormal];
        deletaBtn.titleLabel.font = [UIFont systemFontOfSize:15];
        deletaBtn.layer.masksToBounds = YES;
        deletaBtn.layer.cornerRadius = 4.0;
        [bottomView addSubview:deletaBtn];
    }
    return _view;
}

- (void)headerRefresh
{
    _dataPage.nextPage = 1;
    [[QHttpMessageManager sharedHttpMessageManager] accessMyfavority:[NSString stringWithFormat:@"%d", _dataPage.nextPage]
                                                         andPageSize:[NSString stringWithFormat:@"%d", _dataPage.pageSize]];
}

- (void)footerLoading
{
    [[QHttpMessageManager sharedHttpMessageManager] accessMyfavority:[NSString stringWithFormat:@"%d", _dataPage.nextPage]
                                                         andPageSize:[NSString stringWithFormat:@"%d", _dataPage.pageSize]];
}

#pragma mark - Action

- (void)setEditig:(BOOL)editig animattted:(BOOL)animated
{
    NSString *str = [editBtn titleForState:UIControlStateNormal];
    if ([str isEqualToString:@"编辑"])
    {
        
        [UIView animateWithDuration:0.2 animations:^{
            
            CGRect rect = collectTableView.frame;
            rect.size.height = _view.frame.size.height - CGRectGetMaxY(segmentControl.frame) - 60;
            collectTableView.frame = rect;
            
            bottomView.frame = CGRectMake(0, _view.frame.size.height - 50, _view.frame.size.width, 50);
            
        }];
        
        collectTableView.editing = YES;
        [editBtn setTitle:@"完成" forState:UIControlStateNormal];
    }
    else
    {
        
        [UIView animateWithDuration:0.2 animations:^{
            
            CGRect rect = collectTableView.frame;
            rect.size.height = _view.frame.size.height - CGRectGetMaxY(segmentControl.frame) - 10;
            collectTableView.frame = rect;
            
            bottomView.frame = CGRectMake(0, _view.frame.size.height, _view.frame.size.width, 50);
            
        }];
        collectTableView.editing = NO;
        [editBtn setTitle:@"编辑" forState:UIControlStateNormal];
    }
}

- (void)deleteActon
{
    NSString *orderListId = @"";
    
    for (NSDictionary *dict in deleteArr) {
        
        NSString *favoriteId = [[dict objectForKey:@"favoriteId"] stringValue];
        if ([orderListId isEqualToString:@""]) {
            orderListId = [orderListId stringByAppendingString:favoriteId];
        }
        else {
            orderListId = [orderListId stringByAppendingString:@","];
            orderListId = [orderListId stringByAppendingString:favoriteId];
        }
    }
    [[QHttpMessageManager sharedHttpMessageManager] accessDelectMyFavority:orderListId];
    [ASRequestHUD show];
}

#pragma mark - Data

//成功获取数据
- (void)successToGetMyFavoirty:(NSNotification *)noti
{
    //数据处理
    [_dataPage setMData:noti.object];
    _dataPage.nextPage++;
    
    //tableview刷新
    if (collectTableView.legendHeader.isRefreshing)
        [collectTableView.legendHeader endRefreshing];
    if (collectTableView.legendFooter.isRefreshing)
        [collectTableView.legendFooter endRefreshing];
    
    if(_dataPage.mData.count < (_dataPage.nextPage - 1) * _dataPage.pageSize) //表示不需要loading
        [collectTableView removeFooter];
    else
    {
        if (!collectTableView.legendFooter)
            [collectTableView addLegendFooterWithRefreshingTarget:self refreshingAction:@selector(footerLoading)];
    }
    
    [collectTableView reloadData];
}

//成功删除数据
- (void)successToDeleteMyFavoirty:(NSNotification*)noti
{
    [ASRequestHUD dismissWithSuccess:@"删除成功"];
    
    for (QMyFavoritedModel *model in deleteArr) {
        [_dataPage.mData removeObject:model];
    }
    [deleteArr removeAllObjects];
    
    [self setEditig:NO animattted:YES];
    [collectTableView reloadData];
}

#pragma mark - UITableView DataSource

-(UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return UITableViewCellEditingStyleNone;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return _dataPage.mData.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 87;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    static NSString *collectID = @"collectID";
    QMyCollectCell *cell = [tableView dequeueReusableCellWithIdentifier:collectID];
    
    if (cell == nil) {
        cell = [[QMyCollectCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:collectID];
        cell.delegate = self;
    }
    
    BOOL isSelected = NO;
    NSDictionary *currentDict = [_dataPage.mData objectAtIndex:indexPath.row];
    NSUInteger index = [deleteArr indexOfObject:currentDict];
    if (index < _dataPage.mData.count) {
        isSelected = YES;
    }
    
    cell.isChecked = isSelected;
    [cell configureCellWithData:_dataPage.mData andIndexPath:indexPath];
    return cell;
}

#pragma mark - UITableDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (tableView.editing)
    {
        ;
    }
    else
    {
        NSDictionary *favoriteDict = _dataPage.mData[indexPath.row];
        QBusinessDetailResult *model = [favoriteDict objectForKey:@"model"];
        [QViewController gotoPage:@"QGroupBuyDetailPage" withParam:[NSDictionary dictionaryWithObjectsAndKeys:model.productId, @"ProductID", nil]];
    }
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

#pragma mark - QMyCollectCell Delegate
- (void)setSelectforDelete:(QMyCollectCell*)cell delete:(BOOL)isDelete
{
    NSIndexPath *indexPath = [collectTableView indexPathForCell:cell];
    if (_dataPage.mData.count <= indexPath.row) {
        return;
    }
    NSDictionary *modelDict = [_dataPage.mData objectAtIndex:indexPath.row];
    if (isDelete) {
        [deleteArr addObject:modelDict];;
    }
    else {
        [deleteArr removeObject:modelDict];
    }
}

@end
