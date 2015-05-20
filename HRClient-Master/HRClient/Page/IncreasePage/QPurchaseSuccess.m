//
//  QPurchaseSuccess.m
//  HRClient
//
//  Created by ekoo on 14/12/31.
//  Copyright (c) 2014年 panyj. All rights reserved.
//

#import "QPurchaseSuccess.h"
#import "QPurchaseSuccessCell.h"
#import "QViewController.h"

@interface QPurchaseSuccess (){
    NSArray *infroArr;
}

@end

@implementation QPurchaseSuccess

- (NSString *)title{
    return @"购买成功";
}
- (UIView *)viewWithFrame:(CGRect)frame{
    if ([super viewWithFrame:frame]) {
        infroArr = @[@"名车世家洗车5元代金券",@"2235 6666 8744"];
        
        CGFloat beforeW = 15;
        UIView *footerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_SIZE_WIDTH, 100)];
        UILabel *disPlayLabel = [[UILabel alloc] initWithFrame:CGRectMake(beforeW, beforeW, SCREEN_SIZE_WIDTH - 2 * beforeW, 40)];
        disPlayLabel.backgroundColor = [QTools colorWithRGB:254 :233 :215];
        disPlayLabel.textColor = [QTools colorWithRGB:245 :74 :0];
        disPlayLabel.text = @"您可直接进入我的车夫券，进行体验消费了";
        disPlayLabel.font = [UIFont systemFontOfSize:14];
        disPlayLabel.textAlignment = NSTextAlignmentCenter;
        [footerView addSubview:disPlayLabel];
        
        UIButton *seeBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        seeBtn.frame = CGRectMake(beforeW, disPlayLabel.deFrameBottom + beforeW, (frame.size.width - 3 * beforeW)/2.0, 40);
        seeBtn.backgroundColor = [QTools colorWithRGB:245 :74 :0];
        [seeBtn setTitleColor:[QTools colorWithRGB:255 :255 :255] forState:UIControlStateNormal];
        [seeBtn setTitle:@"查看我的车夫券" forState:UIControlStateNormal];
        seeBtn.layer.masksToBounds = YES;
        seeBtn.layer.cornerRadius = 6.0;
        [seeBtn addTarget:self action:@selector(seeMyNoWorry) forControlEvents:UIControlEventTouchUpInside];
        [footerView addSubview:seeBtn];
        
        UIButton *continueBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        continueBtn.frame = CGRectMake(seeBtn.deFrameRight + beforeW, disPlayLabel.deFrameBottom + beforeW, (frame.size.width - 3 * beforeW)/2.0, 40);
        continueBtn.backgroundColor = UIColorFromRGB(0xc40000);
        [continueBtn setTitleColor:[QTools colorWithRGB:255 :255 :255] forState:UIControlStateNormal];
        [continueBtn setTitle:@"继续购物" forState:UIControlStateNormal];
        continueBtn.layer.masksToBounds = YES;
        continueBtn.layer.cornerRadius = 6.0;
        [continueBtn addTarget:self action:@selector(gotoContinueShop) forControlEvents:UIControlEventTouchUpInside];
        [footerView addSubview:continueBtn];
        
        UITableView *myTableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, frame.size.width, frame.size.height) style:UITableViewStylePlain];
        myTableView.backgroundColor = _view.backgroundColor;
        myTableView.dataSource = self;
        myTableView.delegate = self;
        myTableView.tableFooterView = footerView;
        [_view addSubview:myTableView];
        
    }
    return _view;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return 1;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView;{
    return 2;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section{
    UITableViewHeaderFooterView *headerView = [[UITableViewHeaderFooterView alloc] initWithFrame:CGRectMake(0, 0, tableView.deFrameWidth, 40)];
    headerView.textLabel.font = [UIFont systemFontOfSize:15];
    headerView.contentView.backgroundColor = [UIColor whiteColor];
    if (section == 0) {
        headerView.frame = CGRectZero;
    }else if (section == 1) {
        UILabel *nameLabel = [[UILabel alloc] initWithFrame:CGRectMake(10, 0, headerView.deFrameWidth, headerView.deFrameHeight)];
        nameLabel.text = @"车夫券";
        nameLabel.backgroundColor = [UIColor clearColor];
        [headerView addSubview:nameLabel];
    }
    return headerView;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    if (section == 1) {
        return 40;
    }else{
        return 0.5;
    }
}
- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section{
    return 0.5;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    static NSString *successID = @"success_Identifier";
    QPurchaseSuccessCell *successCell = [tableView dequeueReusableCellWithIdentifier:successID];
    if (successCell == nil) {
        successCell  = [[QPurchaseSuccessCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:successID];
    }
    successCell.userInteractionEnabled = NO;
    [successCell configureCellToModel:infroArr andPath:indexPath];
    return successCell;
    
}

- (void)seeMyNoWorry{
    [QViewController gotoPage:@"QMyNoWarry" withParam:nil];
}

- (void)gotoContinueShop{
    [QViewController gotoPage:@"" withParam:nil];
}

@end
