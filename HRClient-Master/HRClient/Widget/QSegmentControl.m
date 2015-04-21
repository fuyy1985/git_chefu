//
//  QSegmentControl.m
//  Z35465
//
//  Created by panyj on 14-5-17.
//  Copyright (c) 2014年 panyj. All rights reserved.
//

#import "QSegmentControl.h"
@interface QSegmentControl()
@property (nonatomic,strong) NSMutableArray *segments;
@property (nonatomic,assign) BOOL      touched;
@property (nonatomic,strong) UIColor        *tintColor;
@end

@implementation QSegmentControl
@synthesize selectedSegmentIndex = _selectedSegment;

- (instancetype)initWithItems:(NSArray *)items
{
    if ([self initWithFrame:CGRectZero]) {
        [self setItems:items];
    }
    return self;
}


- (instancetype)initWithFrame:(CGRect)frame
{
    if ([super initWithFrame:frame])
    {
        self.tintColor       = [UIColor cyanColor];
        self.backgroundColor = [UIColor clearColor];
    }
    return self;
}

- (void)setItems:(NSArray *)items
{
    _segments = [[NSMutableArray alloc] initWithCapacity:4];
    [self.segments addObjectsFromArray:items];
    if (self.segments.count<2) {//至少要两个
        [self.segments addObject:@""];
    }
}

- (NSArray*)items
{
    return [NSArray arrayWithArray:_segments];
}

- (void)setFrame:(CGRect)frame
{
    frame.size.height = 29.0;
    [super setFrame:frame];
}

- (void)drawRect2:(CGRect)rect
{
    UIImage * imgL = IMAGEOF(@"map_body_lefttab_n.png");
    UIImage * imgLH = IMAGEOF(@"map_body_lefttab_h.png");
    UIImage * imgR = IMAGEOF(@"map_body_righttab_n.png");
    UIImage * imgRH = IMAGEOF(@"map_body_righttab_h.png");
    //backgroud color
    CGRect bounds = self.bounds;
    //draw bounds
    CGFloat itemWidth = bounds.size.width/_segments.count;
    CGFloat itemHeight = bounds.size.height;
    
    
    UIImage * imgDraw = nil;
    for (int i=0; i < _segments.count; ++i) {
        if (i == 0) {
            imgDraw = (_selectedSegment==i)?imgLH:imgL;
        }
        else if(i == [_segments count] -1)
        {
            imgDraw = (_selectedSegment==i)?imgRH:imgR;
        }
        else
        {
            imgDraw = (_selectedSegment==i)?IMAGEOF(@"map_body_middletab_h.png"):IMAGEOF(@"map_body_middletab_n.png");
        }
        [imgDraw drawInRect:CGRectMake(itemWidth*i, 0, itemWidth, itemHeight)];
        
        
        //
        if (i == _selectedSegment) {
            [[UIColor whiteColor] setFill];
        }
        else
        {
            [[self tintColor] setFill];
        }
        //
        UIFont * font = [UIFont systemFontOfSize:14];
        
        NSString * text = _segments[i];
        CGSize szItem = [text sizeWithFont:font];
        
        [text drawAtPoint:CGPointMake(i*itemWidth+(itemWidth-szItem.width)/2,
                                      (itemHeight-szItem.height)/2) withFont:font];
    }
}

- (void)drawRect:(CGRect)rect
{
    [self drawRect2:rect];
    return;
    
    /* Drawing code
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGColorRef   foreColor = self.tintColor.CGColor;
    CGColorRef   backColor = (self.backgroundColor != [UIColor clearColor])?self.backgroundColor.CGColor:[UIColor whiteColor].CGColor;
    
    if (self.backgroundColor == nil) {
       
    }
    //backgroud color
    CGRect bounds = self.bounds;    
    //draw bounds
    CGFloat itemWidth = bounds.size.width/_segments.count;
    CGFloat itemHeight = bounds.size.height;
    
    CGFloat  radius = 4.0;
    
    if (_segments.count < 2 ) {
        return;
    }
    //左侧减去圆角的宽度
    for (int i =0; i<_segments.count; ++i) {
        CGFloat offsetX = itemWidth * i;
        CGMutablePathRef path = CGPathCreateMutable();
        if (i == 0)
        {
            CGPathMoveToPoint(path, nil,radius, itemHeight);
            CGPathAddArcToPoint(path,  nil,0, itemHeight, 0, radius, radius);
            CGPathAddArcToPoint(path,  nil,0, 0, radius, 0, radius);
            CGPathAddLineToPoint(path,  nil,itemWidth, 0);
            CGPathAddLineToPoint(path,  nil,itemWidth, itemHeight);
        }
        else if(i == _segments.count-1)
        {
            CGPathMoveToPoint(path,   nil,itemWidth*i, 0);
            CGPathAddArcToPoint(path,  nil,bounds.size.width, 0, bounds.size.width, itemHeight-radius, radius);
            CGPathAddArcToPoint(path,  nil,bounds.size.width, itemHeight, 0, itemHeight, radius);
            CGPathAddLineToPoint(path,  nil,itemWidth*i, itemHeight);
        }
        else
        {
            CGPathAddRect(path, nil,CGRectMake(i*itemWidth, 0, itemWidth, itemHeight));
        }
        CGPathCloseSubpath(path);
        CGContextAddPath(context, path);
        
        CGColorRef color[2] = {foreColor,backColor};
        CGColorRef colorF   = (i == _selectedSegment)?color[0]:color[1];
        CGColorRef colorS   = (i == _selectedSegment)?color[1]:color[0];
      
        if (_touched && i == _highlightedSegment) {
            colorF = CGColorCreateCopyWithAlpha(colorS, 0.3);
        }
        {
            CGContextSetFillColorWithColor(context, colorF);
            CGContextFillPath(context);
            
            
            CGContextBeginPath(context);
            CGContextAddPath(context, path);
            CGContextSetStrokeColorWithColor(context, colorS);
            CGContextStrokePath(context);
        }
        CGPathRelease(path);
        
        //
        NSString * text = nil;
        UIImage  * img  = nil;
        
        CGSize szItem = CGSizeZero;
        if([_segments[i] isKindOfClass:[NSString class]])
        {
            CGContextSetFillColorWithColor(context, colorS);
            UIFont * font = [UIFont boldSystemFontOfSize:14];
            text = _segments[i];
            szItem = [text sizeWithFont:font];
            [text drawAtPoint:CGPointMake(offsetX+(itemWidth-szItem.width)/2,
                                     (itemHeight-szItem.height)/2) withFont:font];
           
        }
        else if([_segments[i] isKindOfClass:[UIImage class]])
        {
            img = _segments[i];
            szItem = img.size;
            if (szItem.width > itemWidth) {
                szItem.width = itemWidth;
            }
            if (szItem.height>itemHeight) {
                szItem.height = itemHeight;
            }
            
            [img drawAtPoint:CGPointMake(offsetX+(itemWidth-szItem.width)/2, (itemHeight-szItem.height)/2)];
        }        
    }*/
}

#pragma mark -
- (void)setTitle:(NSString *)title forSegmentAtIndex:(NSUInteger)segment
{
    if (segment>=_segments.count) {
        return;
    }
    [_segments replaceObjectAtIndex:segment withObject:title];
    
    [self setNeedsDisplay];
}

- (void)setImage:(UIImage *)image forSegmentAtIndex:(NSUInteger)segment
{
    if (segment>=_segments.count) {
        return;
    }
    [_segments replaceObjectAtIndex:segment withObject:image];
    
    [self setNeedsDisplay];
}

- (void)setSelectedSegmentIndex:(NSInteger)selectedSegmentIndex
{
    _selectedSegment = selectedSegmentIndex;
    
    [self setNeedsDisplay];
}

#pragma mark -
#pragma mark Events

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    if (touches.count>1) {
        return;
    }
    
    _touched = NO;
    
    UITouch * touch = [touches anyObject];
    CGPoint pt = [touch locationInView:self];
    
    CGFloat itemWidth = self.frame.size.width/_segments.count;
    for (int i=0; i<_segments.count; ++i) {
        if (pt.x>0 && pt.x<itemWidth*(i+1)) {
            _highlightedSegment = i;
            break;
        }
    }
    
    if (_highlightedSegment == -1)
    {
        return;
    }
    
    //prevent gesture
    for (UIGestureRecognizer * gest in touch.gestureRecognizers)
    {
        BOOL enabled = gest.enabled;
        gest.enabled = NO;
        gest.enabled = enabled;
    }
    
    [self sendActionsForControlEvents:UIControlEventTouchDown];
    
    if (_highlightedSegment == _selectedSegment)
    {
        return;
    }
    //绘制选中高亮
    _touched = YES;
    [self setNeedsDisplay];
}

- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event
{
    if(!_touched)
    {
        return;
    }
    
    UITouch * touch = [touches anyObject];
    CGPoint pt = [touch locationInView:self];
    
    NSInteger nNowSel = _highlightedSegment;
    CGFloat itemWidth = self.frame.size.width/_segments.count;
    for (int i=0; i<_segments.count; ++i) {
        if (pt.x>0 && pt.x<itemWidth*(i+1)) {
            nNowSel = i;
            break;
        }
    }
    
    if (nNowSel != _highlightedSegment) {
        _touched = NO;
        _highlightedSegment = -1;
        //取消高亮
        [self setNeedsDisplay];
        [self sendActionsForControlEvents:UIControlEventTouchDragExit];
    }
}


- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
    if (_touched) {
        _touched = NO;
        _selectedSegment = _highlightedSegment;
        _highlightedSegment = -1;
        [self setNeedsDisplay];
        
        [self sendActionsForControlEvents:UIControlEventTouchUpInside|UIControlEventValueChanged];
    }
}

- (void)touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event
{
    _touched = NO;
    [self setNeedsDisplay];
}


@end
