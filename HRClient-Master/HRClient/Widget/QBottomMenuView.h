//
//  QBottomMenuView.h
//  DSSClient
//
//  Created by panyj on 14-4-28.
//  Copyright (c) 2014年 SDK. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "QPage.h"

@interface QBottomMenu : NSObject

@property (nonatomic,readonly) NSString * title;
@property (nonatomic,readonly) NSString * pageID;
@property (nonatomic,readonly) NSString * menuImage;
@property (nonatomic,assign,readonly) NSInteger menuType;

@property (nonatomic,readonly) NSMutableArray * pageStack;//页面缓存

@end


@class QBottomMenuView;

@protocol QBottomMenuDelegate <NSObject>
- (QPage*)mainMenu:(QBottomMenuView*)mainMenu selected:(QBottomMenu*)menu;
@end


@interface QBottomMenuView : UIView

@property (nonatomic,weak) id<QBottomMenuDelegate> delegate;

- (QBottomMenu*)menuForID:(NSString*)menuID;
- (BOOL)ifMenuStack:(NSArray*)pageStack;
- (QPage*)setMenuIndex:(NSInteger)index;
- (NSInteger)menuIndexForID:(NSString*)menuID;

@end
