//
//  SGAlertMenu.m
//  SGActionView
//
//  Created by Sagi on 13-9-4.
//  Copyright (c) 2013年 AzureLab. All rights reserved.
//

#import <QuartzCore/QuartzCore.h>
#import "SGAlertMenu.h"

#define kMAX_ALERT_MESSAGE_HEIGHT   300

@interface SGAlertMenu ()
@property (nonatomic, strong) UILabel *titleLabel;
@property (nonatomic, strong) UILabel *messageLabel;
@property (nonatomic, strong) NSMutableArray *actionButtons;
@property (nonatomic, strong) SGMenuActionHandler actionHandle;
@end

@implementation SGAlertMenu

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        _titleLabel = nil;
        _messageLabel = nil;
        _actionButtons = [NSMutableArray array];
    }
    return self;
}

- (id)initWithTitle:(NSString *)title message:(NSString *)message buttonTitles:(NSString *)buttonTitles, ...
{
    self = [self initWithFrame:[[UIScreen mainScreen] bounds]];
    
    if (self) {
        NSMutableArray *actionButtonTitles = [NSMutableArray array];
        if (buttonTitles) {
            [actionButtonTitles addObject:buttonTitles];
            id eachObj;
            va_list argumentList;
            va_start(argumentList, buttonTitles);
            while ((eachObj = va_arg(argumentList, id))) {
                [actionButtonTitles addObject:eachObj];
            }
            va_end(argumentList);
        }
        if (actionButtonTitles.count > 2) {
            [actionButtonTitles removeObjectsInRange:NSMakeRange(2, actionButtonTitles.count)];
        }
        [self setupWithTitle:title message:message actionTitles:actionButtonTitles];
    }
    return self;
}

- (void)setupWithTitle:(NSString *)title message:(NSString *)message actionTitles:(NSArray *)actionTitles;
{
    self.backgroundColor = BaseMenuBackgroundColor(self.style);
    
    if (title) {
        _titleLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        _titleLabel.backgroundColor = [UIColor clearColor];
        _titleLabel.font = [UIFont boldSystemFontOfSize:17];
        _titleLabel.textAlignment = NSTextAlignmentCenter;
        _titleLabel.textColor = BaseMenuTextColor(self.style);
        _titleLabel.text = title;
        [self addSubview:_titleLabel];
    }
    if (message) {
        _messageLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        _messageLabel.backgroundColor = [UIColor clearColor];
        _messageLabel.font = [UIFont systemFontOfSize:15];
        _messageLabel.textAlignment = NSTextAlignmentLeft;
        _messageLabel.textColor = BaseMenuTextColor(self.style);
        _messageLabel.numberOfLines = 0;
        _messageLabel.text = message;
        [self addSubview:_messageLabel];
    }
    for (int i=0; i<actionTitles.count; i++) {
        NSString *title = actionTitles[i];
        SGButton *actionButton = [SGButton buttonWithType:UIButtonTypeCustom];
        actionButton.tag = i;
        actionButton.clipsToBounds = YES;
        actionButton.titleLabel.font = [UIFont systemFontOfSize:16];
        [actionButton setTitleColor:BaseMenuActionTextColor(self.style) forState:UIControlStateNormal];
        [actionButton setTitle:title forState:UIControlStateNormal];
        [actionButton addTarget:self
                         action:@selector(tapAction:)
               forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:actionButton];
        [self.actionButtons addObject:actionButton];
    }
}

- (void)setStyle:(SGActionViewStyle)style{
    _style = style;
    
    self.backgroundColor = BaseMenuBackgroundColor(style);
    self.titleLabel.textColor = BaseMenuTextColor(style);
    self.messageLabel.textColor = BaseMenuTextColor(style);
    for (UIView *view in self.subviews) {
        if ([view isKindOfClass:[SGButton class]]) {
            [(SGButton*)view setTitleColor:BaseMenuActionTextColor(style) forState:UIControlStateNormal];
        }
    }
}

- (void)layoutSubviews
{
    [super layoutSubviews];

    float height = 0;
    float title_top_margin = self.messageLabel.text ? 0 : 15;
    float message_top_margin = 0;
    float message_bottom_margin = self.messageLabel.text ? 15 : 0;
    
    height += title_top_margin;
    if (self.titleLabel) {
        self.titleLabel.frame = (CGRect){CGPointMake(0, height), CGSizeMake(self.bounds.size.width, 50)};
        height += self.titleLabel.bounds.size.height + self.titleLabel.frame.origin.y;
    }
    height += message_top_margin;
    if (self.messageLabel) {
        CGSize s = CGSizeMake(self.bounds.size.width * 0.9, 1000);
        s = [self.messageLabel sizeThatFits:s];
        self.messageLabel.frame = (CGRect){CGPointMake(self.bounds.size.width * 0.05, height), s};
        height += s.height;
    }
    height += message_bottom_margin;
    float btn_y = height;
    for (int i=0; i<self.actionButtons.count; i++) {
        UIButton *button = self.actionButtons[i];
        button.frame = (CGRect){CGPointMake(i * self.bounds.size.width / 2, btn_y), CGSizeMake(self.bounds.size.width / self.actionButtons.count, 44)};
        if (i == 0) {
            height += 44;
        }
    }

    self.bounds = (CGRect){CGPointZero, CGSizeMake(self.bounds.size.width, height)};
}

#pragma mark - 

- (void)triggerSelectedAction:(SGMenuActionHandler)actionHandle;
{
    self.actionHandle = actionHandle;
}

- (void)tapAction:(id)sender
{
    if ([sender isKindOfClass:[UIButton class]] && self.actionHandle) {
        NSInteger tag = [(UIButton*)sender tag];
        double delayInSeconds = 0.15;
        dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC));
        dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
            self.actionHandle(tag);
        });
    }
}

@end
