//
//  IPViewController.m
//  InstaPoet
//
//  Created by Jon Como on 6/26/13.
//  Copyright (c) 2013 Jon Como. All rights reserved.
//

#import "IPViewController.h"
#import "IPMoreViewController.h"
#import "IPEditViewController.h"
#import "IPWorksCollection.h"
#import "IPButton.h"
#import "MBProgressHUD.h"
#import "IPWork.h"

#import "IPWorksCollection.h"

#import <QuartzCore/QuartzCore.h>

@interface IPViewController () <UICollectionViewDataSource, UICollectionViewDelegateFlowLayout>
{
    NSMutableArray *localWorks;
    __weak IBOutlet UICollectionView *collectionViewWorks;
    __weak IBOutlet IPButton *buttonInstapoet;
    __weak IBOutlet IPButton *buttonNew;
    
    BOOL isRotating;
}

@end

@implementation IPViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [self loadWorks];
}

- (CAAnimation*)getShakeAnimation
{
    CAKeyframeAnimation* animation = [CAKeyframeAnimation animationWithKeyPath:@"transform"];
    
    CGFloat wobbleAngle = 0.15f;
    
    NSValue* valLeft = [NSValue valueWithCATransform3D:CATransform3DMakeRotation(wobbleAngle, 0.0f, 0.0f, 1.0f)];
    NSValue* valRight = [NSValue valueWithCATransform3D:CATransform3DMakeRotation(-wobbleAngle, 0.0f, 0.0f, 1.0f)];
    animation.values = [NSArray arrayWithObjects:valLeft, valRight, nil];
    
    animation.autoreverses = YES;
    animation.duration = 0.1;
    animation.repeatCount = INT_MAX;
    
    return animation;
}

- (IBAction)instaPoet:(id)sender
{
    IPMoreViewController *moreVC = [self.storyboard instantiateViewControllerWithIdentifier:@"moreVC"];
    
    moreVC.modalTransitionStyle = UIModalTransitionStyleFlipHorizontal;
    [self presentViewController:moreVC animated:YES completion:nil];
}

-(void)willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration
{
    isRotating = YES;
    [collectionViewWorks.collectionViewLayout invalidateLayout];
    //[collectionViewWorks reloadData];
}

-(void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation
{
    isRotating = NO;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)loadWorks
{
    localWorks = [[[IPWorksCollection sharedCollection] dirLocalFiles] mutableCopy];
    [collectionViewWorks reloadData];
    
    if (localWorks.count == 0){
        [buttonNew.layer addAnimation:[self getShakeAnimation] forKey:@"wiggle"];
    }
}

- (IBAction)new:(id)sender
{
    [buttonNew.layer removeAllAnimations];
    
    IPWork *newWork = [[IPWork alloc] initWithType:IPWorkTypeUser name:@"Unnamed" text:@"Sample text"];
    
    [self presentEditorWithWork:newWork];
}

-(void)presentEditorWithWork:(IPWork *)work
{
    [work loadFromDiskCompletion:^{
        IPEditViewController *editVC = [self.storyboard instantiateViewControllerWithIdentifier:@"editVC"];
        
        editVC.work = work;
        
        editVC.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;
        
        [self presentViewController:editVC animated:YES completion:nil];
    }];
}

-(NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return localWorks.count;
}

-(UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    IPWork *work = localWorks[indexPath.row];
    
    UICollectionViewCell *cell = [collectionViewWorks dequeueReusableCellWithReuseIdentifier:@"workCell" forIndexPath:indexPath];
    
    UITextView *textView = (UITextView *)[cell viewWithTag:100];
    
    NSString *subString = work.summary;
    
    textView.text = subString;
    
    UIView *divider = [cell viewWithTag:200];
    divider.alpha = (indexPath.row == localWorks.count-1) ? 0 : 1;
    
    return cell;
}

-(void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    IPWork *work = localWorks[indexPath.row];
    [self presentEditorWithWork:work];
}

-(CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath
{
    IPWork *work = localWorks[indexPath.row];
    
    float newWidth = self.view.frame.size.width;
    
    if (self.interfaceOrientation != UIInterfaceOrientationPortrait && isRotating)
    {
        newWidth = self.view.frame.size.height;
    }
    
    NSString *subString = work.summary;
    
    CGSize workSize = [subString sizeWithFont:[UIFont systemFontOfSize:14] constrainedToSize:CGSizeMake(newWidth, 220)];
    
    return CGSizeMake(newWidth, workSize.height + 20);
}

@end