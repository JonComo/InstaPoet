//
//  IPMoreViewController.m
//  InstaPoet
//
//  Created by Jon Como on 7/2/13.
//  Copyright (c) 2013 Jon Como. All rights reserved.
//

#import "IPMoreViewController.h"
#import "IPButton.h"
#import "IPGraphics.h"

#import "ISColorWheel.h"

@interface IPMoreViewController () <ISColorWheelDelegate>
{
    __weak IBOutlet IPButton *buttonMoreApps;
    
    ISColorWheel *wheel;
    
}

@end

@implementation IPMoreViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    
    [buttonMoreApps addTarget:self action:@selector(moreApps) forControlEvents:UIControlEventTouchUpInside];
        
    wheel = [[ISColorWheel alloc] initWithFrame:CGRectMake(40, 100, 240, 240)];
    wheel.continuous = YES;
    wheel.delegate = self;
    
    wheel.knobView.layer.transform = CATransform3DMakeScale(0, 0, 1);
    
    [self.view addSubview:wheel];
}

-(void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    [wheel setCurrentColor:[IPGraphics interfaceColor]];
    
    [UIView animateWithDuration:0.2 animations:^{
        wheel.knobView.layer.transform = CATransform3DMakeScale(1.1, 1.1, 1);
    } completion:^(BOOL finished) {
        [UIView animateWithDuration:0.2 animations:^{
            wheel.knobView.layer.transform = CATransform3DMakeScale(1, 1, 1);
        } completion:^(BOOL finished) {
            
        }];
    }];
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

-(void)colorWheelDidChangeColor:(ISColorWheel *)colorWheel
{
    [IPGraphics setInterfaceColor:colorWheel.currentColor];
}

-(void)moreApps
{
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"http://www.joncomo.com"]];
}

@end