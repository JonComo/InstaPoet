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
#import "MVMarkov.h"
#import "IPWork.h"

@interface IPAuthorsViewController () <UICollectionViewDataSource, UICollectionViewDelegateFlowLayout>
{
    NSMutableArray *localAuthors;
    __weak IBOutlet UICollectionView *collectionViewAuthors;
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
    
    [[IPWorksCollection sharedCollection] loadLocalAuthorsCompletion:^(NSArray *authors) {
        localAuthors = [authors mutableCopy];
        [collectionViewAuthors reloadData];
    }];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)cancel:(id)sender
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (IBAction)newAuthor:(id)sender
{
    IPWork *newAuthor = [[IPWork alloc] initWithType:kWorkTypeAuthor];
    
    [self presentEditorWithWork:newAuthor];
}

-(void)editAuthor:(UIButton *)sender
{
    UICollectionViewCell *cell = (UICollectionViewCell*)[sender superview];
    
    NSIndexPath *indexPath = [collectionViewAuthors indexPathForCell:cell];
    
    IPWork *author = localAuthors[indexPath.row];
    
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
    
    UIButton *editButton = (UIButton *)[cell viewWithTag:200];
    
    if (editButton.allTargets.count == 0)
    {
        [editButton addTarget:self action:@selector(editAuthor:) forControlEvents:UIControlEventTouchUpInside];
    }
    
    UITextView *textView = (UITextView *)[cell viewWithTag:100];
    
    textView.text = author.text;
    
    return cell;
}

-(NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return localAuthors.count;
}

-(void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    IPWork *author = localAuthors[indexPath.row];
    
    self.workUser.modelURL = author.url;
    
    MVMarkov *markov = [MVMarkov new];
    
    NSLog(@"Generating model");
    
    [markov buildModelWithAuthorWork:author.text contextLevel:1 completion:^{
        self.workUser.markov = markov;
        [self.workUser save];
        [self dismissViewControllerAnimated:YES completion:nil];
    }];
}

@end
