//
//  QTitleSearch.m
//  HRClient
//
//  Created by ekoo on 14/12/28.
//  Copyright (c) 2014年 panyj. All rights reserved.
//

#import "QTitleSearch.h"
#import "QViewController.h"
#import "QHSearchBar.h"
#import "QBaseFilterView.h"
#import "QHttpMessageManager.h"
#import "QBusinessListModel.h"

@interface QTitleSearch ()<UITableViewDataSource,UITableViewDelegate>
{
    NSArray *_models;
}
@property (nonatomic,strong)QBaseFilterView *filterView;
@property (nonatomic,strong)UITextField *searchTextField;
@property (nonatomic,strong)UITableView *tableView;

@end

@implementation QTitleSearch

- (UITableView*)tableView
{
    if (!_tableView) {
        _tableView = [[UITableView alloc] initWithFrame:_view.bounds];
        _tableView.dataSource = self;
        _tableView.delegate = self;
        [_view addSubview:_tableView];
    }
    return _tableView;
}

- (UIView*)titleViewWithFrame:(CGRect)frame
{
    UIView *searchView = [[UIView alloc] initWithFrame:CGRectMake(65, 9, SCREEN_SIZE_WIDTH - 2*65, 28)];
    searchView.userInteractionEnabled = YES;
    
    _searchTextField = [[UITextField alloc] initWithFrame:searchView.bounds];
    _searchTextField.borderStyle = UITextBorderStyleRoundedRect;
    _searchTextField.placeholder = @"找商家";
    _searchTextField.font = [UIFont systemFontOfSize:14];
    _searchTextField.delegate = self;
    _searchTextField.userInteractionEnabled = YES;
    _searchTextField.clearButtonMode = UITextFieldViewModeWhileEditing;
    _searchTextField.returnKeyType = UIReturnKeySearch;
    [searchView addSubview:_searchTextField];
    
    UIImageView *leftView=[[UIImageView alloc]initWithFrame:CGRectMake(10, 3, 26, 26)];
    leftView.image= [UIImage imageNamed:@"search_.png"];
    leftView.contentMode = UIViewContentModeCenter;
    _searchTextField.leftView=leftView;
    _searchTextField.leftViewMode=UITextFieldViewModeAlways;
    
    return searchView;
}

- (UIBarButtonItem*)pageRightMenu
{
    UIButton *editBtn = [[UIButton alloc] init];
    editBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    editBtn.frame = CGRectMake(0, 0, 40, 10);
    [editBtn setTitle:@"搜索" forState:UIControlStateNormal];
    [editBtn setTitleColor:[QTools colorWithRGB:255 :255 :255] forState:UIControlStateNormal];
    editBtn.titleLabel.font = [UIFont boldSystemFontOfSize:16];
    [editBtn addTarget:self action:@selector(clickSearch) forControlEvents:UIControlEventTouchUpInside];
    
    UIBarButtonItem *editItem = [[UIBarButtonItem alloc] initWithCustomView:editBtn];
    return editItem;
}

- (UIView *)viewWithFrame:(CGRect)frame{
    if ([super viewWithFrame:frame]) {
        
        _filterView = [[QBaseFilterView alloc] initWithFrame:CGRectMake(0, 0, frame.size.width, frame.size.height )];
        [_view addSubview:_filterView];
    }
    
    return _view;
}

- (QCacheType)pageCacheType
{
    return kCacheTypeNone;
}

- (void)pageEvent:(QPageEventType)eventType
{
    if (eventType == kPageEventViewCreate)
    {
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(successSearchBusiness:) name:kSearchBusiness object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(textValueChange:) name:UITextFieldTextDidChangeNotification object:nil];
    }
    else if (eventType == kPageEventWillShow)
    {
        [_searchTextField becomeFirstResponder];
    }
    else if (eventType == kPageEventWillHide)
    {
        if ([_searchTextField isFirstResponder])
            [_searchTextField resignFirstResponder];
    }
    else if (eventType == kPageEventViewDispose)
    {
        [[NSNotificationCenter defaultCenter] removeObserver:self];
    }
}

#pragma mark - Private

- (void)clickSearch
{
    [_searchTextField resignFirstResponder];
    
    [[QHttpMessageManager sharedHttpMessageManager] accessSearchBusiness:[_searchTextField.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]]];
    [ASRequestHUD show];
}

#pragma mark - UITextFieldDelegate
- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
    if ([string isEqual:@"\n"]) {
        [self clickSearch];
        return NO;
    }
    return YES;
}
#pragma mark - Notification

- (void)textValueChange:(NSNotification*)notify
{
    UITextField *textField = (UITextField*)[notify object];
    debug_NSLog(@"%@", textField.text);
}

- (void)successSearchBusiness:(NSNotification*)noti
{
    _models = noti.object;
    if (_models.count < 1) {
        UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, self.tableView.deFrameWidth, 50)];
        label.backgroundColor = [UIColor clearColor];
        label.font = [UIFont systemFontOfSize:14];
        label.textColor = ColorDarkGray;
        label.textAlignment = NSTextAlignmentCenter;
        label.text = @"没有搜索到相关的商家";
        self.tableView.tableFooterView = label;
    }
    else {
        self.tableView.tableFooterView = [UIView new];
    }
    [self.tableView reloadData];
    [ASRequestHUD dismiss];
}

#pragma mark - UITableViewDataSource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return _models.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *cellIdentifier = @"cellIdentifier";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    if (nil == cell)
    {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
        cell.textLabel.font = [UIFont systemFontOfSize:14];
        cell.textLabel.textColor = ColorDarkGray;
    }
    
    if (indexPath.row >= _models.count) {
        return cell;
    }
    
    cell.imageView.image = [UIImage imageNamed:@"search_.png"];
    QBusinessListModel *model = [_models objectAtIndex:indexPath.row];
    cell.textLabel.text = model.companyName;
    
    return cell;
}
#pragma mark - UITableViewDelegate

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 40;
}

- (void)tableView:(UITableView *)tableView didHighlightRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    cell.contentView.backgroundColor = [QTools colorWithRGB:238 :238 :238];
}

- (void)tableView:(UITableView *)tableView didUnhighlightRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    cell.contentView.backgroundColor = [UIColor whiteColor];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.row < _models.count)
    {
        QBusinessListModel *model = [_models objectAtIndex:indexPath.row];
        [QViewController gotoPage:@"QBusinessDetailPage"
                        withParam:[NSDictionary dictionaryWithObjectsAndKeys:model.companyId, @"companyID", nil]];
    }
    
    [tableView deselectRowAtIndexPath:indexPath animated:NO];
}

@end
