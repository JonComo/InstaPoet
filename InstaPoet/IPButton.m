//
//  IPButton.m
//  InstaPoet
//
//  Created by Jon Como on 7/2/13.
//  Copyright (c) 2013 Jon Como. All rights reserved.
//

#import "IPButton.h"
#import "IPGraphics.h"

@implementation IPButton

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
    [IPGraphics button:self];
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
