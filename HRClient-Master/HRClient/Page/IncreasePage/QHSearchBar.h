//
//  QHSearchBar.h
//  HRClient
//
//  Created by ekoo on 14/12/31.
//  Copyright (c) 2014年 panyj. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface QHSearchBar : UISearchBar<UISearchBarDelegate>

- (void)changeBarTextFieldWithColor:(UIColor *)color bgImageName:(NSString *)bgImageName;
- (void)changeBarCancelButtonWithColor:(UIColor *)textColor bgImageName:(NSString *)bgImageName;

@end
