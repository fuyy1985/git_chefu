//
//  QPersonalData.m
//  HRClient
//
//  Created by ekoo on 14/12/10.
//  Copyright (c) 2014年 panyj. All rights reserved.
//

#import "QPersonalData.h"

@interface QPersonalData ()
@property (nonatomic,strong)UITableView *personDataTableView;

@end

@implementation QPersonalData

- (NSString *)title{
    return @"个人信息";
}

- (UIView *)viewWithFrame:(CGRect)frame{
    if ([super viewWithFrame:frame]) {
        _view.backgroundColor = [QTools colorWithRGB:240 :239 :237];
        
        UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(0, _personDataTableView.frame.size.height + 30, 60, 40)];
        label.backgroundColor = [UIColor yellowColor];
        _personDataTableView.tableFooterView = label;
        _personDataTableView.backgroundColor = [QTools colorWithRGB:236 :235 :232];
        _personDataTableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, frame.size.width, 190) style:UITableViewStylePlain];
        _personDataTableView.dataSource = self;
        _personDataTableView.delegate = self;
        _personDataTableView.tableFooterView.backgroundColor =[QTools colorWithRGB:236 :235 :232];
        _personDataTableView.tableHeaderView.backgroundColor = [QTools colorWithRGB:236 :235 :232];
//        _personDataTableView.sectionFooterHeight = 10.0;
        [_view addSubview:_personDataTableView];
        
        
        
    }
    return _view;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    switch (section) {
        case 0:
            return 1;
            break;
        case 1:
            return 3;
            break;
        default:
            return 0;
            break;
    }
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 2;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 40;
}
//- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
//    return 10;
//}
//- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section{
//    return 10;
//}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    static NSString *personalData = @"PersonalData";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:personalData];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:personalData];
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    }
    cell.textLabel.text = @"帐号";
    return cell;
}



@end
