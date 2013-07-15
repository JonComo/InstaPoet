//
//  IPLabel.m
//  InstaPoet
//
//  Created by Jon Como on 7/15/13.
//  Copyright (c) 2013 Jon Como. All rights reserved.
//

#import "IPLabel.h"
#import "IPGraphics.h"

@implementation IPLabel

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        [self graphics];
    }
    return self;
}

-(id)initWithCoder:(NSCoder *)aDecoder
{
    if (self = [super initWithCoder:aDecoder]) {
        //init
        [self graphics];
    }
    
    return self;
}

-(void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

-(void)graphics
{
    [self changeColor];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(changeColor) name:IPNotificationColorChanged object:nil];
}

-(void)changeColor
{
    [IPGraphics label:self];
}



/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

@end
