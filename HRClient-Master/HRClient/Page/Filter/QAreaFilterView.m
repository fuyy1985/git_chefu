//
//  QAreaFilterView.m
//  HRClient
//
//  Created by chenyf on 14/12/29.
//  Copyright (c) 2014年 panyj. All rights reserved.
//  城区 下拉选择

#import "QAreaFilterView.h"
#import "QHttpMessageManager.h"
#import "QHotCityModel.h"

@interface QAreaFilterView ()
{
    NSString *_currentCityID;
}
@property (nonatomic, strong) UITableView *areaTableView;
@property (nonatomic, strong) UITableView *subAreaTableView;
@property (nonatomic, assign) NSInteger parentIndex;
@property (nonatomic, strong) NSMutableDictionary *areasDict;
@end

@implementation QAreaFilterView

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self name:kGetRegion object:nil];
}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self)
    {
        _parentIndex = 0;
        _currentCityID = [[ASUserDefaults objectForKey:CurrentRegionID] stringValue];
        
        CGFloat menuHeight = 285;
        CGFloat parentW = 140;
        CGFloat subW = 180;
        parentW = frame.size.width * parentW / (parentW + subW);
        subW = frame.size.width - parentW;
        
        self.menuView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, frame.size.width, menuHeight)];
        [self addSubview:self.menuView];
        
        _areaTableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, parentW , menuHeight) style:UITableViewStylePlain];
        _areaTableView.separatorStyle = UITableViewCellSeparatorStyleNone;
        _areaTableView.delegate = self;
        _areaTableView.dataSource = self;
        _areaTableView.backgroundColor = [QTools colorWithRGB:238 :238 :238];
        [self.menuView addSubview:_areaTableView];
        
        _subAreaTableView = [[UITableView alloc] initWithFrame:CGRectMake(_areaTableView.deFrameRight, 0, subW, menuHeight) style:UITableViewStylePlain];
        _subAreaTableView.separatorStyle = UITableViewCellSeparatorStyleNone;
        _subAreaTableView.delegate = self;
        _subAreaTableView.dataSource = self;
        _subAreaTableView.backgroundColor = [QTools colorWithRGB:238 :238 :238];
        [self.menuView addSubview:_subAreaTableView];

        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(successGetRegion:) name:kGetRegion object:nil];
        _areasDict = [[NSMutableDictionary alloc] initWithCapacity:0];
        
        //先从本地获取,若没有则从服务器取
        NSMutableArray *array = [[NSMutableArray alloc] initWithCapacity:0];
        [array addObject:[QRegionModel nullRegion]];
        [array addObjectsFromArray:[QRegionModel getSecLevelRegion]];
        if (array.count < 2) {
            
            [[QHttpMessageManager sharedHttpMessageManager] accessGetRegion:_currentCityID];
            [ASRequestHUD show];
        }
        else {
            [_areasDict setObject:array forKey:_currentCityID];
            [self getThirdLevRegion:array];
        }
    }
    return self;
}

#pragma mark - Super

- (void)showMenu
{
    [super showMenu];
}

- (void)hideMenu
{
    [super hideMenu];
    
    if (self.delegate && [self.delegate respondsToSelector:@selector(didHideAreaView)]) {
        [self.delegate didHideAreaView];
    }
}

#pragma mark - Private
- (void)reloadTableView
{
    [_areaTableView reloadData];
    [_subAreaTableView reloadData];
}

- (void)getThirdLevRegion:(NSArray*)parentRegions
{
    NSDictionary *dict = [QRegionModel getThirdLevelRegion];
    for (QRegionModel *model in parentRegions)
    {
        if (!model.regionId) //全城
            continue;
        NSArray *subAreas = [dict objectForKey:[model.regionId stringValue]];
        if (subAreas) {
            [_areasDict setObject:subAreas forKey:[model.regionId stringValue]];
            continue;
        }
        [[QHttpMessageManager sharedHttpMessageManager] accessGetRegion:[model.regionId stringValue]];
    }
    
    [self reloadTableView];
}

- (void)didChangeArea:(QRegionModel*)model
{
    if (self.delegate && [self.delegate respondsToSelector:@selector(didChangeArea:)]) {
        [self.delegate didChangeArea:model];
    }
    [self reloadTableView];
}

#pragma mark - Notification
- (void)successGetRegion:(NSNotification*)noti {
    
    [ASRequestHUD dismiss];
    
    NSMutableArray *array = [[NSMutableArray alloc] initWithArray:noti.object];
    if (array.count)
    {
        QRegionModel *model = [array objectAtIndex:0];
        if ([[model.parentId stringValue] isEqualToString:_currentCityID])
        {
            //二级区域
            [array insertObject:[QRegionModel nullRegion] atIndex:0];
            [QRegionModel setSecLevelRegion:noti.object];
            
            //获取三级区域
            [self getThirdLevRegion:array];
        }
        [_areasDict setObject:array forKey:[model.parentId stringValue]];
        [QRegionModel setThirdLevelRegion:_areasDict];
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
    NSArray *array = [_areasDict objectForKey:_currentCityID];
    
    if (tableView == _areaTableView) {
        return array.count;
    }
    else {
        QRegionModel *model = [array objectAtIndex:_parentIndex];
        NSArray *subArray = [_areasDict objectForKey:[model.regionId stringValue]];
        NSInteger subCount = subArray.count;
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
    if (tableView == _areaTableView)
    {
        static NSString *CellIdentifier = @"Cell_Identifier_filter_parent";
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
        if (nil == cell) {
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault
                                          reuseIdentifier:CellIdentifier];
            
            UIView *selectedBackgroundView = [[UIView alloc] initWithFrame:cell.frame];
            selectedBackgroundView.backgroundColor = [QTools colorWithRGB:240 :239 :237];
            cell.selectedBackgroundView = selectedBackgroundView;
        }
        for (id subView in cell.contentView.subviews) {
            [subView removeFromSuperview];
        }
        
        NSArray *array = [_areasDict objectForKey:_currentCityID];
        QRegionModel *parentModel = [array objectAtIndex:indexPath.row];
        NSArray *subArr = [_areasDict objectForKey:[parentModel.regionId stringValue]];
        if (subArr && subArr.count) {
            cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        }
        else {
            cell.accessoryType = UITableViewCellAccessoryNone;
        }
        /*
         cell.imageView.image = IMAGEOF(item[0]);
         cell.imageView.deFrameLeft = 13;
         */
        
        cell.textLabel.text = parentModel.regionName;
        cell.textLabel.font = [UIFont systemFontOfSize:13];
        cell.textLabel.textColor = [QTools colorWithRGB:107 :107 :107];
        /*
         QPersistentBackgroundLabel *numberLabel = [[QPersistentBackgroundLabel alloc] initWithFrame:CGRectMake(91, 9, 30, 14)];
         numberLabel.deFrameLeft = tableView.deFrameWidth * (91./140);
         numberLabel.textAlignment = NSTextAlignmentCenter;
         numberLabel.font = [UIFont systemFontOfSize:9];
         numberLabel.textColor = [QTools colorWithRGB:85 :85 :85];
         numberLabel.text = item[2];
         [numberLabel setPersistentBackgroundColor:[QTools colorWithRGB:220 :220 :220]];
         numberLabel.clipsToBounds = YES;
         numberLabel.layer.cornerRadius = 5;
         [cell.contentView addSubview:numberLabel];
         */
        UIView *separatorLineView = [[UIView alloc] initWithFrame:CGRectMake(0, [self tableView:tableView heightForRowAtIndexPath:indexPath] - 0.5, tableView.deFrameWidth, 0.5)];
        separatorLineView.backgroundColor = ColorLine;
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
            cell.textLabel.font = [UIFont systemFontOfSize:13];
            cell.textLabel.textColor = [QTools colorWithRGB:107 :107 :107];
        }
        for (id subView in cell.contentView.subviews) {
            [subView removeFromSuperview];
        }
        
        NSArray *array = [_areasDict objectForKey:_currentCityID];
        QRegionModel *parentModel = [array objectAtIndex:_parentIndex];
        if (indexPath.row == 0)
        {
            cell.textLabel.text = @"全部";
        }
        else
        {
            NSArray *subArr = [_areasDict objectForKey:[parentModel.regionId stringValue]];
            QRegionModel *subModel = [subArr objectAtIndex:indexPath.row];
            
            cell.textLabel.text = subModel.regionName;
        }
 
        UIView *separatorLineView = [[UIView alloc] initWithFrame:CGRectMake(0, [self tableView:tableView heightForRowAtIndexPath:indexPath] - 0.5, tableView.deFrameWidth, 0.5)];
        separatorLineView.backgroundColor = ColorLine;
        [cell.contentView addSubview:separatorLineView];
        
        return cell;
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (tableView == _areaTableView) {
        _parentIndex = indexPath.row;
        
        NSArray *array = [_areasDict objectForKey:_currentCityID];
        QRegionModel *parentModel = [array objectAtIndex:_parentIndex];
        NSArray *subModels = [_areasDict objectForKey:[parentModel.regionId stringValue]];
        
        if (subModels.count == 0) {
            [self didChangeArea:parentModel];
            [self hideMenu];
        }
        else {
            [_subAreaTableView reloadData];
        }
    }
    else {
        
        NSArray *array = [_areasDict objectForKey:_currentCityID];
        QRegionModel *parentModel = [array objectAtIndex:_parentIndex];
        
        if (indexPath.row == 0)
        {
            [self didChangeArea:parentModel];
        }
        else
        {
            NSArray *subModels = [_areasDict objectForKey:[parentModel.regionId stringValue]];
            QRegionModel *subModel = [subModels objectAtIndex:indexPath.row];
            [self didChangeArea:subModel];
        }
        
        [self hideMenu];
    }
}

@end
