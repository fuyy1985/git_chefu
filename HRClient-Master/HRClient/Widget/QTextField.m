//
//  QTextField.m
//  DSSClient
//
//  Created by panyj on 14-5-30.
//  Copyright (c) 2014年 SDK. All rights reserved.
//

#import "QTextField.h"

@interface QTextField()<UITextFieldDelegate>
@property (nonatomic,weak) id<UITextFieldDelegate> myDelegate;
@end

@implementation QTextField

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        self.delegate = self;
        
        //垂直居中
        self.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
         if ([_T(@"Language") isEqualToString:@"English"])
         {
             self.font = [UIFont systemFontOfSize:14];
         }
    }
    return self;
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

- (void)setDelegate:(id<UITextFieldDelegate>)delegate
{
    if (delegate == self) {
        [super setDelegate:delegate];
    }
    else
    {
        self.myDelegate = delegate;
    }
}


- (id)delegate
{
    return self.myDelegate;
}


- (BOOL)checkValidByRegular:(NSString*)pattern
{
    if (pattern.length == 0) {
        return YES;
    }
    
    NSString * newText   = self.text;    
    if (newText.length == 0)
    {
        newText = @"";
    }
    
    NSRegularExpression  *regExpression = [[NSRegularExpression alloc] initWithPattern:pattern
                                                                               options:NSRegularExpressionCaseInsensitive|NSRegularExpressionAllowCommentsAndWhitespace
                                                                                 error:nil];
    NSRange textRange = NSMakeRange(0, newText.length);
    NSTextCheckingResult * ckResult = [regExpression firstMatchInString:newText
                                                                options:0
                                                                  range:textRange];
    NSRange rangeMatch = ckResult.range;
    return (memcmp(&textRange, &rangeMatch, sizeof(textRange))==0);
}



- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
    if ([_myDelegate respondsToSelector:@selector(textField:shouldChangeCharactersInRange:replacementString:)]) {
        return [_myDelegate textField:self shouldChangeCharactersInRange:range replacementString:string];
    }
    
    NSString  *orgText = textField.text;
    
    NSString * newText   = [orgText stringByReplacingCharactersInRange:range withString:string];
    NSInteger  newLength = newText.length;
    
    if (newLength == 0) {
        return YES;
    }
    
    if (_validLength>0 && newLength > _validLength) {//valid string length
        return NO;
    }
    
    if (self.invalidChars.length) {//valid chars input
        NSCharacterSet *charSet = [NSCharacterSet characterSetWithCharactersInString:self.invalidChars];
        NSRange range = [string rangeOfCharacterFromSet:charSet];
        if (range.length != 0) {
            return NO;
        }
    }
    
    //regular
    if (self.regPattern) {
        NSRegularExpression  *regExpression = [[NSRegularExpression alloc] initWithPattern:_regPattern
                                  options:NSRegularExpressionCaseInsensitive|NSRegularExpressionAllowCommentsAndWhitespace
                                  error:nil];
        
        NSRange textRange = NSMakeRange(0, newText.length);
        NSTextCheckingResult * ckResult = [regExpression firstMatchInString:newText
                                                                    options:0
                                                                    range:textRange];
        NSRange rangeMatch = ckResult.range;
        if (memcmp(&textRange, &rangeMatch, sizeof(textRange))!=0) {
            return NO;
        }
    }
    
    return YES;
}

- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField
{
    BOOL bRet = YES;
    if ([_myDelegate respondsToSelector:@selector(textFieldShouldBeginEditing:)]) {
        bRet = [_myDelegate textFieldShouldBeginEditing:self];
    }
    return bRet;
}// return NO to disallow editing.


- (void)textFieldDidBeginEditing:(UITextField *)textField           // became first responder
{
    if ([_myDelegate respondsToSelector:@selector(textFieldDidBeginEditing:)]) {
        [_myDelegate textFieldDidBeginEditing:self];
    }
}


- (BOOL)textFieldShouldEndEditing:(UITextField *)textField
// return YES to allow editing to stop and to resign first responder status. NO to disallow the editing session to end
{
    BOOL bRet = YES;
    if ([_myDelegate respondsToSelector:@selector(textFieldShouldEndEditing:)]) {
        bRet = [_myDelegate textFieldShouldEndEditing:self];
    }
    return bRet;
}

- (void)textFieldDidEndEditing:(UITextField *)textField             // may be called if forced even if shouldEndEditing returns NO (e.g. view removed from window) or endEditing:YES called
{
    if ([_myDelegate respondsToSelector:@selector(textFieldDidEndEditing:)]) {
        [_myDelegate textFieldDidEndEditing:self];
    }
}


- (BOOL)textFieldShouldClear:(UITextField *)textField               // called when clear button pressed. return NO to ignore (no notifications)
{
    BOOL bRet = YES;
    if ([_myDelegate respondsToSelector:@selector(textFieldShouldClear:)]) {
        bRet = [_myDelegate textFieldShouldClear:self];
    }
    return bRet;
}


- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    BOOL bRet = YES;
    if ([_myDelegate respondsToSelector:@selector(textFieldShouldReturn:)]) {
        bRet = [_myDelegate textFieldShouldReturn:self];
    }
    return bRet;
}

- (BOOL)respondsToSelector:(SEL)aSelector
{
    NSString *sSel = NSStringFromSelector(aSelector);
    if ([@"customOverlayContainer" isEqualToString:sSel]) {
        return NO;
    }
    return [super respondsToSelector:aSelector];
}
@end
