//
//  QMyPage.m
//  HRClient
//
//  Created by ekoo on 14/12/15.
//  Copyright (c) 2014年 panyj. All rights reserved.
//

#import "QMyPage.h"
#import "QMyPageCell.h"
#import "QViewController.h"
#import "VPImageCropperViewController.h"
#import <AssetsLibrary/AssetsLibrary.h>
#import <MobileCoreServices/MobileCoreServices.h>
#import "QHttpMessageManager.h"
#import "QLoginModel.h"

#define ORIGINAL_MAX_WIDTH 640.0f

@interface QMyPage () <UINavigationControllerDelegate, UIImagePickerControllerDelegate>
{
    NSArray *imageArr;
    NSArray *titleArr;
    UIImageView *iconImageView;
    QLoginModel *dataArr;//页面的数据
    
    UILabel *nameLabel;
    UILabel *_balanceLabel;
    UILabel *_couponLabel;
}

@property (nonatomic, strong) UIImageView *portraitImageView;

@end

@implementation QMyPage

- (NSString *)title{
    return @"我的";
}

- (UIBarButtonItem *)pageLeftMenu{
    UIButton *editBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    editBtn.backgroundColor = [UIColor clearColor];
    UIBarButtonItem *editItem = [[UIBarButtonItem alloc] initWithCustomView:editBtn];
    return editItem;
}

- (void)pageEvent:(QPageEventType)eventType
{
    if (eventType == kPageEventViewCreate)
    {
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(successUpdateMyAccountInfo:) name:kGetMyAccountInfro object:nil];
        [[QUser sharedQUser] updateUserInfo];
    }
    else if (eventType == kPageEventWillShow)
    {
        nameLabel.text = [ASUserDefaults objectForKey:AccountNick];
        
        NSString *text = [NSString stringWithFormat:@"车夫券(%d)", [[ASUserDefaults objectForKey:AccountTicket] intValue]];
        NSMutableAttributedString *string = [[NSMutableAttributedString alloc] initWithString:text
                                                                                   attributes:@{NSStrikethroughStyleAttributeName:@(NSUnderlineStyleNone)}];
        [string addAttribute:NSForegroundColorAttributeName value:[QTools colorWithRGB:85 :85 :85] range:[text rangeOfString:@"车夫券"]];
        _couponLabel.attributedText = string;
    }
    else if (eventType == kPageEventViewDispose)
    {
        [[NSNotificationCenter defaultCenter] removeObserver:self];
    }
}

- (void)setActiveWithParams:(NSDictionary*)params //NOTE:方便页面激活时接收参数
{
    dataArr = [params objectForKey:@"data"];
}

- (QBottomMenuType)bottomMenuType
{
    return kBottomMenuTypeNormal;
}

- (UIView *)viewWithFrame:(CGRect)frame{
    if ([super viewWithFrame:frame]) {
        _view.backgroundColor = [QTools colorWithRGB:240 :239 :237];
        imageArr = @[@"icon_mine_crash",@"icon_mine_order",@"icon_mine_member"/*,@"icon_mine_comment"*/,@"icon_mine_collect"];
        titleArr = @[@"我的账户",@"我的订单",@"会员中心"/*,@"待评价"*/,@"我的收藏"];
        UIImageView *firstImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, frame.size.width, 110)];
        firstImageView.image = [UIImage imageNamed:@"backgroundmine01.png"];
        firstImageView.userInteractionEnabled = YES;
        [_view addSubview:firstImageView];
        
        CGFloat iconBeforeW = 25;
        CGFloat iconTopH = 15;
        CGFloat iconW = 80;
        CGFloat iconH = 80;
        iconImageView = [[UIImageView alloc] initWithFrame:CGRectMake(iconBeforeW, iconTopH, iconW, iconH)];
        iconImageView.layer.cornerRadius = iconImageView.frame.size.width/2;
        iconImageView.clipsToBounds = YES;
        iconImageView.layer.borderWidth = 3.0f;
        iconImageView.layer.borderColor = [UIColor whiteColor].CGColor;
        UIImage *iconImage =[UIImage imageNamed:@"head.png"];
        iconImageView.image = iconImage;
        iconImageView.userInteractionEnabled = YES;
        [firstImageView addSubview:iconImageView];
        
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(editPortrait)];
        [iconImageView addGestureRecognizer:tap];
        
//      名字
        CGFloat nameTopH = 28;
        CGFloat contentBlank = 10;
        CGFloat nameBeforeW = iconImageView.deFrameRight +contentBlank;
        CGFloat nameW = 140;
        CGFloat nameH = 26;
        nameLabel = [[UILabel alloc] initWithFrame:CGRectMake(nameBeforeW, nameTopH, nameW, nameH)];
        nameLabel.backgroundColor = [UIColor clearColor];
        nameLabel.text = dataArr.nick;
        nameLabel.textColor = [UIColor whiteColor];
        nameLabel.font = [UIFont boldSystemFontOfSize:18];
        [firstImageView addSubview:nameLabel];
                
//      余额
        CGFloat balanceTopH = nameLabel.deFrameBottom + contentBlank - 5;
        CGFloat balanceBeforeW = nameBeforeW;
        CGFloat balanceW = nameW;
        CGFloat balanceH = nameH;
        UILabel *balanceLabel = [[UILabel alloc] initWithFrame:CGRectMake(balanceBeforeW, balanceTopH, balanceW, balanceH)];
        balanceLabel.text = [NSString stringWithFormat:@"账户余额：%.2f元", [[QUser sharedQUser].normalAccount.balance doubleValue]];
        balanceLabel.backgroundColor = [UIColor clearColor];
        balanceLabel.textColor = [UIColor whiteColor];
        balanceLabel.font = [UIFont boldSystemFontOfSize:13];
        [firstImageView addSubview:balanceLabel];
        _balanceLabel = balanceLabel;
        
        CGFloat arrowW = 15;
        CGFloat arrowH = 25;
        CGFloat arrowTop = 43;
        CGFloat arrowBeforeW = frame.size.width - 25 - arrowW;
        UIImageView *arrowImageView = [[UIImageView alloc] initWithFrame:CGRectMake(arrowBeforeW, arrowTop, arrowW, arrowH)];
        arrowImageView.image = [UIImage imageNamed:@"startto01.png"];
        arrowImageView.userInteractionEnabled  = YES;
        [firstImageView addSubview:arrowImageView];
//      添加手势
        UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleTapGesture:)];
        [firstImageView addGestureRecognizer:tapGesture];
        
        UIImageView *buttomImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, firstImageView.deFrameBottom, frame.size.width, frame.size.height - firstImageView.deFrameBottom)];
        buttomImageView.image = [UIImage imageNamed:@"backgroundmine02.png"];
        buttomImageView.userInteractionEnabled = YES;
        [_view addSubview:buttomImageView];
        
        UIView *cardView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, buttomImageView.frame.size.width, 45)];
        cardView.backgroundColor = [UIColor whiteColor];
        [buttomImageView addSubview:cardView];
        
        CGFloat couponBtnW = frame.size.width/2;
        CGFloat couponBtnH = cardView.frame.size.height;
        UIButton *couponBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        couponBtn.frame = CGRectMake(0, 0, couponBtnW, couponBtnH);
        [couponBtn addTarget:self action:@selector(selectCoupon) forControlEvents:UIControlEventTouchUpInside];
        [cardView addSubview:couponBtn];
        
        CGFloat couponW = _view.deFrameWidth/2;
        CGFloat couponH = 25;
        CGFloat couponBeforeW = 0;
        CGFloat couponTopH = 10;
        UILabel *couponLabel = [[UILabel alloc] initWithFrame:CGRectMake(couponBeforeW, couponTopH, couponW, couponH)];
        couponLabel.textAlignment = NSTextAlignmentCenter;
        couponLabel.backgroundColor = [UIColor clearColor];
        couponLabel.textColor = ColorTheme;
        couponLabel.font = [UIFont boldSystemFontOfSize:15];
        couponLabel.userInteractionEnabled = YES;
        [couponBtn addSubview:couponLabel];
        _couponLabel = couponLabel;

        UITapGestureRecognizer *myViptap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(gotoMyNoWarryCard:)];
        [couponLabel addGestureRecognizer:myViptap];
        
        //间隔线
        CGFloat lineW = 0.5;
        CGFloat lineH = cardView.frame.size.height - 10;
        CGFloat lineBeforeW = cardView.frame.size.width/2;
        CGFloat lineTopH = 5;
        UILabel *lineLabel = [[UILabel alloc] initWithFrame:CGRectMake(lineBeforeW, lineTopH, lineW, lineH)];
        lineLabel.backgroundColor = ColorLine;
        [cardView addSubview:lineLabel];
        
        CGFloat VIPw = _view.deFrameWidth/2;
        CGFloat VIPh = 25;
        CGFloat VIPBeforeW = lineLabel.deFrameRight;
        CGFloat VIPTopH = 10;
        UIButton *VIPBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        VIPBtn.frame = CGRectMake(VIPBeforeW, VIPTopH, VIPw, VIPh);
        [VIPBtn setTitle:@"洗车会员卡" forState:UIControlStateNormal];
        [VIPBtn setTitleColor:[QTools colorWithRGB:85 :85 :85] forState:UIControlStateNormal];
        VIPBtn.titleLabel.font = [UIFont boldSystemFontOfSize:15];
        [VIPBtn addTarget:self action:@selector(gotoMyVipCard) forControlEvents:UIControlEventTouchUpInside];
        [cardView addSubview:VIPBtn];
        
        CGFloat buttomTopH = cardView.deFrameBottom + 10;
        CGFloat buttomW = frame.size.width;
        CGFloat buttomH = buttomImageView.frame.size.height - buttomTopH;
        UIView *buttomView = [[UIView alloc] initWithFrame:CGRectMake(0, buttomTopH, buttomW, buttomH)];
        buttomView.backgroundColor = [QTools colorWithRGB:255 :255 :255];
        [buttomImageView addSubview:buttomView];
        
        CGFloat tableH;
        if (SCREEN_SIZE_HEIGHT == 480) {
            tableH = 240;
        }else{
            tableH = 300;
        }
        UITableView *myTableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0,frame.size.width ,buttomView.deFrameHeight) style:UITableViewStylePlain];
        myTableView.separatorStyle = UITableViewCellSeparatorStyleNone;
        myTableView.dataSource = self;
        myTableView.delegate = self;
        if (SCREEN_SIZE_HEIGHT == 480) {
            myTableView.scrollEnabled = YES;
        }else{
            myTableView.scrollEnabled = NO;
        }
        [buttomView addSubview:myTableView];
        
    }
    return _view;
}

#pragma mark - Notification
- (void)successUpdateMyAccountInfo:(NSNotification*)noti
{
    _balanceLabel.text = [NSString stringWithFormat:@"账户余额：%.2f元", [[QUser sharedQUser].normalAccount.balance doubleValue]];
}

#pragma mark - UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return imageArr.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return CellHeight;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    static NSString *myCellID = @"myCell_Identifer";
    QMyPageCell *myCell = [tableView dequeueReusableCellWithIdentifier:myCellID];
    if (myCell == nil) {
        myCell = [[QMyPageCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:myCellID];
        myCell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    }
    [myCell configureModelForCell:imageArr andTitle:titleArr andIndexPath:indexPath];
    return myCell;

}

#pragma mark - UITableViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    if (indexPath.row == 0)
    {
        [QViewController gotoPage:@"QMyAccount" withParam:nil];
    }
    else if (indexPath.row == 1)
    {
        NSString *row = [NSString stringWithFormat:@"%ld",(long)indexPath.row];
        NSDictionary *dic = @{@"page":row};
        [QViewController gotoPage:@"QMyList" withParam:dic];
    }
    else if (indexPath.row == 3)
    {
        [QViewController gotoPage:@"QMyCollect" withParam:nil];
    }
    else if (indexPath.row == 2)
    {
        [QViewController gotoPage:@"QAgreementPage" withParam:[[NSDictionary alloc] initWithObjectsAndKeys:[NSNumber numberWithInt:8], @"agreementType", nil]];
    }
}

- (void)handleTapGesture:(UIGestureRecognizer *)sender{
    [QViewController gotoPage:@"QMyData" withParam:nil];
}

//QMyVIPCard
- (void)gotoMyVipCard
{
    if ([QUser sharedQUser].isVIP) {
        [QViewController gotoPage:@"QMyVIPCard" withParam:nil];
    }else{
        [QViewController gotoPage:@"QNoVipChong" withParam:nil];
    }
}

//QMyNoWarry
- (void)gotoMyNoWarryCard:(UIGestureRecognizer *)sender{
    [QViewController gotoPage:@"QMyNoWarry" withParam:nil];
}

- (void)selectCoupon{
}

- (void)editPortrait {
    UIActionSheet *choiceSheet = [[UIActionSheet alloc] initWithTitle:nil
                                                             delegate:(id<UIActionSheetDelegate>)self
                                                    cancelButtonTitle:@"取消"
                                               destructiveButtonTitle:nil
                                                    otherButtonTitles:@"拍照", @"从相册中选取", nil];
    [choiceSheet showInView:self.view];
}

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
    if (buttonIndex == 0) {
        // 拍照
        if ([self isCameraAvailable] && [self doesCameraSupportTakingPhotos]) {
            UIImagePickerController *controller = [[UIImagePickerController alloc] init];
            controller.sourceType = UIImagePickerControllerSourceTypeCamera;
            if ([self isFrontCameraAvailable]) {
                controller.cameraDevice = UIImagePickerControllerCameraDeviceFront;
            }
            NSMutableArray *mediaTypes = [[NSMutableArray alloc] init];
            [mediaTypes addObject:(__bridge NSString *)kUTTypeImage];
            controller.mediaTypes = mediaTypes;
            controller.delegate = (id<UINavigationControllerDelegate,UIImagePickerControllerDelegate>)self;
            [[QViewController shareController] presentViewController:controller
                               animated:YES
                             completion:^(void){
                                 NSLog(@"Picker View Controller is presented");
                             }];
        }
        
    } else if (buttonIndex == 1) {
        // 从相册中选取
        if ([self isPhotoLibraryAvailable]) {
            UIImagePickerController *picker= [[UIImagePickerController alloc]init];
            picker.delegate = self;
            picker.allowsEditing = YES;
            picker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
            
            [[QViewController shareController] presentViewController:picker animated:YES completion:nil];
        }
    }
}

- (BOOL) isCameraAvailable{
    return [UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera];
}

- (BOOL) isRearCameraAvailable{
    return [UIImagePickerController isCameraDeviceAvailable:UIImagePickerControllerCameraDeviceRear];
}

- (BOOL) isFrontCameraAvailable {
    return [UIImagePickerController isCameraDeviceAvailable:UIImagePickerControllerCameraDeviceFront];
}

- (BOOL) doesCameraSupportTakingPhotos {
    return [self cameraSupportsMedia:(__bridge NSString *)kUTTypeImage sourceType:UIImagePickerControllerSourceTypeCamera];
}

- (BOOL) isPhotoLibraryAvailable{
    return [UIImagePickerController isSourceTypeAvailable:
            UIImagePickerControllerSourceTypePhotoLibrary];
}
- (BOOL) canUserPickVideosFromPhotoLibrary{
    return [self
            cameraSupportsMedia:(__bridge NSString *)kUTTypeMovie sourceType:UIImagePickerControllerSourceTypePhotoLibrary];
}
- (BOOL) canUserPickPhotosFromPhotoLibrary{
    return [self
            cameraSupportsMedia:(__bridge NSString *)kUTTypeImage sourceType:UIImagePickerControllerSourceTypePhotoLibrary];
}

- (BOOL) cameraSupportsMedia:(NSString *)paramMediaType sourceType:(UIImagePickerControllerSourceType)paramSourceType{
    __block BOOL result = NO;
    if ([paramMediaType length] == 0) {
        return NO;
    }
    NSArray *availableMediaTypes = [UIImagePickerController availableMediaTypesForSourceType:paramSourceType];
    [availableMediaTypes enumerateObjectsUsingBlock: ^(id obj, NSUInteger idx, BOOL *stop) {
        NSString *mediaType = (NSString *)obj;
        if ([mediaType isEqualToString:paramMediaType]){
            result = YES;
            *stop= YES;
        }
    }];
    return result;
}


#pragma mark - UINavigationControllerDelegate
- (void)navigationController:(UINavigationController *)navigationController willShowViewController:(UIViewController *)viewController animated:(BOOL)animated {
}

- (void)navigationController:(UINavigationController *)navigationController didShowViewController:(UIViewController *)viewController animated:(BOOL)animated {
}

#pragma mark image scale utility
- (UIImage *)imageByScalingToMaxSize:(UIImage *)sourceImage {
    if (sourceImage.size.width < ORIGINAL_MAX_WIDTH) return sourceImage;
    CGFloat btWidth = 0.0f;
    CGFloat btHeight = 0.0f;
    if (sourceImage.size.width > sourceImage.size.height) {
        btHeight = ORIGINAL_MAX_WIDTH;
        btWidth = sourceImage.size.width * (ORIGINAL_MAX_WIDTH / sourceImage.size.height);
    } else {
        btWidth = ORIGINAL_MAX_WIDTH;
        btHeight = sourceImage.size.height * (ORIGINAL_MAX_WIDTH / sourceImage.size.width);
    }
    CGSize targetSize = CGSizeMake(btWidth, btHeight);
    return [self imageByScalingAndCroppingForSourceImage:sourceImage targetSize:targetSize];
}

- (UIImage *)imageByScalingAndCroppingForSourceImage:(UIImage *)sourceImage targetSize:(CGSize)targetSize {
    UIImage *newImage = nil;
    CGSize imageSize = sourceImage.size;
    CGFloat width = imageSize.width;
    CGFloat height = imageSize.height;
    CGFloat targetWidth = targetSize.width;
    CGFloat targetHeight = targetSize.height;
    CGFloat scaleFactor = 0.0;
    CGFloat scaledWidth = targetWidth;
    CGFloat scaledHeight = targetHeight;
    CGPoint thumbnailPoint = CGPointMake(0.0,0.0);
    if (CGSizeEqualToSize(imageSize, targetSize) == NO)
    {
        CGFloat widthFactor = targetWidth / width;
        CGFloat heightFactor = targetHeight / height;
        
        if (widthFactor > heightFactor)
            scaleFactor = widthFactor; // scale to fit height
        else
            scaleFactor = heightFactor; // scale to fit width
        scaledWidth  = width * scaleFactor;
        scaledHeight = height * scaleFactor;
        
        // center the image
        if (widthFactor > heightFactor)
        {
            thumbnailPoint.y = (targetHeight - scaledHeight) * 0.5;
        }
        else
            if (widthFactor < heightFactor)
            {
                thumbnailPoint.x = (targetWidth - scaledWidth) * 0.5;
            }
    }
    UIGraphicsBeginImageContext(targetSize); // this will crop
    CGRect thumbnailRect = CGRectZero;
    thumbnailRect.origin = thumbnailPoint;
    thumbnailRect.size.width  = scaledWidth;
    thumbnailRect.size.height = scaledHeight;
    
    [sourceImage drawInRect:thumbnailRect];
    
    newImage = UIGraphicsGetImageFromCurrentImageContext();
    if(newImage == nil) NSLog(@"could not scale image");
    
    //pop the context to get back to the default
    UIGraphicsEndImageContext();
    return newImage;
}


#pragma mark - UIImagePickerControllerDelegate
- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info {
    [picker dismissViewControllerAnimated:YES completion:^()
    {
        UIImage *editImage = [info objectForKey:@"UIImagePickerControllerEditedImage"];
        iconImageView.image = editImage;
    }];
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker {
    [picker dismissViewControllerAnimated:YES completion:^(){
    }];
}

- (void)didGetModelFromLogin:(NSNotification *)noti{
    NSLog(@"%@",noti.object);
}


@end
