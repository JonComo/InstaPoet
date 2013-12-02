//
//  IPEditViewController.m
//  InstaPoet
//
//  Created by Jon Como on 6/26/13.
//  Copyright (c) 2013 Jon Como. All rights reserved.
//

#import "IPEditViewController.h"
#import "IPAuthorsViewController.h"
#import "IPWorkOptionsViewController.h"
#import "MVMarkov.h"
#import "MVPhrase.h"
#import "IPLabel.h"
#import "IPWork.h"

@interface IPEditViewController () <UITextViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout>
{
    __weak IBOutlet UITextView *textViewMain;
    __weak IBOutlet NSLayoutConstraint *constraintBottom;
    __weak IBOutlet NSLayoutConstraint *constraintControlsHeight;
    
    __weak IBOutlet UIView *viewControls;
    
    __weak IBOutlet UIButton *buttonInspiration;
    
    __weak IBOutlet UICollectionView *collectionViewWords;
    
    NSArray *foundPhrases;
    NSArray *phrasesSuggested;
    
    NSString *textEntered;
    
    BOOL isBackspace;
}

@end

@implementation IPEditViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillChangeFrame:) name:UIKeyboardWillChangeFrameNotification object:nil];
    
    textViewMain.text = self.work.text;
    
    constraintControlsHeight.constant = 40;
    [self.view layoutSubviews];
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [self showInspiration];
}

-(void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    if (self.work.text.length == 0){
        [textViewMain becomeFirstResponder];
    }
}

-(void)willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration
{
    viewControls.alpha = 0;
}

-(void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation
{
    [UIView animateWithDuration:0.3 animations:^{
        viewControls.alpha = 1;
    }];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

-(void)showInspiration
{
    if (self.work.model)
    {
        [buttonInspiration setTitle:@"Inspiration (On)" forState:UIControlStateNormal];
    }else{
        [buttonInspiration setTitle:@"Inspiration (Off)" forState:UIControlStateNormal];
        
        constraintControlsHeight.constant = 40;
        [self.view layoutSubviews];
    }
}

-(void)keyboardWillChangeFrame:(NSNotification *)notification
{
    CGRect keyboardRect;
    
    [[notification.userInfo valueForKey:UIKeyboardFrameEndUserInfoKey] getValue:&keyboardRect];
    float animationDuration = [[notification.userInfo valueForKey:UIKeyboardAnimationDurationUserInfoKey] floatValue];
    
    [UIView animateWithDuration:animationDuration animations:^{
        
        float statusHeight = 0;
        float frameHeight = self.view.frame.size.height;
        
        float offset = (frameHeight + statusHeight - keyboardRect.origin.y);
        
        if (self.interfaceOrientation != UIInterfaceOrientationPortrait){
            statusHeight = [UIApplication sharedApplication].statusBarFrame.size.width;
            frameHeight = self.view.frame.size.width;
        }
        
        if (self.interfaceOrientation == UIInterfaceOrientationLandscapeRight)
        {
            offset = keyboardRect.size.width;
        }else if (self.interfaceOrientation == UIInterfaceOrientationLandscapeLeft){
            offset = (frameHeight + statusHeight - keyboardRect.origin.x);
        }
        
        constraintBottom.constant = offset;
        [self.view layoutSubviews];
    }];
}

-(void)saveWork
{
    if (textViewMain.text.length > 0)
    {
        self.work.text = textViewMain.text;
        [self.work saveToDisk];
    }else{
        //delete
    }
}

- (IBAction)done:(id)sender
{
    [textViewMain resignFirstResponder];
    [self saveWork];
    
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (IBAction)keyboardToggle:(id)sender
{
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

- (IBAction)options:(id)sender
{
    IPWorkOptionsViewController *optionsVC = [self.storyboard instantiateViewControllerWithIdentifier:@"optionsVC"];
    
    [self saveWork];
    
    optionsVC.work = self.work;
    
    optionsVC.modalTransitionStyle = UIModalTransitionStyleFlipHorizontal;
    [self presentViewController:optionsVC animated:YES completion:nil];
}

-(BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text
{
    isBackspace = (text.length == 0);
    
    return YES;
}

-(void)textViewDidChange:(UITextView *)textView
{
    if (!isBackspace)
        [self suggestWords];
}

-(void)filterWords
{
    //filter based on text entered
    if (textEntered.length == 0 || !textEntered)
    {
        //none entered, just use all
        phrasesSuggested = [foundPhrases copy];
        [collectionViewWords reloadData];
        return;
    }
    
    NSMutableArray *matched = [NSMutableArray array];
    
    for (MVPhrase *phrase in phrasesSuggested)
    {
        if (![phrase.text rangeOfString:textEntered].location == NSNotFound)
        {
            //contains it
            [matched addObject:phrase];
        }
    }
    
    phrasesSuggested = matched;
    [collectionViewWords reloadData];
}

-(void)suggestWords
{
    if (textViewMain.text.length > 1)
    {
        NSString *periodTest = [textViewMain.text substringFromIndex:textViewMain.text.length-1];
        
        if ([periodTest isEqualToString:@"."])
        {
            //dont suggest any
            [self showSuggestions:NO];
            return;
        }
    }
    
    [self.work.model suggestWordsForString:textViewMain.text completion:^(NSArray *words) {
        
        foundPhrases = [words copy];
        phrasesSuggested = [foundPhrases copy];
        [collectionViewWords reloadData];
        
        if (words.count > 0)
        {
            textEntered = @"";
            [self showSuggestions:YES];
            [collectionViewWords scrollToItemAtIndexPath:[NSIndexPath indexPathForItem:0 inSection:0] atScrollPosition:UICollectionViewScrollPositionTop animated:NO];
        }else{
            [self showSuggestions:NO];
        }
    }];
}

-(void)showSuggestions:(BOOL)show
{
    float targetHeight = show ? 120 : 40;
    
    [UIView animateWithDuration:0.3 animations:^{
        constraintControlsHeight.constant = targetHeight;
        [self.view layoutSubviews];
    }];
    
    if (textViewMain.contentSize.height > textViewMain.frame.size.height){
        CGPoint offset = CGPointMake(0, textViewMain.contentSize.height - textViewMain.frame.size.height);
        [textViewMain setContentOffset:offset animated:YES];
    }
}

-(UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    UICollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"wordCell" forIndexPath:indexPath];
    
    MVPhrase *phrase = phrasesSuggested[indexPath.row];
    
    IPLabel *label = (IPLabel *)[cell viewWithTag:100];
    
    label.text = phrase.text;
    
    return cell;
}

-(NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return phrasesSuggested.count;
}

-(void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    MVPhrase *phrase = phrasesSuggested[indexPath.row];
    
    NSString *lastCharacter = [textViewMain.text substringFromIndex:textViewMain.text.length-1];
    
    textViewMain.text = [NSString stringWithFormat:@"%@%@%@", textViewMain.text, [lastCharacter isEqualToString:@" "] ? @"": @" ", phrase.text];
    
    [self suggestWords];
}

-(CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath
{
    MVPhrase *phrase = phrasesSuggested[indexPath.row];
    
    CGSize wordSize = [phrase.text sizeWithAttributes:@{NSFontAttributeName: [UIFont fontWithName:@"Helvetica" size:16]}];
    
    return CGSizeMake(wordSize.width + 10, 34);
}

@end
