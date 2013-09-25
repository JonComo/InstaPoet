//
//  IPGraphics.h
//  InstaPoet
//
//  Created by Jon Como on 7/2/13.
//  Copyright (c) 2013 Jon Como. All rights reserved.
//

#import <Foundation/Foundation.h>

#define IPNotificationColorChanged @"colorChanged"
#define IPColorDefault [UIColor colorWithRed:0.244 green:0.824 blue:1.000 alpha:1.000]

@interface IPGraphics : NSObject

+(void)button:(UIButton *)button;
+(void)label:(UILabel *)label;
+(UIColor *)interfaceColor;
+(void)setInterfaceColor:(UIColor *)color;

@end