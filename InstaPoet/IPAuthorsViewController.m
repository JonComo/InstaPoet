//
//  IPAuthorsViewController.m
//  InstaPoet
//
//  Created by Jon Como on 6/27/13.
//  Copyright (c) 2013 Jon Como. All rights reserved.
//

#import "IPAuthorsViewController.h"
#import "IPEditViewController.h"
#import "IPWorksCollection.h"
#import "MBProgressHUD.h"
#import "IPButtonCell.h"
#import "MVMarkov.h"
#import "IPWork.h"

@interface IPAuthorsViewController () <UICollectionViewDataSource, UICollectionViewDelegateFlowLayout>
{
    NSMutableArray *localAuthors;
    __weak IBOutlet UICollectionView *collectionViewAuthors;
    
    BOOL isRotating;
}

@end

@implementation IPAuthorsViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    [hud setMode:MBProgressHUDModeIndeterminate];
    hud.labelText = @"Loading Inspiration";
    
    [[IPWorksCollection sharedCollection] loadLocalAuthorsCompletion:^(NSArray *authors) {
        [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
        localAuthors = [authors mutableCopy];
        [collectionViewAuthors reloadData];
    }];
}

-(void)willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration
{
    isRotating = YES;
    [collectionViewAuthors.collectionViewLayout invalidateLayout];
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

- (IBAction)off:(id)sender
{
    self.workUser.model = nil;
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (IBAction)newAuthor:(id)sender
{
    IPWork *newAuthor = [[IPWork alloc] initWithType:kWorkTypeAuthor];
    
    [self presentEditorWithWork:newAuthor];
}

-(void)editAuthor:(IPButtonCell *)sender
{
    IPWork *author = localAuthors[sender.indexPath.row];
    
    [self presentEditorWithWork:author];
}

-(void)presentEditorWithWork:(IPWork *)work
{
    IPEditViewController *editVC = [self.storyboard instantiateViewControllerWithIdentifier:@"editVC"];
    
    editVC.work = work;
    
    [self presentViewController:editVC animated:YES completion:nil];
}

-(UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    IPWork *author = localAuthors[indexPath.row];
    
    UICollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"authorCell" forIndexPath:indexPath];
    
    IPButtonCell *editButton = (IPButtonCell *)[cell viewWithTag:200];
    editButton.indexPath = indexPath;
    
    if (editButton.allTargets.count == 0)
    {
        [editButton addTarget:self action:@selector(editAuthor:) forControlEvents:UIControlEventTouchUpInside];
    }
    
    UITextView *textView = (UITextView *)[cell viewWithTag:100];
    
    NSString *subText = [author.text substringToIndex:MIN(author.text.length, 200)];
    textView.text = subText;
    
    UIView *divider = [cell viewWithTag:300];
    divider.alpha = (indexPath.row == localAuthors.count-1) ? 0 : 1;
    
    return cell;
}

-(NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return localAuthors.count;
}

-(void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    IPWork *author = localAuthors[indexPath.row];
    
    self.workUser.authorWorkURL = author.url;
    
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    [hud setMode:MBProgressHUDModeIndeterminate];
    hud.labelText = @"Generating Model";
    
    [self.workUser loadModelCompletion:^{
        [MBProgressHUD hideAllHUDsForView:self.view animated:NO];
        
        [self dismissViewControllerAnimated:YES completion:nil];
    }];
}

-(CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath
{
    IPWork *author = localAuthors[indexPath.row];
    
    float newWidth = self.view.frame.size.width;
    
    if (self.interfaceOrientation != UIInterfaceOrientationPortrait && isRotating)
    {
        newWidth = self.view.frame.size.height;
    }
    
    NSString *subText = [author.text substringToIndex:MIN(author.text.length, 200)];
    
    CGSize workSize = [subText sizeWithFont:[UIFont systemFontOfSize:14] constrainedToSize:CGSizeMake(newWidth, 110)];
    
    return CGSizeMake(newWidth, workSize.height + 20);
}

@end
