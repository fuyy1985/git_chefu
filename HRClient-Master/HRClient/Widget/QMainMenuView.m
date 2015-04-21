//
//  QMainMenuView.m
//  DSSClient
//
//  Created by panyj on 14-4-28.
//  Copyright (c) 2014年 SDK. All rights reserved.
//

#import "QMainMenuView.h"
#import "QViewController.h"

@implementation QMainMenu

+ (NSArray*)loadMainMenu
{
    NSMutableArray * allMenus = [[NSMutableArray alloc] initWithCapacity:8];
    
    NSArray * menus = [QConfigration readConfigForKey:@"MainMenu"];
    for (NSDictionary * dicItem in menus) {
        NSString * pageID   = [dicItem objectForKey:@"pageID"];
        NSString * menuIcon = [dicItem objectForKey:@"menuIcon"];
        NSString * menuName = [dicItem objectForKey:@"menuName"];
        
        QMainMenu * newMenu = [[QMainMenu alloc] initWithID:pageID iconImage:menuIcon andName:menuName ofType:0];
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


@interface QMainMenuView()

@property (nonatomic,strong)NSArray * menus;
@property (nonatomic,strong)UITableView *contentTable;

@end

@implementation QMainMenuView

- (id)initWithFrame:(CGRect)frame
{
    if (self = [super initWithFrame:frame])
    {
        self.backgroundColor = [QTools colorWithRGB:239 :239 :244];
        
        self.menus = [QMainMenu loadMainMenu];
        _contentTable = [[UITableView alloc]initWithFrame:CGRectMake(0, 0, frame.size.width, frame.size.height)
                                                    style:UITableViewStylePlain];
        _contentTable.delegate = self;
        _contentTable.dataSource = self;
        _contentTable.backgroundColor = [UIColor clearColor];
        
        [self addSubview:_contentTable];
    }
    return self;
}


- (NSArray*)mainMenu
{
    return self.menus;
}

- (QMainMenu*)menuForID:(NSString*)menuID
{
    for (QMainMenu * menu in self.menus) {
        if ([menu.pageID isEqualToString:menuID]) {
            return menu;
        }
    }
    return nil;
}

- (BOOL)ifMenuStack:(NSArray*)pageStack
{
    for (QMainMenu * menu in self.menus) {
        if(menu.pageStack == pageStack)
        {
            return YES;
        }
    }
    return NO;
}

-(void)setMenuSelectedAtRow:(int)row
{
    if (row < 0 || row > self.menus.count)
    {
        return;
    }
    
    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:0 inSection:0];
    [_contentTable selectRowAtIndexPath:indexPath animated:YES scrollPosition:UITableViewScrollPositionNone];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.menus.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 44;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 30;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    UIView *view = [[UIView alloc]initWithFrame:CGRectMake(0, 0, 320, 30)];
    view.backgroundColor = [QTools colorWithRGB:117 :126 :142];
    UILabel *lbText = [[UILabel alloc]initWithFrame:CGRectMake(15, 0, 200, 30)];
    lbText.textAlignment = NSTextAlignmentLeft;
    lbText.text = _T(@"Menu");
    lbText.textColor = [UIColor whiteColor];
    lbText.backgroundColor = [UIColor clearColor];
    
    [view addSubview:lbText];
    
    return view;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"mainCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (nil == cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault
                                      reuseIdentifier:CellIdentifier];
    }
    

    [cell.contentView.subviews makeObjectsPerformSelector:@selector(removeFromSuperview)];
    cell.selectionStyle = UITableViewCellSelectionStyleGray;
    cell.backgroundColor = [UIColor clearColor];
    
    UIView *view = [[UIView alloc]initWithFrame:cell.bounds];
    view.backgroundColor = [QTools colorWithRGB:215 :216 :224];;
    cell.selectedBackgroundView = view;
    
    // Configure the cell...
    QMainMenu *curMenu = self.menus[indexPath.row];
    
    cell.contentView.backgroundColor = [QTools colorWithRGB:239 :239 :244];
    
    UIImageView *img = [[UIImageView alloc] initWithFrame:CGRectMake(15, 10, 30, 30)];
    img.tag = 99999;
    img.image = IMAGEOF(curMenu.menuImage);
    [cell.contentView addSubview:img];
    
    UILabel *lbText = [[UILabel alloc]initWithFrame:CGRectMake(60,5,150,40)];
    lbText.backgroundColor = [UIColor clearColor];
    lbText.text = _T(curMenu.title);
    lbText.textColor = [QTools colorWithRGB:46 :46 :46];
    [cell.contentView addSubview:lbText];

    return cell;
}

- (BOOL)tableView:(UITableView *)tableView shouldHighlightRowAtIndexPath:(NSIndexPath *)indexPath
{
    return YES;
}

- (void)tableView:(UITableView *)tableView didHighlightRowAtIndexPath:(NSIndexPath *)indexPath
{
    @try
    {
        if (indexPath.row >= self.menus.count)
        {
            return;
        }
        
        QMainMenu *curMenu = self.menus[indexPath.row];
        UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
        UIImageView *imgView = (UIImageView *)[cell viewWithTag:99999];
        if (imgView)
        {
            NSString *strImage = [curMenu.menuImage substringToIndex:[curMenu.menuImage length] - 5];
            strImage = [strImage stringByAppendingString:@"h.png"];
            imgView.image = IMAGEOF(strImage);
        }
    }
    @catch (NSException *exception)
    {
        NSLog(@"Exception:%@", exception);
    }
}

- (void)tableView:(UITableView *)tableView didUnhighlightRowAtIndexPath:(NSIndexPath *)indexPath
{
    @try
    {
        if (indexPath.row >= self.menus.count)
        {
            return;
        }
        
        QMainMenu *curMenu = self.menus[indexPath.row];
        UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
        UIImageView *imgView = (UIImageView *)[cell viewWithTag:99999];
        if (imgView)
        {
            imgView.image = IMAGEOF(curMenu.menuImage);
        }

    }
    @catch (NSException *exception)
    {
         NSLog(@"Exception:%@", exception);
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    QMainMenu *curMenu = self.menus[indexPath.row];
    
    //[tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    if (_delegate) {
        [_delegate mainMenu:self selected:curMenu];
    }
}

@end
