//
//  IPGraphics.m
//  InstaPoet
//
//  Created by Jon Como on 7/2/13.
//  Copyright (c) 2013 Jon Como. All rights reserved.
//

#import "IPGraphics.h"

#define IPInterfaceColor @"defaultColor"

@implementation IPGraphics

+(void)button:(UIButton *)button
{
    [button setTitleColor:[IPGraphics interfaceColor] forState:UIControlStateNormal];
    [button setTitleColor:[IPGraphics interfaceColor] forState:UIControlStateHighlighted];
}

+(UIColor *)interfaceColor
{
    if (![[NSUserDefaults standardUserDefaults] objectForKey:IPInterfaceColor]){
        [IPGraphics setInterfaceColor:IPColorDefault];
    }
    
    NSData *colorData = [[NSUserDefaults standardUserDefaults] objectForKey:IPInterfaceColor];
    UIColor *returnColor = (UIColor *)[NSKeyedUnarchiver unarchiveObjectWithData:colorData];
    
    return returnColor;
}

+(void)setInterfaceColor:(UIColor *)color
{
    NSData *colorData = [NSKeyedArchiver archivedDataWithRootObject:color];
    
    [[NSUserDefaults standardUserDefaults] setObject:colorData forKey:IPInterfaceColor];
    
    [[NSNotificationCenter defaultCenter] postNotificationName:IPNotificationColorChanged object:nil];
}

@end