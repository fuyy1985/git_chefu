//
//  QMyList.m
//  HRClient
//
//  Created by ekoo on 14/12/11.
//  Copyright (c) 2014年 panyj. All rights reserved.
//

#import "QMyList.h"
#import "QMyListCell.h"
#import "QViewController.h"
#import "QHttpMessageManager.h"
#import "QDifStatusListQtyModel.h"
#import "QMyListDetailModel.h"
#import "QDataPaging.h"
#import "MJRefresh.h"

@interface QMyList ()<QMyListCellDelegate>
{
    long selectIndex;
    QDifStatusListQtyModel *qtyModel;
    QMyListDetailModel *listModel;
    QDataPaging *_dataPage;
    UIView *bottomView;
    
    NSMutableArray *deleteArr;
    NSUInteger flag_seg;
}
@property (nonatomic,strong)UITableView *myListTableView;
@property (nonatomic,strong)NSDictionary *dic;
@property (nonatomic,strong)UISegmentedControl *segmentControl;
@property (nonatomic,strong)UIButton *editBtn;
@property (nonatomic,copy)NSString *noPay;
@property (nonatomic,copy)NSString *noConsumption;
@property (nonatomic,copy)NSString *noEvaluate;
@property (nonatomic,copy)NSString *backOrders;

@end

@implementation QMyList

- (NSString *)title{
    return @"我的订单";
}

- (QCacheType)pageCacheType //NOTE:页面缓存方式
{
    return kCacheTypeCommon;
}

- (void)pageEvent:(QPageEventType)eventType
{
    if (eventType == kPageEventWillShow)
    {
        NSString *userId = [ASUserDefaults objectForKey:AccountUserID];
        [[QHttpMessageManager sharedHttpMessageManager] accessGetListQtyAccordingDifStatus:userId];
        [ASRequestHUD show];
    }
    else if (eventType == kPageEventViewCreate)
    {
        deleteArr = [[NSMutableArray alloc] initWithCapacity:0];
        
        _dataPage = [[QDataPaging alloc] init];
        [self initDataPage];
        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(receiveListQty:) name:kGetQtyAccountStatus object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(receiveListDifStatus:) name:kGetListAccountStatus object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(reveiveDeleInfro:) name:kGetEditDelegate object:nil];
        
        NSString *userId = [ASUserDefaults objectForKey:AccountUserID];
        [[QHttpMessageManager sharedHttpMessageManager] accessGetListQtyAccordingDifStatus:userId];
        [ASRequestHUD show];
    }
    else if (eventType == kPageEventWillHide)
    {
        [ASRequestHUD dismiss];
    }
    else if (eventType == kPageEventViewDispose)
    {
        [[NSNotificationCenter defaultCenter] removeObserver:self];
    }
}

- (void)setActiveWithParams:(NSDictionary*)params //NOTE:方便页面激活时接收参数
{
    self.dic = [NSDictionary dictionary];
    self.dic = params;
}

- (UIBarButtonItem*)pageRightMenu
{
    _view.backgroundColor = [QTools colorWithRGB:240 :239 :237];
    _editBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    _editBtn.frame = CGRectMake(0, 0, 40, 10);
    [_editBtn setTitleColor:[QTools colorWithRGB:255 :255 :255] forState:UIControlStateNormal];
    _editBtn.titleLabel.font = [UIFont boldSystemFontOfSize:14];
    _editBtn.userInteractionEnabled = NO;
    [_editBtn addTarget:self action:@selector(setEditigToDele) forControlEvents:UIControlEventTouchUpInside];
    
    UIBarButtonItem *editItem = [[UIBarButtonItem alloc] initWithCustomView:_editBtn];
    return editItem;
}

-(void)ChangeSegmentFont:(UIView *)aView
{
    if ([aView isKindOfClass:[UILabel class]]) {
        UILabel *lb = (UILabel    *)aView;
        [lb setTextAlignment:NSTextAlignmentCenter];
        [lb setFrame:CGRectMake(0, 0, 120, 30)];
        [lb setFont:[UIFont systemFontOfSize:14]];
    }
    NSArray *na = [aView subviews];
    NSEnumerator *ne = [na objectEnumerator];
    UIView *subView;
    while (subView = [ne nextObject]) {
        [self ChangeSegmentFont:subView];
    }
}

- (UIView *)viewWithFrame:(CGRect)frame{
    if ([super viewWithFrame:frame]) {
        _view.backgroundColor = [UIColor whiteColor];
        UIView *headerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, frame.size.width, 50)];
        [_view addSubview:headerView];

        //segmentControl
        _segmentControl = [[UISegmentedControl alloc] initWithItems:@[@"", @"", @"", @"", @""]];
        _segmentControl.frame = CGRectMake(10, 8, (_view.frame.size.width - 20), 30);
        _segmentControl.tintColor = ColorTheme;
        _segmentControl.selectedSegmentIndex = 0;
        if ([[self.dic objectForKeyedSubscript:@"page"] isEqualToString:@"3"]) {
            _segmentControl.selectedSegmentIndex = 3;
        }
        [self updateSegmentTitle:[[QDifStatusListQtyModel alloc] init]];
        
        // 字体大小
        if ( [[UIDevice currentDevice].systemVersion doubleValue] < 7.0)
        {
        NSDictionary *attributes = [NSDictionary dictionaryWithObjectsAndKeys:[UIFont systemFontOfSize:10],NSFontAttributeName,ColorTheme, NSForegroundColorAttributeName, nil];
        [_segmentControl setTitleTextAttributes:attributes forState:UIControlStateNormal];
        }
        [_segmentControl addTarget:self action:@selector(segmentedControl:) forControlEvents:UIControlEventValueChanged];
        [_view addSubview:_segmentControl];
        
        _myListTableView = [[UITableView alloc] initWithFrame:CGRectMake(0, headerView.frame.size.height, frame.size.width, frame.size.height - headerView.frame.size.height) style:UITableViewStylePlain];
        _myListTableView.dataSource = self;
        _myListTableView.delegate = self;
        _myListTableView.separatorStyle = UITableViewCellSeparatorStyleNone;
        _myListTableView.backgroundColor = [UIColor clearColor];
        _myListTableView.tableFooterView = [UIView new];
        [_view addSubview:_myListTableView];
        [_myListTableView addLegendHeaderWithRefreshingTarget:self refreshingAction:@selector(headerRereshing)];

        //创建删除按钮
        bottomView = [[UIView alloc] initWithFrame:CGRectMake(0, _view.frame.size.height, _view.frame.size.width, 50)];
        bottomView.backgroundColor = [QTools colorWithRGB:240 :239 :237];
        UILabel *lineLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, bottomView.deFrameWidth, 1)];
        lineLabel.backgroundColor = [QTools colorWithRGB:209 :208 :206];
        [bottomView addSubview:lineLabel];
        //[_view addSubview:bottomView];
        UIButton *deletaBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [deletaBtn addTarget:self action:@selector(deleteActon) forControlEvents:UIControlEventTouchUpInside];
        deletaBtn.frame = CGRectMake((frame.size.width - 115)/2, 10, 115, 30);
        [deletaBtn setTitle:@"删除" forState:UIControlStateNormal];
        deletaBtn.backgroundColor = ColorTheme;
        deletaBtn.layer.masksToBounds = YES;
        deletaBtn.layer.cornerRadius = 4.0;
        [deletaBtn setTitleColor:[QTools colorWithRGB:255 :255 :255] forState:UIControlStateNormal];
        [bottomView addSubview:deletaBtn];
        [_view addSubview:bottomView];
    }
    return _view;
}

#pragma mark - Private

/**
 编辑按钮变化
 */
- (void)enableEditList:(BOOL)isEnable
{
    if (isEnable) {
        _editBtn.userInteractionEnabled = YES;
        [_editBtn setTitle:@"编辑" forState:UIControlStateNormal];
    }
    else {
        _editBtn.userInteractionEnabled = NO;
        [_editBtn setTitle:@"" forState:UIControlStateNormal];
        
        _myListTableView.editing = NO;
        
        [UIView animateWithDuration:0.2 animations:^{
            
            CGRect rect = _myListTableView.frame;
            rect.size.height = _view.frame.size.height - CGRectGetMaxY(_segmentControl.frame) - 10;
            _myListTableView.frame = rect;
            
            bottomView.frame = CGRectMake(0, _view.frame.size.height, _view.frame.size.width, 50);
            
        }];
    }
}

/**
 订单各个状态的数目
 */
- (void)updateSegmentTitle:(QDifStatusListQtyModel *)model{
    
    _noPay = [NSString stringWithFormat:@"未付款(%d)",model.noPay];
    _noConsumption = [NSString stringWithFormat:@"未消费(%d)",model.noConsumption];
    _noEvaluate = [NSString stringWithFormat:@"待评价(%d)",model.haveevaluate + model.noEvaluate];
    _backOrders = [NSString stringWithFormat:@"已退款(%d)",model.backOrders];
    
    [_segmentControl setTitle:@"全部" forSegmentAtIndex:0];
    [_segmentControl setTitle:_noPay forSegmentAtIndex:1];
    [_segmentControl setTitle:_noConsumption forSegmentAtIndex:2];
    [_segmentControl setTitle:_noEvaluate forSegmentAtIndex:3];
    [_segmentControl setTitle:_backOrders forSegmentAtIndex:4];
}

/**
 segment的索引
 */
- (NSString*)getStatusbySegmentIndex:(NSInteger)index
{
    NSString *status = @"";
    switch (_segmentControl.selectedSegmentIndex) {
        case 0:
            status = @"";
            break;
        case 1:
            status = [NSString stringWithFormat:@"%d", kOrderStatusUnPayed];
            break;
        case 2:
            status = [NSString stringWithFormat:@"%d", kOrderStatusUnUsed];
            break;
        case 3:
            status = [NSString stringWithFormat:@"%d", kOrderStatusNeedRemark];
            break;
        case 4:
            status = [NSString stringWithFormat:@"%d", kOrderStatusRefund];
            break;
        default:
            break;
    }
    return status;
}

- (void)getListByStatus:(NSString*)status
{
    [[QHttpMessageManager sharedHttpMessageManager] accessGetListAccordStatus:status
                                                               andcurrentPage:INTTOSTRING(_dataPage.nextPage)
                                                                  andPageSize:INTTOSTRING(_dataPage.pageSize)];
}

- (void)initDataPage
{
    _dataPage.nextPage = 1;
    _dataPage.pageSize = 12;
}

- (void)headerRereshing
{
    if (_myListTableView.legendFooter.isRefreshing)
        return;
    
    [self initDataPage];
    [self getListByStatus:[self getStatusbySegmentIndex:selectIndex]];
}

- (void)footerLoading
{
    if (_myListTableView.legendHeader.isRefreshing)
        return;
    
    [self getListByStatus:[self getStatusbySegmentIndex:selectIndex]];
}

#pragma mark - Action

//编辑
- (void)setEditigToDele{
    {
        NSString *str = [_editBtn titleForState:UIControlStateNormal];
        if ([str isEqualToString:@"编辑"]) {
            
            [UIView animateWithDuration:0.2 animations:^{
                
                CGRect rect = _myListTableView.frame;
                rect.size.height = _view.frame.size.height - CGRectGetMaxY(_segmentControl.frame) - 60;
                _myListTableView.frame = rect;
                
                bottomView.frame = CGRectMake(0, _view.frame.size.height - 50, _view.frame.size.width, 50);
                
            }];
            
            _myListTableView.editing = YES;
            [_editBtn setTitle:@"取消" forState:UIControlStateNormal];
        }else{
            
            [UIView animateWithDuration:0.2 animations:^{
                
                CGRect rect = _myListTableView.frame;
                rect.size.height = _view.frame.size.height - CGRectGetMaxY(_segmentControl.frame) - 10;
                _myListTableView.frame = rect;
                
                bottomView.frame = CGRectMake(0, _view.frame.size.height, _view.frame.size.width, 50);
                
            }];
            _myListTableView.editing = NO;
            [_editBtn setTitle:@"编辑" forState:UIControlStateNormal];
        }
    }
}

- (void)deleteActon
{
    NSString *orderListId = @"";
    
    for (QMyListDetailModel *orderStatus in deleteArr) {
        
        NSString *orderId = [orderStatus.orderListId stringValue];
        if ([orderListId isEqualToString:@""]) {
            orderListId = [orderListId stringByAppendingString:orderId];
        }
        else {
            orderListId = [orderListId stringByAppendingString:@","];
            orderListId = [orderListId stringByAppendingString:orderId];
        }
    }

    if ([orderListId isEqualToString:@""])
    {
        [QViewController showMessage:@"您还未选取订单"];
    }
    else
    {
        [[QHttpMessageManager sharedHttpMessageManager] accessEditDelegate:orderListId];
        [ASRequestHUD show];
    }
}

#pragma mark - Notification
/**
 成功获取不同状态订单
 */
- (void)receiveListDifStatus:(NSNotification *)noti
{
    [_dataPage setMData:noti.object];
    _dataPage.nextPage++;
    
    [_myListTableView reloadData];
    
    if (_myListTableView.legendHeader.isRefreshing)
        [_myListTableView.legendHeader endRefreshing];
    if (_myListTableView.legendFooter.isRefreshing)
        [_myListTableView.legendFooter endRefreshing];
    
    if(_dataPage.mData.count < (_dataPage.nextPage - 1) * _dataPage.pageSize) //表示不需要loading
        [_myListTableView removeFooter];
    else
    {
        if (!_myListTableView.legendFooter)
            [_myListTableView addLegendFooterWithRefreshingTarget:self refreshingAction:@selector(footerLoading)];
    }
}

/**
 成功获取不同状态订单数
 */
- (void)receiveListQty:(NSNotification *)noti{

    qtyModel = noti.object;
    [self updateSegmentTitle:qtyModel];
    [ASRequestHUD dismiss];
    
    [_myListTableView.legendHeader beginRefreshing];
}

/**
 成功删除
 */
- (void)reveiveDeleInfro:(NSNotification *)noti{
    
    [ASRequestHUD dismissWithSuccess:@"删除成功"];
    
    [deleteArr removeAllObjects];
    //table恢复正常
    [self setEditigToDele];
    
    [[QHttpMessageManager sharedHttpMessageManager] accessGetListQtyAccordingDifStatus:[ASUserDefaults objectForKey:AccountUserID]];
}

#pragma mark - UISegmentedControl Delegate
- (void)segmentedControl:(UISegmentedControl*)segmentedControl
{
    selectIndex = segmentedControl.selectedSegmentIndex;
    
    /*
    if ( [[UIDevice currentDevice].systemVersion doubleValue] < 7.0)
        [self ChangeSegmentFont:segmentedControl];*/
    
    if (selectIndex == 1 || selectIndex == 3) {
        [self enableEditList:YES];
    }
    else{
        [self enableEditList:NO];
    }
    
    [_myListTableView.legendHeader beginRefreshing];
}

#pragma mark - UITabelViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return _dataPage.mData.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return ListCellHeight;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    static NSString *myList = @"MyList";
    QMyListCell *cell = [tableView dequeueReusableCellWithIdentifier:myList];
    if (cell == nil) {
        cell = [[QMyListCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:myList];
        cell.delegate = self;
    }
    BOOL isSelected = NO;
    NSDictionary *currentDict = [_dataPage.mData objectAtIndex:indexPath.row];
    NSUInteger index = [deleteArr indexOfObject:currentDict];
    if (index < _dataPage.mData.count) {
        isSelected = YES;
    }
    
    cell.isChecked = isSelected;
    [cell configureModelForCell:_dataPage.mData andInexPath:indexPath];
    
    return cell;
}

#pragma mark - UITableViewDelegate

-(UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return UITableViewCellEditingStyleNone;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{

    if (tableView.editing)
    {
        ;
    }
    else {
        QMyListDetailModel *model = _dataPage.mData[indexPath.row];
        NSDictionary *dic = [[NSDictionary alloc] initWithObjectsAndKeys:model, @"model", nil];
        
        switch ([model.status intValue]) {
            case kOrderStatusUnPayed:
            case kOrderStatusUnUsed:
            case kOrderStatusRefund:
                [QViewController gotoPage:@"QListDetail" withParam:[[NSDictionary alloc] initWithObjectsAndKeys:model.orderListId, @"orderListId", model.status, @"status", nil]];
                break;
            case kOrderStatusNeedRemark:
                [QViewController gotoPage:@"QRemark" withParam:dic];
                break;
            default:
                break;
        }
    }

    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

#pragma mark - QMyListCellDelegate

- (void)setSelectforDelete:(QMyListCell *)cell delete:(BOOL)isDelete
{
    NSIndexPath *indexPath = [_myListTableView indexPathForCell:cell];
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
