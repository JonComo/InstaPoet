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
        _nextPhrases = [NSMutableArray array];
    }
    
    return self;
}

-(id)initWithCoder:(NSCoder *)aDecoder
{
    if (self = [super init]) {
        //init
        _nextPhrases = [aDecoder decodeObjectForKey:@"nextPhrases"];
        _text = [aDecoder decodeObjectForKey:@"text"];
        _count = [aDecoder decodeIntForKey:@"count"];
    }
    
    return self;
}

-(void)encodeWithCoder:(NSCoder *)aCoder
{
    [aCoder encodeObject:self.text forKey:@"text"];
    [aCoder encodeObject:self.nextPhrases forKey:@"nextPhrases"];
    [aCoder encodeInt:self.count forKey:@"count"];
}

@end