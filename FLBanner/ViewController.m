//
//  ViewController.m
//  FLBanner
//
//  Created by sashy on 2022/8/18.
//

#import "ViewController.h"
#import "FLBanner.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    //FLBanner的使用方法
    FLBanner *banner = [[FLBanner alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 200)];
    [banner refreshUI:@[@"fl_image.jpeg", @"fl_image2.jpeg"] action:^(NSInteger index) {
        NSLog(@"=========%zd",index);
    }];
    [self.view addSubview:banner];
}


@end
