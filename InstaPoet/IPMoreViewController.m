//
//  IPMoreViewController.m
//  InstaPoet
//
//  Created by Jon Como on 7/2/13.
//  Copyright (c) 2013 Jon Como. All rights reserved.
//

#import "IPMoreViewController.h"
#import "IPGraphics.h"

@interface IPMoreViewController ()

@end

@implementation IPMoreViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)done:(id)sender
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (IBAction)changeInterfaceColor:(UIButton *)sender
{
    [IPGraphics setInterfaceColor:sender.backgroundColor];
}

@end