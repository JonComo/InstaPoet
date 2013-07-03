//
//  IPFlowLayout.m
//  InstaPoet
//
//  Created by Jon Como on 7/2/13.
//  Copyright (c) 2013 Jon Como. All rights reserved.
//

#import "IPFlowLayout.h"
#import <QuartzCore/QuartzCore.h>

@implementation IPFlowLayout

-(void)prepareLayout
{
    self.sectionInset = UIEdgeInsetsMake(50, 0, 0, 0);
}

-(NSArray *)layoutAttributesForElementsInRect:(CGRect)rect
{
    NSArray *attributes = [super layoutAttributesForElementsInRect:rect];
    
    for (UICollectionViewLayoutAttributes *attribute in attributes)
    {
        [self modifyAttributes:attribute];
    }
    
    return attributes;
}

-(void)modifyAttributes:(UICollectionViewLayoutAttributes *)attributes
{
    /*
    float contentOffset  = self.collectionView.contentOffset.y;
    float offset = attributes.frame.origin.y - contentOffset + 20;
    
    NSLog(@"%f", offset);
    
    attributes.alpha = offset/10;
     */
}

-(BOOL)shouldInvalidateLayoutForBoundsChange:(CGRect)newBounds
{
    return YES;
}

@end
