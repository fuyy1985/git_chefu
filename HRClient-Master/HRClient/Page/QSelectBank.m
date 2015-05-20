//
//  QSelectBank.m
//  HRClient
//
//  Created by ekoo on 14/12/14.
//  Copyright (c) 2014年 panyj. All rights reserved.
//

#import "QSelectBank.h"
#import "pinyin.h"
#import "AllenProvince.h"

@interface QSelectBank ()

@property (nonatomic,retain)NSDictionary *dataDic;
@property (nonatomic,retain)NSMutableArray *provinces;
@property (nonatomic,retain)NSMutableArray *indexArray;
@property (nonatomic,retain)UITableView *tableView;

@end


@implementation QSelectBank

- (NSString *)title{
    return @"选择银行";
}

- (UIView *)viewWithFrame:(CGRect)frame{
    if ([super viewWithFrame:frame]) {
        
        _view.backgroundColor = [QTools colorWithRGB:240 :239 :237];
        CGFloat segmentBeforeW = 10;
        CGFloat segmentTopH = 10;
        CGFloat segmentW = frame.size.width - 2 * segmentBeforeW;
        CGFloat segmentH = 35;
        NSArray *items = @[@"信用卡",@"储蓄卡"];
        UISegmentedControl *segmentedControl = [[UISegmentedControl alloc] initWithItems:items];
        segmentedControl.frame = CGRectMake(segmentBeforeW, segmentTopH, segmentW, segmentH);
        segmentedControl.tintColor = UIColorFromRGB(0xc40000);
        segmentedControl.selectedSegmentIndex = 0;
//        字体大小
        NSDictionary *attributes = [NSDictionary dictionaryWithObjectsAndKeys:[UIFont boldSystemFontOfSize:16],NSFontAttributeName,[QTools colorWithRGB:181 :0 :7], NSForegroundColorAttributeName, nil];
        [segmentedControl setTitleTextAttributes:attributes forState:UIControlStateNormal];
        [segmentedControl addTarget:self action:@selector(segmentedControl:) forControlEvents:UIControlEventValueChanged];
        [_view addSubview:segmentedControl];
        

        
        
//        -------读取文件
        NSString *plistFilePath = [[NSBundle mainBundle] pathForResource:@"cities" ofType:@"plist"];
        NSDictionary *dic = [NSDictionary dictionaryWithContentsOfFile:plistFilePath];
        self.dataDic = dic;
        NSArray *provincesArr = [self.dataDic objectForKey:@"provinces"];
        _provinces = [[NSMutableArray alloc] initWithCapacity:0];
        for (NSString *name in provincesArr) {
            AllenProvince *province = [AllenProvince provinceWithName:name];
            [self.provinces addObject:province];
        }
        [self.provinces sortUsingComparator:^NSComparisonResult(AllenProvince *obj1, AllenProvince *obj2) {
            return obj1.pinYin >obj2.pinYin;
        }];
        
        _indexArray = [[NSMutableArray alloc] initWithCapacity:0];
        [self handlIndexArray];
        
        UITableView *tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, segmentedControl.deFrameBottom + 10, frame.size.width, frame.size.height - segmentedControl.deFrameBottom) style:UITableViewStylePlain];
        tableView.dataSource = self;
        tableView.delegate = self;
//        tableView.tableHeaderView = headerView;
        tableView.backgroundColor = [UIColor colorWithRed:255/255.0 green:255/255.0 blue:255/255.0 alpha:1.0];
        self.tableView = tableView;
        self.tableView.sectionIndexTrackingBackgroundColor = [QTools colorWithRGB:148 :148 :148];
//        self.tableView.tableHeaderView = headerView;
        [self.view addSubview:self.tableView];
        
    }
    return _view;
}

#pragma mark --点击事件
- (void)segmentedControl:(UISegmentedControl*)segmentedControl{
    NSLog(@"selectedSegmentIndex:%d",segmentedControl.selectedSegmentIndex);
}

- (void)handlIndexArray{
#pragma mark --去重
    NSMutableArray *mutableArr = [[NSMutableArray alloc] initWithCapacity:0];
    char preC = 0;
    for (AllenProvince *province in self.provinces) {
        if (preC != province.pinYin) {
            preC = province.pinYin;
            [mutableArr addObject:[NSString stringWithFormat:@"%c",preC]];
        }
    }
    [mutableArr insertObject:@"#" atIndex:0];
    self.indexArray = mutableArr;
    
}


#pragma mark --UITableViewDataSource
//返回每一个section的行数
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return [self.provinces count];
    
}
//创建并配置cell
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    //    标示符
    NSString *cellID = @"cellID";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellID];
    if (cell == nil) {
        //        创建cell对象
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellID];
    }
    cell.imageView.image = [UIImage imageNamed:@"image.png"];
    AllenProvince *province = [self.provinces objectAtIndex:indexPath.row];
    cell.textLabel.text = province.provinceName;
    
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    return 30;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section{
    //        header
    UIView *headerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_SIZE_WIDTH, 30)];
    [_view addSubview:headerView];
    UILabel *hotLabel = [[UILabel alloc] initWithFrame:CGRectMake(10, 0, SCREEN_SIZE_WIDTH, 30)];
    hotLabel.frame = hotLabel.bounds;
    hotLabel.text = @"  热门";
    hotLabel.backgroundColor = [UIColor clearColor];
    hotLabel.textColor = [QTools colorWithRGB:109 :109 :109];
    [headerView addSubview:hotLabel];
    return headerView;
}




#pragma mark --索引
//下面返回的数组，点击时调到哪一个section是根据数组的索引跳到对应的section
- (NSArray *)sectionIndexTitlesForTableView:(UITableView *)tableView{
    
    return self.indexArray;
}
//重写这个方法，让索引与section关联，这个方法就是索引和section的一个桥梁
- (NSInteger)tableView:(UITableView *)tableView sectionForSectionIndexTitle:(NSString *)title atIndex:(NSInteger)index{
    NSLog(@"title:%@ index:%d --",title,index);
    
    NSInteger i = 0;
    for (AllenProvince *province in self.provinces) {
        //        获取title的第一字符
        char pinYin = [title characterAtIndex:0];
        if (pinYin == province.pinYin) {
            break;
        }
        i++;
    }
    return  i;
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
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}


@end
