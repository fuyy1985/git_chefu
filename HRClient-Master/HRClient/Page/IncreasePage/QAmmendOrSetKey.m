//
//  QAmmendOrSetKey.m
//  HRClient
//
//  Created by ekoo on 14/12/24.
//  Copyright (c) 2014年 panyj. All rights reserved.
//

#import "QAmmendOrSetKey.h"
#import "QViewController.h"

@implementation QAmmendOrSetKey

- (NSString *)title{
    return @"支付密码";
}

- (UIView *)viewWithFrame:(CGRect)frame{
    if ([super viewWithFrame:frame]) {
        _view.backgroundColor = [QTools colorWithRGB:240 :239 :237];
        UITableView *payTableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 15, frame.size.width, 99) style:UITableViewStylePlain];
        payTableView.backgroundColor = [QTools colorWithRGB:240 :239 :237];
        payTableView.dataSource = self;
        payTableView.delegate = self;
        [_view addSubview:payTableView];
    }
    return _view;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return 2;

}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 41;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    static NSString *payID = @"pay_ID";
    UITableViewCell *payCell = [tableView dequeueReusableCellWithIdentifier:payID];
    if (payCell == nil) {
        payCell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:payID];
        payCell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        payCell.textLabel.textColor = ColorDarkGray;
        payCell.textLabel.font = [UIFont systemFontOfSize:14];
    }
    if (indexPath.row == 0) {
        payCell.textLabel.text = @"修改支付密码";
    }else if (indexPath.row == 1){
        payCell.textLabel.text = @"找回支付密码";
    }
    return payCell;

}

#pragma mark - UITableViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    if (indexPath.row == 0) {
        [QViewController gotoPage:@"QAmendPayKey" withParam:nil];
    }else if (indexPath.row == 1){
        [QViewController gotoPage:@"QFindPayKey" withParam:nil];
    }
}


@end
