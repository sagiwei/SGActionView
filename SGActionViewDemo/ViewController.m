//
//  ViewController.m
//  SGActionView
//
//  Created by Sagi on 13-12-17.
//  Copyright (c) 2013年 AzureLab. All rights reserved.
//

#import "ViewController.h"
#import "SGActionView.h"

@interface ViewController ()
@property (weak, nonatomic) IBOutlet UISegmentedControl *segmentedControl;

@end

@implementation ViewController

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == 1) {
        NSInteger selected = self.segmentedControl.selectedSegmentIndex;
        [SGActionView sharedActionView].style = selected == 0 ? SGActionViewStyleLight : SGActionViewStyleDark;
        if (indexPath.row == 0) {
            [SGActionView showAlertWithTitle:@"Alert View"
                                     message:@"Just input your alert message here.\nUse '\\n' to create a line break.\nAuto height adjust your message."
                             leftButtonTitle:@"Cancel"
                            rightButtonTitle:@"OK"
                              selectedHandle:nil];
        }else if (indexPath.row == 1){
            [SGActionView showSheetWithTitle:@"Sheet View"
                                  itemTitles:@[ @"Wedding Bell", @"I'm Yours", @"When I Was Your Man" ]
                               itemSubTitles:@[ @"Depapepe - Let's go!!!", @"Jason Mraz", @"Bruno Mars" ]
                               selectedIndex:0
                              selectedHandle:nil];
        }else if (indexPath.row == 2){
            [SGActionView showGridMenuWithTitle:@"Grid View"
                                     itemTitles:@[ @"Facebook", @"Twitter", @"Google+", @"Linkedin",
                                                   @"Weibo", @"WeChat", @"Pocket", @"Dropbox" ]
                                         images:@[ [UIImage imageNamed:@"facebook"],
                                                   [UIImage imageNamed:@"twitter"],
                                                   [UIImage imageNamed:@"googleplus"],
                                                   [UIImage imageNamed:@"linkedin"],
                                                   [UIImage imageNamed:@"weibo"],
                                                   [UIImage imageNamed:@"wechat"],
                                                   [UIImage imageNamed:@"pocket"],
                                                   [UIImage imageNamed:@"dropbox"]]
                                 selectedHandle:nil];
        }
    }
    double delayInSeconds = 0.2;
    dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC));
    dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
        [tableView deselectRowAtIndexPath:indexPath animated:YES];
    });
}

@end
