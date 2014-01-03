//
//  SGActionMenu.m
//  SGActionView
//
//  Created by Sagi on 13-9-3.
//  Copyright (c) 2013年 AzureLab. All rights reserved.
//

#import "SGActionView.h"
#import "SGAlertMenu.h"
#import "SGSheetMenu.h"
#import "SGGridMenu.h"
#import <QuartzCore/QuartzCore.h>


@interface SGActionView () <UIGestureRecognizerDelegate>
@property (nonatomic, strong) NSMutableArray *menus;
@property (nonatomic, strong) CAAnimation *showMenuAnimation;
@property (nonatomic, strong) CAAnimation *dismissMenuAnimation;
@property (nonatomic, strong) CAAnimation *dimingAnimation;
@property (nonatomic, strong) CAAnimation *lightingAnimation;
// 点击背景取消
@property (nonatomic, strong) UITapGestureRecognizer *tapGesture;
@end

@implementation SGActionView

+ (SGActionView *)sharedActionView
{
    static SGActionView *actionView = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        CGRect rect = [[UIScreen mainScreen] bounds];
        actionView = [[SGActionView alloc] initWithFrame:rect];
    });
    
    return actionView;
}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        _menus = [NSMutableArray array];
        
        _tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapAction:)];
        _tapGesture.delegate = self;
        [self addGestureRecognizer:_tapGesture];
    }
    return self;
}

- (void)dealloc{
    [self removeGestureRecognizer:_tapGesture];
}

- (void)tapAction:(UITapGestureRecognizer *)tapGesture{
    CGPoint touchPoint = [tapGesture locationInView:self];
//    if (self.menus.count > 1) {
//        SGBaseMenu *menu = self.menus.lastObject;
//        if (!CGRectContainsPoint(menu.frame, touchPoint)) {
//            [menu removeFromSuperview];
//            [self.menus removeLastObject];
//        }
//    }else{
    SGBaseMenu *menu = self.menus.lastObject;
    if (!CGRectContainsPoint(menu.frame, touchPoint)) {
        [[SGActionView sharedActionView] dismissMenu:menu Animated:YES];
        [self.menus removeObject:menu];
    }
//    }
}

- (BOOL)gestureRecognizerShouldBegin:(UIGestureRecognizer *)gestureRecognizer{
    if ([gestureRecognizer isEqual:self.tapGesture]) {
        CGPoint p = [gestureRecognizer locationInView:self];
        SGBaseMenu *topMenu = self.menus.lastObject;
        if (CGRectContainsPoint(topMenu.frame, p)) {
            return NO;
        }
    }
    return YES;
}

#pragma mark -

- (void)setMenu:(UIView *)menu animation:(BOOL)animated{
    if (![self superview]) {
        UIWindow *window = [[UIApplication sharedApplication] keyWindow];
        [window addSubview:self];
    }
    
    SGBaseMenu *topMenu = (SGBaseMenu *)menu;
    
    [self.menus makeObjectsPerformSelector:@selector(removeFromSuperview)];
    [self.menus addObject:topMenu];
    
    topMenu.style = self.style;
    [self addSubview:topMenu];
    [topMenu layoutIfNeeded];
    topMenu.frame = (CGRect){CGPointMake(0, self.bounds.size.height - topMenu.bounds.size.height), topMenu.bounds.size};
    
    if (animated && self.menus.count == 1) {
        [CATransaction begin];
        [CATransaction setAnimationDuration:0.2];
        [CATransaction setAnimationTimingFunction:[CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseOut]];
        [self.layer addAnimation:self.dimingAnimation forKey:@"diming"];
        [topMenu.layer addAnimation:self.showMenuAnimation forKey:@"showMenu"];
        [CATransaction commit];
    }
}

- (void)dismissMenu:(SGBaseMenu *)menu Animated:(BOOL)animated
{
    if ([self superview]) {
        [self.menus removeObject:menu];
        if (animated && self.menus.count == 0) {
            [CATransaction begin];
            [CATransaction setAnimationDuration:0.2];
            [CATransaction setAnimationTimingFunction:[CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseIn]];
            [CATransaction setCompletionBlock:^{
                [self removeFromSuperview];
                [menu removeFromSuperview];
            }];
            [self.layer addAnimation:self.lightingAnimation forKey:@"lighting"];
            [menu.layer addAnimation:self.dismissMenuAnimation forKey:@"dismissMenu"];
            [CATransaction commit];
        }else{
            [menu removeFromSuperview];

            SGBaseMenu *topMenu = self.menus.lastObject;
            topMenu.style = self.style;
            [self addSubview:topMenu];
            [topMenu layoutIfNeeded];
            topMenu.frame = (CGRect){CGPointMake(0, self.bounds.size.height - topMenu.bounds.size.height), topMenu.bounds.size};
        }
    }
}

#pragma mark -

- (CAAnimation *)dimingAnimation
{
    if (_dimingAnimation == nil) {
        CABasicAnimation *opacityAnimation = [CABasicAnimation animationWithKeyPath:@"backgroundColor"];
        opacityAnimation.fromValue = (id)[[UIColor colorWithWhite:0.0 alpha:0.0] CGColor];
        opacityAnimation.toValue = (id)[[UIColor colorWithWhite:0.0 alpha:0.4] CGColor];
        [opacityAnimation setRemovedOnCompletion:NO];
        [opacityAnimation setFillMode:kCAFillModeBoth];
        _dimingAnimation = opacityAnimation;
    }
    return _dimingAnimation;
}

- (CAAnimation *)lightingAnimation
{
    if (_lightingAnimation == nil ) {
        CABasicAnimation *opacityAnimation = [CABasicAnimation animationWithKeyPath:@"backgroundColor"];
        opacityAnimation.fromValue = (id)[[UIColor colorWithWhite:0.0 alpha:0.4] CGColor];
        opacityAnimation.toValue = (id)[[UIColor colorWithWhite:0.0 alpha:0.0] CGColor];
        [opacityAnimation setRemovedOnCompletion:NO];
        [opacityAnimation setFillMode:kCAFillModeBoth];
        _lightingAnimation = opacityAnimation;
    }
    return _lightingAnimation;
}

- (CAAnimation *)showMenuAnimation
{
    if (_showMenuAnimation == nil) {
        CABasicAnimation *rotateAnimation = [CABasicAnimation animationWithKeyPath:@"transform"];
        CATransform3D t = CATransform3DIdentity;
        t.m34 = 1 / -500.0f;
        CATransform3D from = CATransform3DRotate(t, -30.0f * M_PI / 180.0f, 1, 0, 0);
        CATransform3D to = CATransform3DIdentity;
        [rotateAnimation setFromValue:[NSValue valueWithCATransform3D:from]];
        [rotateAnimation setToValue:[NSValue valueWithCATransform3D:to]];
        
        CABasicAnimation *scaleAnimation = [CABasicAnimation animationWithKeyPath:@"transform.scale"];
        [scaleAnimation setFromValue:@0.9];
        [scaleAnimation setToValue:@1.0];
        
        CABasicAnimation *positionAnimation = [CABasicAnimation animationWithKeyPath:@"transform.translation.y"];
        [positionAnimation setFromValue:[NSNumber numberWithFloat:50.0]];
        [positionAnimation setToValue:[NSNumber numberWithFloat:0.0]];
        
        CABasicAnimation *opacityAnimation = [CABasicAnimation animationWithKeyPath:@"opacity"];
        [opacityAnimation setFromValue:@0.0];
        [opacityAnimation setToValue:@1.0];
        
        CAAnimationGroup *group = [CAAnimationGroup animation];
        [group setAnimations:@[rotateAnimation, scaleAnimation, opacityAnimation, positionAnimation]];
        [group setRemovedOnCompletion:NO];
        [group setFillMode:kCAFillModeBoth];
        _showMenuAnimation = group;
    }
    return _showMenuAnimation;
}

- (CAAnimation *)dismissMenuAnimation
{
    if (_dismissMenuAnimation == nil) {
        CABasicAnimation *rotateAnimation = [CABasicAnimation animationWithKeyPath:@"transform"];
        CATransform3D t = CATransform3DIdentity;
        t.m34 = 1 / -500.0f;
        CATransform3D from = CATransform3DIdentity;
        CATransform3D to = CATransform3DRotate(t, -30.0f * M_PI / 180.0f, 1, 0, 0);
        [rotateAnimation setFromValue:[NSValue valueWithCATransform3D:from]];
        [rotateAnimation setToValue:[NSValue valueWithCATransform3D:to]];
        
        CABasicAnimation *scaleAnimation = [CABasicAnimation animationWithKeyPath:@"transform.scale"];
        [scaleAnimation setFromValue:@1.0];
        [scaleAnimation setToValue:@0.9];
        
        CABasicAnimation *positionAnimation = [CABasicAnimation animationWithKeyPath:@"transform.translation.y"];
        [positionAnimation setFromValue:[NSNumber numberWithFloat:0.0]];
        [positionAnimation setToValue:[NSNumber numberWithFloat:50.0]];
        
        CABasicAnimation *opacityAnimation = [CABasicAnimation animationWithKeyPath:@"opacity"];
        [opacityAnimation setFromValue:@1.0];
        [opacityAnimation setToValue:@0.0];
        
        CAAnimationGroup *group = [CAAnimationGroup animation];
        [group setAnimations:@[rotateAnimation, scaleAnimation, opacityAnimation, positionAnimation]];
        [group setRemovedOnCompletion:NO];
        [group setFillMode:kCAFillModeBoth];
        _dismissMenuAnimation = group;
    }
    return _dismissMenuAnimation;
}

#pragma mark -

+ (void)showAlertWithTitle:(NSString *)title
                   message:(NSString *)message
               buttonTitle:(NSString *)buttonTitle
            selectedHandle:(SGMenuActionHandler)handler{
    SGAlertMenu *menu = [[SGAlertMenu alloc] initWithTitle:title
                                                   message:message
                                              buttonTitles:buttonTitle, nil];
    [menu triggerSelectedAction:^(NSInteger index){
        [[SGActionView sharedActionView] dismissMenu:menu Animated:YES];
        if (handler) {
            handler(index);
        }
    }];
    [[SGActionView sharedActionView] setMenu:menu animation:YES];
}

+ (void)showAlertWithTitle:(NSString *)title
                   message:(NSString *)message
           leftButtonTitle:(NSString *)leftTitle
          rightButtonTitle:(NSString *)rightTitle
            selectedHandle:(SGMenuActionHandler)handler{
    SGAlertMenu *menu = [[SGAlertMenu alloc] initWithTitle:title
                                                   message:message
                                              buttonTitles:leftTitle, rightTitle, nil];
    [menu triggerSelectedAction:^(NSInteger index){
        [[SGActionView sharedActionView] dismissMenu:menu Animated:YES];
        if (handler) {
            handler(index);
        }
    }];
    [[SGActionView sharedActionView] setMenu:menu animation:YES];
}

+ (void)showSheetWithTitle:(NSString *)title
                itemTitles:(NSArray *)itemTitles
             selectedIndex:(NSInteger)selectedIndex
            selectedHandle:(SGMenuActionHandler)handler{
    SGSheetMenu *menu = [[SGSheetMenu alloc] initWithTitle:title
                                                itemTitles:itemTitles];
    menu.selectedItemIndex = selectedIndex;
    [menu triggerSelectedAction:^(NSInteger index){
        [[SGActionView sharedActionView] dismissMenu:menu Animated:YES];
        if (handler) {
            handler(index);
        }
    }];
    [[SGActionView sharedActionView] setMenu:menu animation:YES];
}

+ (void)showSheetWithTitle:(NSString *)title
                itemTitles:(NSArray *)itemTitles
             itemSubTitles:(NSArray *)itemSubTitles
             selectedIndex:(NSInteger)selectedIndex
            selectedHandle:(SGMenuActionHandler)handler{
    SGSheetMenu *menu = [[SGSheetMenu alloc] initWithTitle:title
                                                itemTitles:itemTitles
                                                 subTitles:itemSubTitles];
    menu.selectedItemIndex = selectedIndex;
    [menu triggerSelectedAction:^(NSInteger index){
        [[SGActionView sharedActionView] dismissMenu:menu Animated:YES];
        if (handler) {
            handler(index);
        }
    }];
    [[SGActionView sharedActionView] setMenu:menu animation:YES];
}

+ (void)showGridMenuWithTitle:(NSString *)title
                   itemTitles:(NSArray *)itemTitles
                       images:(NSArray *)images
               selectedHandle:(SGMenuActionHandler)handler{
    SGGridMenu *menu = [[SGGridMenu alloc] initWithTitle:title
                                              itemTitles:itemTitles
                                                  images:images];
    [menu triggerSelectedAction:^(NSInteger index){
        [[SGActionView sharedActionView] dismissMenu:menu Animated:YES];
        if (handler) {
            handler(index);
        }
    }];
    [[SGActionView sharedActionView] setMenu:menu animation:YES];
}

@end
