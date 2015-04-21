//
//  QTextField.h
//  DSSClient
//
//  Created by panyj on 14-5-30.
//  Copyright (c) 2014年 SDK. All rights reserved.
//

#import <UIKit/UIKit.h>


// textfield designed for valid input characters, if you set the delegate and rewrite
// delegate method, your method will work.don't rewrite 'textField:shouldChangeCharactersInRange:replacementString:' or
// valid method will not work.

@interface QTextField : UITextField
@property (nonatomic,assign) NSInteger            validLength;
@property (nonatomic,strong) NSString             *invalidChars;
@property (nonatomic,strong) NSString             *regPattern;
- (BOOL)checkValidByRegular:(NSString*)pattern;
@end
