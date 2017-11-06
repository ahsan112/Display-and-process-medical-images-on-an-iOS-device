//
//  LineView.m
//  MedViewer
//
//  Created by Ahsan Mirza on 21/02/2017.
//  Copyright © 2017 Ahsan Mirza. All rights reserved.
//

#import "LineView.h"

@interface LineView()

@property (nonatomic) CGPoint                 startPoint;
@property (nonatomic) CGPoint                 endPoint;
@property (nonatomic) CGFloat                 circleRadius;
@property (nonatomic) BOOL                    startPointTracking;
@property (nonatomic) BOOL                    endPointTracking;

@property (nonatomic) NSMutableArray         *lineArray;
@property (nonatomic) BOOL                    remove;
@end

@implementation LineView


- (instancetype)initWithFrame:(CGRect)frame {
    
    self = [super initWithFrame:frame];
    if (self) {
        [self setup];
        self.startPoint = [self randomPointInBounds];
        self.endPoint = [self randomPointInBounds];
        _lineArray = [[NSMutableArray alloc]init];
        [_lineArray addObject:self];
        
        UITapGestureRecognizer *doubleTap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(tap:)];
        doubleTap.numberOfTapsRequired = 2;
        [self addGestureRecognizer:doubleTap];
        [self setNeedsDisplay];
    }
    
    return self;
    
}

- (void)setup
{
    self.backgroundColor = [UIColor clearColor];
    self.multipleTouchEnabled = false; // multi-touch is not allowed
    self.circleRadius = 10.0;
}

- (void)tap:(UIGestureRecognizer*)gr {
    
    NSLog(@"TAPPEd");
    
    [self becomeFirstResponder];
    
    UIMenuController *menu = [UIMenuController sharedMenuController];
    
    UIMenuItem *deleteItem = [[UIMenuItem alloc]initWithTitle:@"Delete"
                                                       action:@selector(removeAll)];
    menu.menuItems = @[deleteItem];
    
    [menu setTargetRect:CGRectMake(_startPoint.x, _endPoint.y, 2, 2) inView:self];
    
    [menu setMenuVisible:YES animated:YES];
    
    [self setNeedsDisplay];
}

- (BOOL)canBecomeFirstResponder {
    return YES;
}

- (void)removeAll {
    
    _remove = true;
    NSLog(@"Tapp Pressed");
    [self setNeedsDisplay];
}

#pragma mark - Touch handling

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    UITouch *touch = [touches anyObject];
    CGPoint location = [touch locationInView:self];
    
    if ([self pointIsOnStartCircle:location]) {
        self.startPointTracking = YES;
        self.endPointTracking = NO;
    } else if ([self pointIsOnEndCircle:location]) {
        self.startPointTracking = NO;
        self.endPointTracking = YES;
    }
    
    [self updatePointsWithTouches:touches];
}

- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event
{
    [self updatePointsWithTouches:touches];
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
    self.startPointTracking = NO;
    self.endPointTracking = NO;
}

- (void)touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event
{
    self.startPointTracking = NO;
    self.endPointTracking = NO;
}

- (void)updatePointsWithTouches:(NSSet *)touches
{
    UITouch *touch = [touches anyObject];
    
    if (self.startPointTracking) {
        self.startPoint = [touch locationInView:self];
        [self setNeedsDisplay];
        
    } else if (self.endPointTracking) {
        self.endPoint = [touch locationInView:self];
        [self setNeedsDisplay];
    }
}

- (BOOL)pointInside:(CGPoint)point withEvent:(nullable UIEvent *)event
{
    return [self pointIsOnStartCircle:point] || [self pointIsOnEndCircle:point];
}

#pragma mark - Drawing

- (void)drawRect:(CGRect)rect
{
    if (_remove == true) {
        CGContextRef context = UIGraphicsGetCurrentContext();
        //CGContextClearRect(context, rect);
        CGContextSetBlendMode(context, kCGBlendModeClear);
        NSLog(@"Should be removed");
        [self setNeedsDisplay];
        
    }
    
    if ([self isHidden]) { return; }
    _context = UIGraphicsGetCurrentContext();
    [self drawTouchCircleAtPoint:self.startPoint];
    [self drawTouchCircleAtPoint:self.endPoint];
    [self drawLineBetweenFirstPoint:self.startPoint end:self.endPoint];
    [self drawDistanceText];
    }

- (void)drawLineBetweenFirstPoint:(CGPoint)startPoint end:(CGPoint)endPoint
{
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSaveGState(context);
    CGContextSetStrokeColorWithColor(context, [[[UIColor greenColor] colorWithAlphaComponent:0.6] CGColor]);
    CGContextSetLineWidth(context, 1.0);
    
    CGContextMoveToPoint(context, startPoint.x, startPoint.y);
    CGContextAddLineToPoint(context, endPoint.x, endPoint.y);
    CGContextStrokePath(context);
    CGContextRestoreGState(context);
    
    
}

- (void)drawTouchCircleAtPoint:(CGPoint)CirclePoint
{
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSaveGState(context);
    CGContextSetLineWidth(context, 2.0);
    CGContextSetRGBFillColor(context, 1.0, 1.0, 1.0, 0.6);
    
    CGContextAddArc(context, CirclePoint.x, CirclePoint.y, self.circleRadius, 30.0,  M_PI * 2, YES);
    CGContextFillPath(context);
    CGContextRestoreGState(context);
}

- (void)drawDistanceText
{
    CGPoint midpoint = [self midpointBetweenFirstPoint:self.startPoint secondPoint:self.endPoint];
    
    UIFont *font = [UIFont boldSystemFontOfSize:18.0];
    UIColor *textColor = [UIColor whiteColor];
    NSDictionary *attributes = @{NSFontAttributeName : font, NSForegroundColorAttributeName : textColor};
    NSString *distanceString = [self formattedDistanceString];
    
    NSAttributedString *attributedString = [[NSAttributedString alloc] initWithString:distanceString attributes:attributes];
    
    [attributedString drawAtPoint:midpoint];
}

#pragma mark - Helper methods

- (CGPoint)randomPointInBounds
{
    int x = arc4random() % (int)CGRectGetWidth(self.bounds);
    int y = arc4random() % (int)CGRectGetHeight(self.bounds);
    return CGPointMake(x, 350);
}

- (CGFloat)distanceFromPoint:(CGPoint)p1 toPoint:(CGPoint)p2
{
    CGFloat xDist = p2.x - p1.x;
    CGFloat yDist = p2.y - p1.y;
    return sqrt((xDist * xDist) + (yDist * yDist));
}

- (CGPoint)midpointBetweenFirstPoint:(CGPoint)p1 secondPoint:(CGPoint)p2
{
    CGFloat x = (p1.x + p2.x) / 2.0;
    CGFloat y = (p1.y + p2.y) / 2.0;
    return CGPointMake(x, y);
}

- (BOOL)pointIsOnStartCircle:(CGPoint)point
{
    CGFloat distance = [self distanceFromPoint:point toPoint:self.startPoint];
    return distance <= self.circleRadius;
}

- (BOOL)pointIsOnEndCircle:(CGPoint)point
{
    CGFloat distance = [self distanceFromPoint:point toPoint:self.endPoint];
    return distance <= self.circleRadius;
}

- (NSString *)formattedDistanceString
{
    CGFloat distance = [self distanceFromPoint:self.startPoint toPoint:self.endPoint];
    CGFloat dd = distance / 200;
    NSNumberFormatter *formatter = [[self class] sharedFormatter];
    return [formatter stringFromNumber:@(distance)];
    //return [formatter stringFromNumber:@(dd)];
}

+ (NSNumberFormatter *)sharedFormatter
{
    static NSNumberFormatter *sharedFormatter = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedFormatter = [[NSNumberFormatter alloc] init];
    });
    return sharedFormatter;
}





@end
