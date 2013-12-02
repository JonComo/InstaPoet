//
//  IPAuthorsViewController.m
//  InstaPoet
//
//  Created by Jon Como on 6/27/13.
//  Copyright (c) 2013 Jon Como. All rights reserved.
//

#import "IPAuthorsViewController.h"
#import "IPEditViewController.h"
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
    
    localAuthors = [[IPWork localFiles] mutableCopy];
    [collectionViewAuthors reloadData];
}

-(void)willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration
{
    isRotating = YES;
    [collectionViewAuthors.collectionViewLayout invalidateLayout];
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
    IPWork *newAuthor = [[IPWork alloc] initWithType:IPWorkTypeInspiration name:@"Author Name" text:@"Paste author's sample work here."];
    
    [self presentEditorWithWork:newAuthor];
}

-(void)editAuthor:(IPButtonCell *)sender
{
    IPWork *author = localAuthors[sender.indexPath.row];
    
    [self presentEditorWithWork:author];
}

-(void)presentEditorWithWork:(IPWork *)work
{
    [work loadFromDiskCompletion:^{
        
        IPEditViewController *editVC = [self.storyboard instantiateViewControllerWithIdentifier:@"editVC"];
        
        editVC.work = work;
        
        [self presentViewController:editVC animated:YES completion:nil];
    }];
}

-(UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    IPWork *author = localAuthors[indexPath.row];
    
    UICollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"authorCell" forIndexPath:indexPath];
    
    IPButtonCell *editButton = (IPButtonCell *)[cell viewWithTag:200];
    editButton.indexPath = indexPath;
    
    if (editButton.allTargets.count == 0){
        [editButton addTarget:self action:@selector(editAuthor:) forControlEvents:UIControlEventTouchUpInside];
    }
    
    UILabel *authorName = (UILabel *)[cell viewWithTag:400];
    authorName.text = author.name;
    
    UITextView *textView = (UITextView *)[cell viewWithTag:100];
    textView.text = author.summary;
    
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
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    [hud setMode:MBProgressHUDModeIndeterminate];
    hud.labelText = @"Generating Model";
    
    IPWork *author = localAuthors[indexPath.row];
    
    [author loadFromDiskCompletion:^{
        
        MVMarkov *model = [MVMarkov new];
        [model generateModelWithString:author.text completion:^{
            
            self.workUser.model = model;
            
            [self dismissViewControllerAnimated:YES completion:nil];
        }];
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
    
    return CGSizeMake(newWidth, 80);
}

@end
