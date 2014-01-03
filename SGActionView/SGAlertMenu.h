//
//  SGAlertMenu.h
//  SGActionView
//
//  Created by Sagi on 13-9-4.
//  Copyright (c) 2013年 AzureLab. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SGBaseMenu.h"

@interface SGAlertMenu : SGBaseMenu

- (id)initWithTitle:(NSString *)title message:(NSString *)message buttonTitles:(NSString *)buttonTitles,...;

- (void)triggerSelectedAction:(void(^)(NSInteger))actionHandle;

@end
