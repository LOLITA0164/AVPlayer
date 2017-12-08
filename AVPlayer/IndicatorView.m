//
//  IndicatorView.m
//  IndicatorView
//
//  Created by LOLITA on 17/7/4.
//  Copyright © 2017年 LOLITA. All rights reserved.
//

#import "IndicatorView.h"


#define ColorWithRGB(r,g,b) [UIColor colorWithRed:(r)/255.0f green:(g)/255.0f blue:(b)/255.0f alpha:1]
#define ColorWithRGBA(r,g,b,a) [UIColor colorWithRed:(r)/255.0f green:(g)/255.0f blue:(b)/255.0f alpha:(a)]
#define IndicatorDefaultTintColor ColorWithRGB(arc4random_uniform(255), arc4random_uniform(255), arc4random_uniform(255))
#define IndicatorDefaultSize CGSizeMake(40,40)

#define getRandomNumberFromAtoB(A,B) (int)(A+(arc4random()%(B-A+1)))

#if __IPHONE_OS_VERSION_MAX_ALLOWED >= 100000
@interface IndicatorView ()<CAAnimationDelegate>
#else
@interface JQIndicatorView ()
#endif

@property id<IndicatorAnimationProtocol> delegate;
@property IndicatorType type;
@property CGSize size;

@end


@implementation IndicatorView

#pragma mark - 初始化
- (instancetype)initWithType:(IndicatorType)type tintColor:(UIColor *)color size:(CGSize)size{
    if (self = [super init]) {
        self.type = type;
        self.loadingTintColor = color;
        self.size = size;
        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(appDidEnterBackground) name:UIApplicationDidEnterBackgroundNotification object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(appWillBecomeActive) name:UIApplicationWillEnterForegroundNotification object:nil];
    }
    
    return self;
}

-(void)setLoadingTintColor:(UIColor *)loadingTintColor{
    _loadingTintColor = loadingTintColor;
}


- (instancetype)initWithType:(IndicatorType)type{
    return [self initWithType:type tintColor:IndicatorDefaultTintColor];
}

- (instancetype)initWithType:(IndicatorType)type tintColor:(UIColor *)color{
    return [self initWithType:type tintColor:color size:IndicatorDefaultSize];
}


#pragma mark - 动画
- (void)startAnimating{
    
    self.layer.sublayers = nil;
    
    [self setToNormalState];
    
    self.delegate = [self animationForIndicatorType:self.type];
    
    if ([self.delegate respondsToSelector:@selector(configAnimationLayer:withTintColor:size:)]) {
        
        [self.delegate configAnimationLayer:self.layer withTintColor:self.loadingTintColor size:self.size];
        
    }
    
    self.isAnimating = YES;
}

- (void)stopAnimating{
    if (self.isAnimating == YES) {
        if ([self.delegate respondsToSelector:@selector(removeAnimation)]) {
            [self.delegate removeAnimation];
            self.isAnimating = NO;
            self.delegate = nil;
        }
        [self fadeOutWithAnimation:NO];
        [[NSNotificationCenter defaultCenter] removeObserver:self];
    }
}

- (id<IndicatorAnimationProtocol>)animationForIndicatorType:(IndicatorType)type{
    switch (type) {
        case IndicatorTypeBounceSpot1:
            return [IndicatorBounceSpot1Animation new];
        case IndicatorTypeBounceSpot2:
            return [IndicatorBounceSpot2Animation new];
        case IndicatorTypeBounceSpot3:
            return [IndicatorBounceSpot3Animation new];
        case IndicatorTypeCyclingLine:
            return [IndicatorCyclingLineAnimation new];
        case IndicatorTypeCyclingCycle1:
            return [IndicatorCyclingCycle1Animation new];
        case IndicatorTypeCyclingCycle2:
            return [IndicatorCyclingCycle2Animation new];
        case IndicatorTypeMusic1:
            return [IndicatorMusic1Animation new];
        case IndicatorTypeMusic2:
        return [IndicatorMusic2Animation new];
        case IndicatorTypeStock:
            return [IndicatorStockAnimation new];
        default:
            break;
    }
}


#pragma mark - CAAnimation delegate
- (void)animationDidStop:(CAAnimation *)anim finished:(BOOL)flag{
    [self setToFadeOutState];
}


- (void)setToNormalState{
    self.layer.backgroundColor = [UIColor grayColor].CGColor;
    self.layer.speed = 1.0f;
    self.layer.opacity = 1.0;
}


- (void)setToFadeOutState{
    self.layer.backgroundColor = [UIColor clearColor].CGColor;
    self.layer.sublayers = nil;
    self.layer.opacity = 0.f;
}



- (void)fadeOutWithAnimation:(BOOL)animated{
    if (animated) {
        CABasicAnimation *fadeAnimation = [CABasicAnimation animationWithKeyPath:@"opacity"];
        fadeAnimation.delegate = self;
        fadeAnimation.duration = 0.35;
        fadeAnimation.fromValue = @(1);
        fadeAnimation.toValue = @(0);
        [self.layer addAnimation:fadeAnimation forKey:@"fadeOut"];
    }
    else{
        [self setToFadeOutState];
    }
}



- (void)appDidEnterBackground{
    if (self.isAnimating == YES) {
        [self.delegate removeAnimation];
    }
}

- (void)appWillBecomeActive{
    if (self.isAnimating == YES) {
        [self startAnimating];
    }
}





@end










#pragma mark - *********************************************** 动画module ***********************************************







@implementation IndicatorAnimation


-(void)configAnimationLayer:(CALayer*)layer withTintColor:(UIColor*)color size:(CGSize)size
{
    CAReplicatorLayer *replicatorLayer = [CAReplicatorLayer layer];
    replicatorLayer.frame = CGRectMake(0, 0, size.width, size.height);
    replicatorLayer.position = CGPointZero;
    replicatorLayer.backgroundColor = [UIColor clearColor].CGColor;
    [layer addSublayer:replicatorLayer];
}



-(void)removeAnimation{
    [self.itemLayer removeAnimationForKey:@"animation"];
}


@end





#pragma mark - 环形圆点 ************************************************************************

@implementation IndicatorBounceSpot1Animation

-(void)configAnimationLayer:(CALayer *)layer withTintColor:(UIColor *)color size:(CGSize)size{
    
    [super configAnimationLayer:layer withTintColor:color size:size];
    
    for (id la in layer.sublayers) {
        
        if ([la isKindOfClass:[CAReplicatorLayer class]]) {
            
            CAReplicatorLayer *replicatorLayer = la;
            
            [self addCyclingSpotAnimationLayerAtLayer:replicatorLayer withTintColor:color size:size];
            
            NSInteger numOfSpot = 15;
            replicatorLayer.instanceCount = numOfSpot;
            CGFloat angle = (M_PI*2.0)/numOfSpot;   // 角度
            replicatorLayer.instanceTransform = CATransform3DMakeRotation(angle, 0, 0, 1);
            replicatorLayer.instanceDelay = 1.0/numOfSpot;  //  延迟添加
            
        }
    }
    
}


- (void)addCyclingSpotAnimationLayerAtLayer:(CALayer *)layer withTintColor:(UIColor *)color size:(CGSize)size
{
    self.itemLayer = [CALayer layer];
    self.itemLayer.bounds = CGRectMake(0, 0, size.width/6, size.width/6);
    self.itemLayer.position = CGPointMake(size.width/2, 5);
    self.itemLayer.cornerRadius = self.itemLayer.bounds.size.width/2;
    self.itemLayer.backgroundColor = color.CGColor;
    self.itemLayer.transform = CATransform3DMakeScale(0.1, 0.1, 0.1);
    
    [layer addSublayer:self.itemLayer];
    
    self.animation = [CABasicAnimation animationWithKeyPath:@"transform.scale"];
    self.animation.fromValue = @1;
    self.animation.toValue = @0.1;
    self.animation.duration = 0.5;
    self.animation.repeatCount = HUGE_VALF;
    self.animation.removedOnCompletion = NO;
    
    [self.itemLayer addAnimation:self.animation forKey:@"animation"];
    
}





@end





#pragma mark - 线性圆点 ************************************************************************

#define kBounceSpot2AnimationDuration 0.8

@implementation IndicatorBounceSpot2Animation


-(void)configAnimationLayer:(CALayer *)layer withTintColor:(UIColor *)color size:(CGSize)size{
    
    [super configAnimationLayer:layer withTintColor:color size:size];
    
    for (id la in layer.sublayers) {
        
        if ([la isKindOfClass:[CAReplicatorLayer class]]) {
            
            CAReplicatorLayer *replicatorLayer = la;
            
            [self addCyclingSpotAnimationLayerAtLayer:replicatorLayer withTintColor:color size:size];
            
            NSInteger numOfSpot = 4;
            replicatorLayer.instanceCount = numOfSpot;
            replicatorLayer.instanceTransform = CATransform3DMakeTranslation(size.width/5.0, 0, 0);
            replicatorLayer.instanceDelay = kBounceSpot2AnimationDuration/numOfSpot;  //  延迟添加
            
        }
    }
    
}


- (void)addCyclingSpotAnimationLayerAtLayer:(CALayer *)layer withTintColor:(UIColor *)color size:(CGSize)size
{
    CGFloat radius = size.width/5;
    self.itemLayer = [CALayer layer];
    self.itemLayer.bounds = CGRectMake(0, 0, radius, radius);
    self.itemLayer.position = CGPointMake(radius/2.0, size.height/2.0);
    self.itemLayer.cornerRadius = self.itemLayer.bounds.size.width/2.0;
    self.itemLayer.backgroundColor = color.CGColor;
    self.itemLayer.transform = CATransform3DMakeScale(0.2, 0.2, 0.2);
    
    [layer addSublayer:self.itemLayer];
    
    self.animation = [CABasicAnimation animationWithKeyPath:@"transform.scale"];
    self.animation.fromValue = @0.1;
    self.animation.toValue = @1;
    self.animation.duration = kBounceSpot2AnimationDuration;
    self.animation.repeatCount = HUGE_VALF;
    self.animation.autoreverses = YES;
    self.animation.removedOnCompletion = NO;
    
    [self.itemLayer addAnimation:self.animation forKey:@"animation"];
    
}




@end







#pragma mark - 三角运动圆点 ************************************************************************

@implementation IndicatorBounceSpot3Animation


-(void)configAnimationLayer:(CALayer *)layer withTintColor:(UIColor *)color size:(CGSize)size{
    
    [super configAnimationLayer:layer withTintColor:color size:size];
    
    for (id la in layer.sublayers) {
        
        if ([la isKindOfClass:[CAReplicatorLayer class]]) {
            
            CAReplicatorLayer *replicatorLayer = la;
            
            [self addCyclingSpotAnimationLayerAtLayer:replicatorLayer withTintColor:color size:size];
            
            NSInteger numOfSpot = 3;
            replicatorLayer.instanceCount = numOfSpot;
            CGFloat angle = (M_PI*2) / numOfSpot;
            replicatorLayer.instanceTransform = CATransform3DMakeRotation(angle, 0, 0, 1);
            
        }
    }
    
}


- (void)addCyclingSpotAnimationLayerAtLayer:(CALayer *)layer withTintColor:(UIColor *)color size:(CGSize)size
{
    CGFloat radius = size.width/4;
    self.itemLayer = [CALayer layer];
    self.itemLayer.bounds = CGRectMake(0, 0, radius, radius);
    self.itemLayer.position = CGPointMake(size.width/2.0, size.height - radius/2.0);
    self.itemLayer.cornerRadius = self.itemLayer.bounds.size.width/2.0;
    self.itemLayer.backgroundColor = color.CGColor;
    
    [layer addSublayer:self.itemLayer];
    
    CGPoint p0,p1,p2;
    p0 = CGPointMake(size.width/2.0, size.height);
    p1 = CGPointMake(size.width/2.0*(1-cos(M_PI*30/180.0)), size.width/2.0*(1-sin(M_PI*30/180.0)));
    p2 = CGPointMake(size.width/2.0*(1+cos(M_PI*30/180.0)), size.width/2.0*(1-sin(M_PI*30/180.0)));
    
    
    self.animationKey = [CAKeyframeAnimation animationWithKeyPath:@"position"];
    self.animationKey.duration = 1.5;
    self.animationKey.values = @[[NSValue valueWithCGPoint:p0],[NSValue valueWithCGPoint:p1],[NSValue valueWithCGPoint:p2],[NSValue valueWithCGPoint:p0]];
    self.animationKey.timingFunctions = @[
                                  [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut],
                                  [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut],
                                  [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut]
                                  ];
    self.animationKey.repeatCount = HUGE_VALF;
    self.animation.removedOnCompletion = NO;
    
    [self.itemLayer addAnimation:self.animationKey forKey:@"animation"];
    
}




@end












#pragma mark - 虚线圆环 ************************************************************************

@implementation IndicatorCyclingLineAnimation

-(void)configAnimationLayer:(CALayer *)layer withTintColor:(UIColor *)color size:(CGSize)size{
    
    [super configAnimationLayer:layer withTintColor:color size:size];
    
    for (id la in layer.sublayers) {
        
        if ([la isKindOfClass:[CAReplicatorLayer class]]) {
            
            CAReplicatorLayer *replicatorLayer = la;
            
            [self addCyclingLineAnimationLayerAtLayer:replicatorLayer withTintColor:color size:size];
            
            NSInteger numOfSpot = 10;
            replicatorLayer.instanceCount = numOfSpot;
            CGFloat angle = (M_PI *2) / numOfSpot;
            replicatorLayer.instanceTransform = CATransform3DMakeRotation(angle, 0, 0, 1);
            replicatorLayer.instanceDelay = 0.8/numOfSpot;
            
        }
    }
    
}


- (void)addCyclingLineAnimationLayerAtLayer:(CALayer *)layer withTintColor:(UIColor *)color size:(CGSize)size
{
    CGFloat width = 2 * M_PI * size.width / 2.0 / 12;
    self.itemLayer = [CALayer layer];
    self.itemLayer.bounds = CGRectMake(0, 0, width, width/3>3?width/3:3);
    self.itemLayer.position = CGPointMake(size.width/2, 0);
    self.itemLayer.backgroundColor = color.CGColor;
    self.itemLayer.opacity = 0;
    self.itemLayer.cornerRadius = self.itemLayer.bounds.size.height/2.0;
    
    [layer addSublayer:self.itemLayer];
    
    self.animation = [CABasicAnimation animationWithKeyPath:@"opacity"];
    self.animation.fromValue = @1.0;
    self.animation.toValue = @0.0;
    self.animation.duration = 0.8;
    self.animation.repeatCount = HUGE_VALF;
    self.animation.removedOnCompletion = NO;
    
    [self.itemLayer addAnimation:self.animation forKey:@"animation"];
    
}

@end









#pragma mark - 单线圆环 ************************************************************************

@implementation IndicatorCyclingCycle1Animation

-(void)configAnimationLayer:(CALayer *)layer withTintColor:(UIColor *)color size:(CGSize)size{
    
    CAShapeLayer *newItemLayer = [CAShapeLayer layer];
    newItemLayer.frame = CGRectMake(0, 0, size.width, size.height);
    newItemLayer.position = CGPointZero;
    newItemLayer.strokeColor = color.CGColor;
    newItemLayer.fillColor = [UIColor clearColor].CGColor;
    newItemLayer.lineWidth = 2.0;
    
    CGFloat radius = MIN(size.width/2.0, size.height/2.0);
    CGPoint center = CGPointMake(size.width/2.0, size.height/2.0);
    
    UIBezierPath *path = [UIBezierPath bezierPathWithArcCenter:center
                                                        radius:radius
                                                    startAngle:0
                                                      endAngle:M_PI*2*5/6.0
                                                     clockwise:YES];
    
    newItemLayer.path = path.CGPath;
    
    [layer addSublayer:newItemLayer];
    
    self.animation = [CABasicAnimation animationWithKeyPath:@"transform.rotation"];
    self.animation.duration = 0.8;
    self.animation.repeatCount = HUGE_VALF;
    self.animation.fromValue = @0;
    self.animation.toValue = @(M_PI*2.0);
    self.animation.removedOnCompletion = NO;
    [newItemLayer addAnimation:self.animation forKey:@"animation"];
    
}



@end






#pragma mark - 多线圆环 ************************************************************************

@implementation IndicatorCyclingCycle2Animation

-(void)configAnimationLayer:(CALayer *)layer withTintColor:(UIColor *)color size:(CGSize)size{
    
    NSInteger numOfCycle = 2;   // 圆环的个数   可变
    NSInteger numOfArc = 2;     // 内圈圆弧的个数    可变
    
    for (int i = 0; i < numOfCycle; i++) {
        
//        numOfArc = numOfArc + i;
        
        CAReplicatorLayer *replicatorLayer = [self newCAReplicatorLayerWithNumPer:numOfArc size:size];
        [layer addSublayer:replicatorLayer];
        id formValue,toValue;
        if (i%2) {
            formValue = @(0);
            toValue = @(M_PI*2);
        }else{
            formValue = @(M_PI*2);
            toValue = @(0);
        }
        self.animation = [self newCABasicAnimationWithFormValue:formValue toValue:toValue];
        self.animation.removedOnCompletion = NO;
        [replicatorLayer addAnimation:self.animation forKey:@"animation"];
        
        CGFloat perRadius = size.width/2.0 / numOfCycle;
        
        CGFloat radius =  perRadius * (i+1);
        
        CAShapeLayer *newItemLayer = [self newCAShapeLayerWithColor:color];
        
        UIBezierPath *path = [UIBezierPath bezierPathWithArcCenter:CGPointMake(size.width/2.0, size.height/2.0) radius:radius startAngle:0 endAngle:M_PI*2/(numOfArc+1) clockwise:YES];
        newItemLayer.path = path.CGPath;
        [replicatorLayer addSublayer:newItemLayer];
        
    }
    
}


-(CAReplicatorLayer *)newCAReplicatorLayerWithNumPer:(NSInteger)num size:(CGSize)size{
    CAReplicatorLayer *replicatorLayer = [CAReplicatorLayer layer];
    replicatorLayer.frame = CGRectMake(0, 0, size.width, size.height);
    replicatorLayer.position = CGPointZero;
    replicatorLayer.backgroundColor = [UIColor clearColor].CGColor;
    replicatorLayer.instanceCount = num;
    CGFloat angle = (M_PI *2) / num;
    replicatorLayer.instanceTransform = CATransform3DMakeRotation(angle, 0, 0, 1);
    return replicatorLayer;
}

-(CAShapeLayer*)newCAShapeLayerWithColor:(UIColor*)color{
    CAShapeLayer *newItemLayer = [CAShapeLayer layer];
    newItemLayer.position = CGPointZero;
    newItemLayer.strokeColor = color.CGColor;
    newItemLayer.fillColor = [UIColor clearColor].CGColor;
    newItemLayer.lineWidth = 2.0;
    return newItemLayer;
}

-(CABasicAnimation*)newCABasicAnimationWithFormValue:(id)formValue toValue:(id)toValue{
    CABasicAnimation *animation = [CABasicAnimation animationWithKeyPath:@"transform.rotation"];
    animation.duration = 1.0;
    animation.repeatCount = HUGE_VALF;
    animation.fromValue = formValue;
    animation.toValue = toValue;
    animation.removedOnCompletion = NO;
    return animation;
}


@end










#pragma mark - Music1 ************************************************************************

@implementation IndicatorMusic1Animation

-(void)configAnimationLayer:(CALayer *)layer withTintColor:(UIColor *)color size:(CGSize)size{
    
    [super configAnimationLayer:layer withTintColor:color size:size];
    
    for (id la in layer.sublayers) {
        
        if ([la isKindOfClass:[CAReplicatorLayer class]]) {
            
            CAReplicatorLayer *replicatorLayer = la;
            
            [self addMusicBarAnimationLayerAtLayer:replicatorLayer withTintColor:color size:size];
            
            NSInteger numOfSpot = 3;
            replicatorLayer.instanceCount = numOfSpot;
            replicatorLayer.instanceTransform = CATransform3DMakeTranslation(size.width*3/10, 0.f, 0.f);
            replicatorLayer.instanceDelay = 3.0;
            replicatorLayer.instanceDelay = 0.2;
            replicatorLayer.masksToBounds = YES; // 子视图超出的部分切掉
        }
    }
    
}



- (void)addMusicBarAnimationLayerAtLayer:(CALayer *)layer withTintColor:(UIColor *)color size:(CGSize)size{
    CGFloat width = size.width/5;
    CGFloat height = size.height;
    self.itemLayer = [CALayer layer];
    self.itemLayer.bounds = CGRectMake(0, 0, width, height);
    self.itemLayer.position = CGPointMake(size.width/2-width*3/2, size.height + 15);
    self.itemLayer.cornerRadius = 2.0;
    self.itemLayer.backgroundColor = color.CGColor;
    [layer addSublayer:self.itemLayer];
    
    self.animation = [CABasicAnimation animationWithKeyPath:@"position.y"];
    self.animation.toValue = @(self.itemLayer.position.y - self.itemLayer.bounds.size.height/2);
    self.animation.duration = 0.3;
    self.animation.autoreverses = YES;
    self.animation.repeatCount = HUGE_VALF;
    self.animation.delegate = self;
    self.animation.removedOnCompletion = NO;
    
    [self.itemLayer addAnimation:self.animation forKey:@"animation"];
}



@end









#pragma mark - Music2 ************************************************************************

@implementation IndicatorMusic2Animation

-(void)configAnimationLayer:(CALayer *)layer withTintColor:(UIColor *)color size:(CGSize)size{
    
    [super configAnimationLayer:layer withTintColor:color size:size];
    
    for (id la in layer.sublayers) {
        
        if ([la isKindOfClass:[CAReplicatorLayer class]]) {
            
            CAReplicatorLayer *replicatorLayer = la;
            
            [self addMusicBarAnimationLayerAtLayer:replicatorLayer withTintColor:color size:size];
            
            NSInteger numOfSpot = 3;
            replicatorLayer.instanceCount = numOfSpot;
            replicatorLayer.instanceTransform = CATransform3DMakeTranslation(size.width*3/10, 0.f, 0.f);
            replicatorLayer.instanceDelay = 3.0;
            replicatorLayer.instanceDelay = 0.2;
        }
    }
    
}



- (void)addMusicBarAnimationLayerAtLayer:(CALayer *)layer withTintColor:(UIColor *)color size:(CGSize)size{
    CGFloat width = size.width/5;
    CGFloat height = size.height - 10;
    self.itemLayer = [CALayer layer];
    self.itemLayer.bounds = CGRectMake(0, 0, width, height);
    self.itemLayer.position = CGPointMake(size.width/2-width*3/2, size.height/2);
    self.itemLayer.cornerRadius = 2.0;
    self.itemLayer.backgroundColor = color.CGColor;
    [layer addSublayer:self.itemLayer];
    
    self.animation = [CABasicAnimation animationWithKeyPath:@"transform.scale.y"];
    self.animation.fromValue = @1;
    self.animation.toValue = @0.3;
    self.animation.duration = 0.3;
    self.animation.autoreverses = YES;
    self.animation.repeatCount = HUGE_VALF;
    self.animation.removedOnCompletion = NO;
    
    [self.itemLayer addAnimation:self.animation forKey:@"animation"];
}


@end





#pragma mark - 折线类型 ************************************************************************

@interface IndicatorStockAnimation ()


/**
 临时的坐标点数组
 */
@property  NSArray *tmpPoints;

@property CGSize size;
@property UIColor *color;

@property (nonatomic) NSTimer *timer;

@property (strong, nonatomic) CAShapeLayer *la;

@property (strong, nonatomic) CABasicAnimation *animationNew;

@property (strong, nonatomic) CAReplicatorLayer *replicatorLayer;

@end


@implementation IndicatorStockAnimation

-(void)configAnimationLayer:(CALayer *)layer withTintColor:(UIColor *)color size:(CGSize)size{
    
    self.size = size;
    self.color = color;
    
    self.replicatorLayer = [self drawLinesWithSize:size lineNum:4];
    [layer addSublayer:self.replicatorLayer];
    

    self.la.frame = CGRectMake(0, 0, size.width, size.height);
    self.la.position = CGPointZero;
    self.la.strokeColor = color.CGColor;
    [layer addSublayer:self.la];
    
    [self.timer setFireDate:[NSDate date]];
 
    
    
}


// 获取路径
-(CGPathRef)path{
    UIBezierPath *path = [UIBezierPath bezierPath];
    NSArray *points = [self getNewPoints];
    for (int i=0; i<points.count; i++) {
        NSArray *point = points[i];
        if (i==0) {
            [path moveToPoint:CGPointMake(((NSNumber*)point.firstObject).floatValue, ((NSNumber*)point.lastObject).floatValue)];
        }else{
            [path addLineToPoint:CGPointMake(((NSNumber*)point.firstObject).floatValue, ((NSNumber*)point.lastObject).floatValue)];
        }
    }
    path.lineWidth = 1;
    return path.CGPath;
}



// 获取新的坐标数组
-(NSArray *)getNewPoints{
    
    NSMutableArray *tmp = [NSMutableArray array];
    
    NSInteger axis_x_num = 5;   // x轴数据数量
    
    CGFloat per_w = self.size.width / axis_x_num;
    
    for (int i = 0; i<axis_x_num+1; i++) {
        CGFloat y = 0.0;
        if (i==0) {
            y = getRandomNumberFromAtoB((int)self.size.height*8/10, (int)self.size.height*9/10);
        }
        else if (i==axis_x_num){
            y = getRandomNumberFromAtoB((int)self.size.height*1/10, (int)self.size.height*2/10);
        }
        else if (i%2){
            y = getRandomNumberFromAtoB((int)self.size.height*3/10, (int)self.size.height*5/10);
        }
        else{
            y = getRandomNumberFromAtoB((int)self.size.height*5/10, (int)self.size.height*8/10);
        }
        NSArray *point = @[@(i*per_w),@(y)];
        [tmp addObject:point];
    }
    
    return tmp.copy;
}


-(CAReplicatorLayer *)drawLinesWithSize:(CGSize)size lineNum:(NSInteger)lineNum{
    
    CGFloat itemWidth = 10.0;  // 每个元素的宽度
    
    CAReplicatorLayer *lineLayer = [CAReplicatorLayer layer];
    lineLayer.frame = CGRectMake(0, 0, size.width, size.height/lineNum);
    lineLayer.backgroundColor = [UIColor clearColor].CGColor;
    NSInteger itemCount = ceil(size.width/itemWidth);
    lineLayer.instanceCount = itemCount;
    lineLayer.instanceTransform = CATransform3DMakeTranslation(ceil(size.width/itemCount), 0, 0);

    CALayer *layer = [CALayer layer];
    layer.frame = CGRectMake(0, 0, itemWidth/2.0, 0.5);
    layer.position = CGPointMake(itemWidth/2.0, lineLayer.bounds.size.height/2.0);
    layer.backgroundColor = [[UIColor darkGrayColor] colorWithAlphaComponent:0.5].CGColor;
    [lineLayer addSublayer:layer];

    CAReplicatorLayer *axis_y_layer = [CAReplicatorLayer layer];
    axis_y_layer.frame = CGRectMake(0, 0, size.width, size.height);
    axis_y_layer.position = CGPointZero;
    axis_y_layer.backgroundColor = [UIColor clearColor].CGColor;;
    axis_y_layer.instanceCount = lineNum;
    axis_y_layer.instanceTransform = CATransform3DMakeTranslation(0, size.height/lineNum, 0);
    [axis_y_layer addSublayer:lineLayer];
    
    return axis_y_layer;
}





-(void)changePath{
    self.la.path = [self path];
}



-(NSTimer *)timer{
    if (_timer==nil) {
        _timer = [NSTimer scheduledTimerWithTimeInterval:1.0 target:self selector:@selector(changePath) userInfo:nil repeats:YES];
    }
    return _timer;
}



-(CABasicAnimation *)animationNew{
    if (_animationNew==nil) {
        _animationNew = [CABasicAnimation animationWithKeyPath:@"strokeEnd"];
        _animationNew.duration = 1.0;
        _animationNew.repeatCount = HUGE_VALF;
        _animationNew.fromValue = [NSNumber numberWithFloat:0.0];
        _animationNew.toValue = [NSNumber numberWithFloat:1.0];
    }
    return _animationNew;
}

-(CAShapeLayer *)la{
    if (_la==nil) {
        _la = [CAShapeLayer layer];
        _la.backgroundColor = [UIColor clearColor].CGColor;
        _la.path = [self path];
        _la.lineWidth = 2;
        _la.fillColor = [UIColor clearColor].CGColor;
        _la.lineCap = kCALineCapSquare;
        _la.lineJoin = kCALineJoinRound;
        [_la addAnimation:self.animationNew forKey:@"animation"];
    }
    return _la;
}


-(void)removeAnimation{
    [self.la removeAnimationForKey:@"animation"];
    [_timer invalidate];
    _timer = nil;
}



@end















