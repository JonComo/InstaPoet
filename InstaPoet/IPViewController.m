//
//  IPViewController.m
//  InstaPoet
//
//  Created by Jon Como on 6/26/13.
//  Copyright (c) 2013 Jon Como. All rights reserved.
//

#import "IPViewController.h"
#import "IPEditViewController.h"
#import "IPWorksCollection.h"
#import "IPWork.h"

@interface IPViewController () <UICollectionViewDataSource, UICollectionViewDelegateFlowLayout>
{
    NSMutableArray *localWorks;
    __weak IBOutlet UICollectionView *collectionViewWorks;
}

@end

@implementation IPViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
}

-(void)viewDidAppear:(BOOL)animated
{
    [[IPWorksCollection sharedCollection]loadLocalWorksCompletion:^(NSArray *works) {
        localWorks = [works mutableCopy];
        [collectionViewWorks reloadData];
    }];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)new:(id)sender
{
    IPWork *newWork = [[IPWork alloc] init];
    [self presentEditorWithWork:newWork];
}

-(void)presentEditorWithWork:(IPWork *)work
{
    IPEditViewController *editVC = [self.storyboard instantiateViewControllerWithIdentifier:@"editVC"];
    
    editVC.work = work;
    
    editVC.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;
    [self presentViewController:editVC animated:YES completion:nil];
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
    
    textView.text = work.text;
    
    return cell;
}

-(void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    IPWork *work = localWorks[indexPath.row];
    [self presentEditorWithWork:work];
}

@end