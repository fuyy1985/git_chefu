//
//  QCityChange.m
//  HRClient
//
//  Created by ekoo on 14/12/30.
//  Copyright (c) 2014年 panyj. All rights reserved.
//

#import "QCityChange.h"
#import "QHttpMessageManager.h"
#import "QCityChangeeCell.h"
#import "QHotCityModel.h"
#import "pinyin.h"
#import "QViewController.h"

#define MaxRecentCityVisit          (6)

@interface QCityChange ()<QCityChangeeCellDelegate>
{
    QHotCityModel *_selectModel;
}
@property (nonatomic,strong)NSMutableDictionary *cities;
@property (nonatomic,strong)NSMutableArray *keys;//城市首字母
@property (nonatomic,strong)NSArray *arrayCitys;//城市数据
@property (nonatomic,strong)NSArray *arrayHotCity;
@property (nonatomic,strong)NSMutableArray *visitCitys;
@property (nonatomic,copy)NSString *locationCity;
@property (nonatomic,strong)NSArray *modelArr;
@property (nonatomic,strong)UITableView *cityTableView;
@property (nonatomic,strong)NSMutableArray *hotArr;

@end

@implementation QCityChange

- (void)dealloc{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:kHotCity object:nil];
}

- (NSString *)title
{
    return @"切换城市";
}

- (void)setActiveWithParams:(NSDictionary *)params
{
    QRegionModel *model = [QRegionModel defaultRegionModel];
    //定位城市
    _locationCity = model.regionName;
    //最近访问城市
    NSMutableArray *mArrs = [[NSMutableArray alloc] initWithArray:[ASUserDefaults objectForKey:CityRecentVisit]];
    if (mArrs.count > MaxRecentCityVisit) {
        _visitCitys = [[NSMutableArray alloc] initWithArray:[mArrs objectsAtIndexes:[NSIndexSet indexSetWithIndexesInRange:NSMakeRange(0, MaxRecentCityVisit)]]];
    }
    else {
        _visitCitys = mArrs;
    }
    self.keys = [[NSMutableArray alloc] initWithCapacity:0];
    self.cities = [[NSMutableDictionary alloc] initWithCapacity:0];
}

- (void)pageEvent:(QPageEventType)eventType
{
    if (eventType == kPageEventWillShow)
    {
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(successGetRegion:) name:kGetRegion object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(hotDataFromMessage:) name:kHotCity object:nil];
        [[QHttpMessageManager sharedHttpMessageManager] accessHotCity];
        [ASRequestHUD show];
    }
    else if (eventType == kPageEventWillHide)
    {
        [[NSNotificationCenter defaultCenter] removeObserver:self name:kGetRegion object:nil];
        [[NSNotificationCenter defaultCenter] removeObserver:self name:kHotCity object:nil];
        
        [ASUserDefaults setObject:_visitCitys forKey:CityRecentVisit];
    }
}

- (UIView *)viewWithFrame:(CGRect)frame{
    if ([super viewWithFrame:frame]) {
        
        /*
        UIView *searchView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, frame.size.width, 40)];
        [_view addSubview:searchView];
        */
        
        _cityTableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, frame.size.width, frame.size.height) style:UITableViewStylePlain];
        _cityTableView.tableFooterView = [UIView new];
        _cityTableView.dataSource = self;
        _cityTableView.delegate = self;
        [_view addSubview:_cityTableView];
        
    }
    return _view;
}

#pragma mark - Notification
- (void)hotDataFromMessage:(NSNotification *)noti{
    
    [ASRequestHUD dismiss];
    
    _arrayHotCity = noti.object;
    
    [self filterSectionArray:noti.object];
    //支持的城市
    [self.keys insertObject:@"热" atIndex:0];
    [self.keys insertObject:@"近" atIndex:0];
    [self.keys insertObject:@"当" atIndex:0];
    
    [self getCityData];
    
    [self.cityTableView reloadData];
}

- (void)successGetRegion:(NSNotification*)noti {
    [ASRequestHUD dismiss];
    
    NSArray *arr = noti.object;
    [ASUserDefaults setObject:_selectModel.regionId forKey:CurrentRegionID];
    [ASUserDefaults setObject:_selectModel.regionName forKey:CurrentRegionName];
    [QViewController backPageWithParam:[[NSDictionary alloc] initWithObjectsAndKeys:[NSNumber numberWithBool:YES], @"CityChanged", nil]];
}

- (void)getCityData
{
    _hotArr = [[NSMutableArray alloc] initWithCapacity:0];
    for (QHotCityModel *model in _arrayHotCity) {
        [_hotArr addObject:model.regionName];
    }
    [self.cities setObject:_hotArr forKey:@"热"];
}

#pragma mark - Private

+ (NSString*)getFirstLetter:(NSString*)wenzi
{
    NSString *firstLetter = [[NSString stringWithFormat:@"%c", pinyinFirstLetter([wenzi characterAtIndex:0])] uppercaseString];
    NSUInteger firstLetterIndex = [ALPHA rangeOfString:[firstLetter substringToIndex:1]].location;
    if (firstLetterIndex > 26) {
        firstLetter = nil;
    }
    return firstLetter;
}

- (void)filterSectionArray:(NSArray *)citys
{
    @synchronized(_cities) {
        
        for (QHotCityModel *model in citys)
        {
            NSString *firstLetter = [QCityChange getFirstLetter:model.regionName];
            if (!firstLetter) {
                continue;
            }
            NSMutableArray *letterArr =  [self.cities objectForKey:firstLetter];
            if (!letterArr) {
                letterArr = [[NSMutableArray alloc] initWithCapacity:0];
                [self.keys addObject:firstLetter];
            }
            [letterArr addObject:model];
            [self.cities setObject:letterArr forKey:firstLetter];
        }
        [self.keys sortUsingComparator:^NSComparisonResult(id obj1, id obj2) {
            return [obj1 compare:obj2 options:NSNumericSearch];
        }];
/*
         for (NSString *name in self.keys) {
         NSMutableArray *array = [self.cities objectForKey:name];
         [array sortUsingComparator:^NSComparisonResult(id obj1, id obj2) {
         QHotCityModel *consumer1 = obj1;
         QHotCityModel *consumer2 = obj2;
         return [consumer1.regionName compare:consumer2.regionName options:NSNumericSearch];
         }];
         }
*/
    }
}

- (void)didChangeFromRecentorHot:(NSArray*)cityArray index:(NSInteger)index
{
    if (cityArray.count > index) {
        NSString *name = [cityArray objectAtIndex:index];
        NSString *firstLetter = [QCityChange getFirstLetter:name];
        if (!firstLetter) {
            return;
        }
        QHotCityModel *model = nil;
        NSArray *array = [self.cities objectForKey:firstLetter];
        for (model in array) {
            if ([model.regionName isEqualToString:name]) {
                break;
            }
        }
        //切换城市
        if (model) {
            [self didChangeCity:model];
        }
    }
}

- (NSArray*)cityArraybySectionIndex:(NSUInteger)index
{
    if (self.keys.count <= index) {
        return nil;
    }
    return  [self.cities objectForKey:[self.keys objectAtIndex:index]];
}

- (void)didChangeCity:(QHotCityModel*)currentModel
{
    _selectModel = currentModel;
    /* 定位 */
    _locationCity = currentModel.regionName;
    /* 历史 */
    BOOL isCityExist = NO;
    for (NSString *city in _visitCitys) {
        if ([city isEqualToString:currentModel.regionName]) {
            
            [_visitCitys removeObject:city];
            [_visitCitys insertObject:city atIndex:0];
            isCityExist = YES;
            break;
        }
    }
    if (!isCityExist) {
        [_visitCitys insertObject:[currentModel.regionName copy] atIndex:0];
    }
    if (_visitCitys.count > MaxRecentCityVisit) {
        [_visitCitys removeLastObject];
    }
    
    //获取城市子类
    [[QHttpMessageManager sharedHttpMessageManager] accessGetRegion:[currentModel.regionId stringValue]];
    [ASRequestHUD show];
}

#pragma mark - tableView
-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 30.0;
}

-(UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    UIView *bgView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_SIZE_WIDTH, 30)];
    bgView.backgroundColor = [QTools colorWithRGB:247 :247 :247];
    
    CGFloat titleH = 20;
    UILabel *titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(13, (bgView.deFrameHeight - titleH)/2.0, SCREEN_SIZE_WIDTH, titleH)];
    titleLabel.backgroundColor = [UIColor clearColor];
    titleLabel.textColor = [QTools colorWithRGB:85 :85 :85];
    titleLabel.font = [UIFont systemFontOfSize:16];
    
    NSString *key = [_keys objectAtIndex:section];
    if ([key rangeOfString:@"热"].location != NSNotFound) {
        titleLabel.text = @"热门城市";
    }else if(section == 0){
        titleLabel.text = @"当前城市";
    }else if (section == 1){
        titleLabel.text = @"最近访问城市";
    }else
        titleLabel.text = key;
    
    [bgView addSubview:titleLabel];
    
    return bgView;
}

- (NSArray *)sectionIndexTitlesForTableView:(UITableView *)tableView
{
    return _keys;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return [_keys count];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    NSInteger number = 0;
    if (section < 3) {
        number = 1;
    }
    else{
        NSString *key = [_keys objectAtIndex:section];
        NSArray *citySection = [_cities objectForKey:key];
        number = [citySection count];
    }
    return number;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"City_Identifier";
    static NSString *CellIdentifierspecifical = @"Cell_specifical";
    
    if (indexPath.section < 3) {
        QCityChangeeCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifierspecifical];
        if (nil == cell) {
            cell = [[QCityChangeeCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifierspecifical];
            cell.backgroundColor = [QTools colorWithRGB:240 :239 :237];
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
            cell.delegate = self;
        }
        
        [cell.contentView.subviews makeObjectsPerformSelector:@selector(removeFromSuperview)];
        [cell configureCellForTableView:@[_locationCity] andRecent:_visitCitys andHot:_hotArr andIndexPath:indexPath];
        
        return cell;
    }
    else{
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
        if (cell == nil)
        {
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] ;
            cell.backgroundColor = [QTools colorWithRGB:240 :239 :237];
            cell.contentView.backgroundColor = [UIColor clearColor];
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
            
            [cell.textLabel setTextColor:[UIColor blackColor]];
            cell.textLabel.font = [UIFont systemFontOfSize:14];
            cell.textLabel.textColor = [QTools colorWithRGB:114 :114 :114];
        }
        NSString *key = [_keys objectAtIndex:indexPath.section];
        QHotCityModel *cityModel = (QHotCityModel*)[[_cities objectForKey:key] objectAtIndex:indexPath.row];
        cell.textLabel.text = cityModel.regionName;

        return cell;
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    CGFloat height = 0;
    if (indexPath.section == 1) {
        if (_visitCitys.count == 0) {
            height = 50;
        }
        else if (_visitCitys.count%3 == 1 || _visitCitys.count%3 == 2) {
            height = 30 * (_visitCitys.count/3 + 1) + 20 + (_visitCitys.count/3) * 7;
        }
        else{
            height = 30 * (_visitCitys.count/3) + 20 + ((_visitCitys.count - 1)/3 * 7);
        }
    }
    else if (indexPath.section == 2){
        if (_arrayHotCity.count%3 == 0) {
            height = 30 * (_arrayHotCity.count/3) + 20 + ((_arrayHotCity.count - 1)/3 * 7);
        }
        else{
            height = 30 * (_arrayHotCity.count/3 + 1) + 20 + (_arrayHotCity.count/3) * 7;
        }
    }
    else {
        height = 40 + 10;
    }
    return height;
}

#pragma mark - UITableViewDelegete

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSArray *array = [self cityArraybySectionIndex:indexPath.section];
    if (array.count > indexPath.row && indexPath.section >= 3) {
        [self didChangeCity:[array objectAtIndex:indexPath.row]];
    }
}

#pragma mark - QCityChangeeCellDelegate
- (void)citySelected:(QCityChangeeCell*)cell andCityIndex:(NSUInteger)index
{
    NSIndexPath *indexPath =  [_cityTableView indexPathForCell:cell];
    if (!indexPath) {
        return;
    }
    switch (indexPath.section) {
        case 0:/*定*/
            break;
        case 1:/*近*/
        {
            [self didChangeFromRecentorHot:_visitCitys index:index];
        }
            break;
        case 2:/*热*/
        {
            [self didChangeFromRecentorHot:_hotArr index:index];
        }
            break;
        default:
            break;
    }
}

@end
