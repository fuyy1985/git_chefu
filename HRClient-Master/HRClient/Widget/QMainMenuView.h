//
//  QMainMenuView.h
//  DSSClient
//
//  Created by panyj on 14-4-28.
//  Copyright (c) 2014年 SDK. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface QMainMenu : NSObject

@property (nonatomic,readonly) NSString * title;
@property (nonatomic,readonly) NSString * pageID;
@property (nonatomic,readonly) NSString * menuImage;
@property (nonatomic,assign,readonly) NSInteger menuType;
@property (nonatomic,readonly) NSMutableArray * pageStack;//页面缓存
@end


@class QMainMenuView;

@interface QMainMenuDelegate
- (void)mainMenu:(QMainMenuView*)mainMenu selected:(QMainMenu*)menu;
@end


@interface QMainMenuView : UIView<UITableViewDataSource,UITableViewDelegate>
@property (nonatomic,weak) id    delegate;
- (QMainMenu*)menuForID:(NSString*)menuID;
- (BOOL)ifMenuStack:(NSArray*)pageStack;
- (void)setMenuSelectedAtRow:(int)row;

@end
