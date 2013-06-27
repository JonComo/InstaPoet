//
//  MVPhrase.m
//  Markov
//
//  Created by Jon Como on 12/8/12.
//  Copyright (c) 2012 Jon Como. All rights reserved.
//

#import "MVPhrase.h"

@implementation MVPhrase

-(id)init
{
    if (self = [super init]) {
        //init
        _nextWords = [[NSMutableArray alloc] init];
        
    }
    
    return self;
}

-(id)initWithCoder:(NSCoder *)aDecoder
{
    if (self = [super init]) {
        //init
        _nextWords = [aDecoder decodeObjectForKey:@"nextWords"];
        _text = [aDecoder decodeObjectForKey:@"text"];
    }
    
    return self;
}

-(void)encodeWithCoder:(NSCoder *)aCoder
{
    [aCoder encodeObject:self.text forKey:@"text"];
    [aCoder encodeObject:self.nextWords forKey:@"nextWords"];
}

@end