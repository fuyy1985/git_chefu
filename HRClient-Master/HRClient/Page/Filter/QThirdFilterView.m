//
//  QThirdFilterView.m
//  HRClient
//
//  Created by chenyf on 14/12/29.
//  Copyright (c) 2014年 panyj. All rights reserved.
//  第三个 下拉选择
//  智能排序/距离最近/评价最高/最新发布/人气最高/价格最低/价格最高

#import "QThirdFilterView.h"
#import "QLocationManager.h"

@implementation QFilterKeyModel

+ (QFilterKeyModel*)filterModelbyKey:(FilterKeyType)keyType andListType:(DataListType)listType
{
    NSArray *arr = [QFilterKeyModel defaultFilterKeyModels:listType];
    if (arr.count > (keyType - 1)) {
        return [arr objectAtIndex:(keyType - 1)];
    }
    return nil;
}

+ (NSArray*)defaultFilterKeyModels:(DataListType)listType
{
    NSMutableArray *mArr = [[NSMutableArray alloc] initWithCapacity:0];
    NSArray *names = @[
                    @"智能排序",
                    @"距离最近",
                    @"好评优先",
                    @"最新发布",
                    @"人气优先",
                    @"价格最高",
                    @"价格最低"];
    if (listType == kDataBusinuessType)
    {
        names = @[
                  @"智能排序",
                  @"距离最近",
                  @"最新发布"];
    }
    
    for (NSString *name in names)
    {
        QFilterKeyModel *model = [[QFilterKeyModel alloc] init];
        model.keyType = (int)[names indexOfObject:name] + 1;
        model.keyName = name;
        [mArr addObject:model];
    }
    return mArr;
}


@end

@interface QThirdFilterView ()
@property (nonatomic) UITableView *filterTableView;
@property (nonatomic) NSArray *filterList;
@end

@implementation QThirdFilterView

- (id)initWithFrame:(CGRect)frame andListType:(DataListType)listType
{
    self = [super initWithFrame:frame];
    if (self)
    {
        CGFloat menuHeight = 210;
        
        self.menuView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, frame.size.width, menuHeight)];
        [self addSubview:self.menuView];
        
        _filterTableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, frame.size.width , menuHeight) style:UITableViewStylePlain];
        _filterTableView.separatorStyle = UITableViewCellSeparatorStyleNone;
        _filterTableView.delegate = self;
        _filterTableView.dataSource = self;
        [self.menuView addSubview:_filterTableView];
        
        _filterList = [QFilterKeyModel defaultFilterKeyModels:listType];
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
    
    if (self.delegate && [self.delegate respondsToSelector:@selector(didHideThirdFilterView)]) {
        [self.delegate didHideThirdFilterView];
    }
}

#pragma mark - UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return _filterList.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 30;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell_Identifier_filter_3";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (nil == cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault
                                      reuseIdentifier:CellIdentifier];
    }
    [cell.contentView.subviews makeObjectsPerformSelector:@selector(removeFromSuperview)];
    
    QFilterKeyModel *model = _filterList[indexPath.row];
    cell.textLabel.text = model.keyName;
    cell.textLabel.font = [UIFont systemFontOfSize:13];
    cell.textLabel.textColor = [QTools colorWithRGB:107 :107 :107];

    
    UIView *separatorLineView = [[UIView alloc] initWithFrame:CGRectMake(0, [self tableView:tableView heightForRowAtIndexPath:indexPath] - 0.5, tableView.deFrameWidth, 0.5)];
    separatorLineView.backgroundColor = ColorLine;
    [cell.contentView addSubview:separatorLineView];

    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (1 == indexPath.row && ![[QLocationManager sharedInstance] canStartLocation])
    {
        //距离最近
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:nil
                                                            message:@"无法定位当前位置，请到\"设置->隐私\"打开定位服务"
                                                           delegate:self
                                                  cancelButtonTitle:nil
                                                  otherButtonTitles:@"知道了", nil];
        [alertView show];
    }
    else
    {
        //如果没有定位结果,重新定位
        if (![QLocationManager sharedInstance].geoResult)
        {
            [[QLocationManager sharedInstance] startUserLocation];
        }
        
        if (self.delegate && [self.delegate respondsToSelector:@selector(didChangeKey:)]) {
            [self.delegate didChangeKey:[_filterList objectAtIndex:indexPath.row]];
        }
    }
    
    
    [self hideMenu];
}


@end
