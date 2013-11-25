//
//  IPWorkOptionsViewController.m
//  InstaPoet
//
//  Created by Jon Como on 7/2/13.
//  Copyright (c) 2013 Jon Como. All rights reserved.
//

#import "IPWorkOptionsViewController.h"
#import "IPWorksCollection.h"
#import "IPWork.h"

@import AVFoundation;

@interface IPWorkOptionsViewController ()
{
    __weak IBOutlet UILabel *labelInfo;
    __weak IBOutlet UITextView *textViewWork;
}

@end

@implementation IPWorkOptionsViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    
    NSDateFormatter *formatter = [NSDateFormatter new];
    [formatter setDateStyle:NSDateFormatterFullStyle];
    
    labelInfo.text = [NSString stringWithFormat:@"Created: %@", [formatter stringFromDate:self.work.dateCreated]];
    
    textViewWork.text = self.work.text;
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

- (IBAction)delete:(id)sender
{
    [[IPWorksCollection sharedCollection] deleteFile:self.work];
    
    UIViewController *presenting = self.presentingViewController;
    
    [self dismissViewControllerAnimated:YES completion:^{
        [presenting dismissViewControllerAnimated:YES completion:nil];
    }];
}

- (IBAction)share:(id)sender
{
    NSString *poemHashed = [NSString stringWithFormat:@"%@ #instapoet", self.work.text];
    
    UIActivityViewController *activityController = [[UIActivityViewController alloc] initWithActivityItems:@[poemHashed] applicationActivities:nil];
    
    [self presentViewController:activityController animated:YES completion:nil];
}

- (IBAction)speak:(id)sender
{
    AVSpeechUtterance *utterance = [AVSpeechUtterance speechUtteranceWithString:self.work.text];
    
    utterance.rate = 0.8;
    utterance.pitchMultiplier = 1.2;
    
    AVSpeechSynthesizer *speach = [[AVSpeechSynthesizer alloc] init];
    
    [speach speakUtterance:utterance];
    
}

@end
