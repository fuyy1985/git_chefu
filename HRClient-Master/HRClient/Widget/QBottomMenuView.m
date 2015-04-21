//
//  QBottomMenuView.m
//  DSSClient
//
//  Created by panyj on 14-4-28.
//  Copyright (c) 2014年 SDK. All rights reserved.
//

#import "QBottomMenuView.h"
#import "QViewController.h"
#import "QUser.h"
#import "QPage.h"

@implementation QBottomMenu

+ (NSArray*)loadMainMenu
{
    NSMutableArray * allMenus = [[NSMutableArray alloc] initWithCapacity:8];
    
    NSArray * menus = [QConfigration readConfigForKey:@"BottomMenu"];
    for (NSDictionary * dicItem in menus) {
        NSString * pageID   = [dicItem objectForKey:@"pageID"];
        NSString * menuIcon = [dicItem objectForKey:@"menuIcon"];
        NSString * menuName = [dicItem objectForKey:@"menuName"];
        
        QBottomMenu * newMenu = [[QBottomMenu alloc] initWithID:pageID iconImage:menuIcon andName:menuName ofType:0];
        [allMenus addObject:newMenu];
    }
    return allMenus;
}

- (id)initWithID:(NSString*)pageID iconImage:(NSString*)icon andName:(NSString*)name ofType:(NSInteger)type
{
    if (self = [super init]) {
        _title     = name;
        _pageID    = pageID;
        _menuImage = icon;
        _menuType  = type;
        
        _pageStack = [[NSMutableArray alloc] initWithCapacity:8];
    }
    return self;
}

@end

@interface QBottomMenuView()
@property (nonatomic,strong)NSArray *menus;
@property (nonatomic,strong)NSArray *buttons;
@property (nonatomic,assign)NSInteger curIndex;
@end

@implementation QBottomMenuView

#define tagBtn  ((NSInteger)10000)

- (id)initWithFrame:(CGRect)frame
{
    if (self = [super initWithFrame:frame])
    {
        self.backgroundColor = [UIColor whiteColor];
        UIView *lineView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, frame.size.width, 0.5f)];
        lineView.backgroundColor = ColorLine;
        [self addSubview:lineView];
        
        self.menus = [QBottomMenu loadMainMenu];
        NSUInteger iCount = self.menus.count;
        
        float fWidth = frame.size.width / iCount;
        float fHeight = 44;
        
        NSMutableArray *arrs = [[NSMutableArray alloc] initWithCapacity:0];
        for (NSInteger i = 0; i < iCount; i++)
        {
            UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
            btn.tag = tagBtn + i;
            btn.frame = CGRectMake(fWidth * i, 1, fWidth, fHeight);
            [self addSubview:btn];
            
            //image
            QBottomMenu *curMenu = self.menus[i];
            UIImage *nImage = IMAGEOF(curMenu.menuImage);
            NSString *strImage = [curMenu.menuImage substringToIndex:[curMenu.menuImage length] - 4];
            strImage = [strImage stringByAppendingString:@"_h.png"];
            UIImage *hImage = IMAGEOF(strImage);
            [btn setImage:nImage forState:UIControlStateNormal];
            [btn setImage:hImage forState:UIControlStateSelected];
            [btn setImage:hImage forState:UIControlStateHighlighted];

            //初始化状态
            if (i == 0)
                btn.selected = YES;
            
            //target
            [btn addTarget:self action:@selector(btnAction:) forControlEvents:UIControlEventTouchUpInside];
            [arrs addObject:btn];
        }
        
        self.curIndex = 0xff;
        self.buttons = arrs;
    }
    return self;
}

- (void)btnAction:(id)sender
{
    UIButton *btn = (UIButton*)sender;
    NSInteger index = btn.tag - tagBtn;
    
    //未登录情况
    if (index == 2) {
        if ([QUser sharedQUser].isLogin == NO) {
            [QViewController gotoPage:@"QAccountLogin" withParam:[[NSDictionary alloc] initWithObjectsAndKeys:@"QMyPage", @"NextPage", nil]];
            return;
        }
    }
    
    [self setMenuIndex:index];
    self.curIndex = index;
}

- (NSArray*)mainMenu
{
    return self.menus;
}

- (QBottomMenu*)menuForID:(NSString*)menuID
{
    for (QBottomMenu * menu in self.menus) {
        if ([menu.pageID isEqualToString:menuID]) {
            return menu;
        }
    }
    return nil;
}

- (NSInteger)menuIndexForID:(NSString*)menuID
{
    for (QBottomMenu * menu in self.menus) {
        if ([menu.pageID isEqualToString:menuID]) {
            return [self.menus indexOfObject:menu];
        }
    }
    return 0;
}

- (BOOL)ifMenuStack:(NSArray*)pageStack
{
    for (QBottomMenu * menu in self.menus) {
        if(menu.pageStack == pageStack)
        {
            return YES;
        }
    }
    return NO;
}

- (QPage*)setMenuIndex:(NSInteger)index
{
    QPage *page = nil;
    
    if (index < 0 || index > self.menus.count)
    {
        return page;
    }
    
    if (index == self.curIndex) return page;
    self.curIndex = index;

    for (NSInteger i = 0; i < 4; i++)
    {
        UIButton *btn = (UIButton*)[self viewWithTag:tagBtn + i];
        btn.selected = (index == i)?YES:NO;
    }
    
    QBottomMenu *menu = self.menus[index];
    if (_delegate)
    {
        page = [_delegate mainMenu:self selected:menu];
    }
    return page;
}

@end
