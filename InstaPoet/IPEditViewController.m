//
//  IPEditViewController.m
//  InstaPoet
//
//  Created by Jon Como on 6/26/13.
//  Copyright (c) 2013 Jon Como. All rights reserved.
//

#import "IPEditViewController.h"
#import "IPAuthorsViewController.h"
#import "MVMarkov.h"
#import "IPWork.h"

@interface IPEditViewController () <UITextViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout>
{
    __weak IBOutlet UITextView *textViewMain;
    __weak IBOutlet NSLayoutConstraint *constraintBottom;
    
    __weak IBOutlet UICollectionView *collectionViewWords;
    NSArray *wordsSuggested;
}

@end

@implementation IPEditViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillChangeFrame:) name:UIKeyboardWillChangeFrameNotification object:nil];
    
    textViewMain.text = self.work.text;
}

-(void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    if (self.work.text.length == 0){
        [textViewMain becomeFirstResponder];
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)keyboardWillChangeFrame:(NSNotification *)notification
{
    CGRect keyboardRect;
    
    [[notification.userInfo valueForKey:UIKeyboardFrameEndUserInfoKey] getValue:&keyboardRect];
    float animationDuration = [[notification.userInfo valueForKey:UIKeyboardAnimationDurationUserInfoKey] floatValue];
    
    [UIView animateWithDuration:animationDuration animations:^{
        float statusHeight = [UIApplication sharedApplication].statusBarFrame.size.height;
        
        float offset = (self.view.frame.size.height + statusHeight - keyboardRect.origin.y);
        constraintBottom.constant = offset;
        NSLog(@"x: %f y: %f w:%f h:%f", keyboardRect.origin.x, keyboardRect.origin.y, keyboardRect.size.width, keyboardRect.size.height);
        [self.view layoutSubviews];
    }];
}

- (IBAction)done:(id)sender
{
    self.work.text = textViewMain.text;
    
    [self.work save];
    
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (IBAction)keyboardToggle:(id)sender {
    if ([textViewMain isFirstResponder]){
        [textViewMain resignFirstResponder];
    }else{
        [textViewMain becomeFirstResponder];
    }
}

- (IBAction)chooseInspiration:(id)sender
{
    IPAuthorsViewController *authorsVC = [self.storyboard instantiateViewControllerWithIdentifier:@"authorsVC"];
    
    authorsVC.workUser = self.work;
    
    [self presentViewController:authorsVC animated:YES completion:nil];
}

-(BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text
{
    if ([text isEqualToString:@" "]){
        [self suggestWords];
    }
    
    return YES;
}

-(void)suggestWords
{
    [self.work.markov suggestWordsAfterString:textViewMain.text completion:^(NSArray *words) {
        wordsSuggested = [words copy];
        [collectionViewWords reloadData];
    }];
}

-(UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    UICollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"wordCell" forIndexPath:indexPath];
    
    NSString *word = wordsSuggested[indexPath.row];
    
    UILabel *label = (UILabel *)[cell viewWithTag:100];
    
    label.text = word;
    
    return cell;
}

-(NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return wordsSuggested.count;
}

-(void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    NSString *word = wordsSuggested[indexPath.row];
    
    textViewMain.text = [NSString stringWithFormat:@"%@%@ ", textViewMain.text, word];
    
    [self suggestWords];
}

@end
