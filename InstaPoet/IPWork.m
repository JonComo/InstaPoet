//
//  IPWork.m
//  InstaPoet
//
//  Created by Jon Como on 6/26/13.
//  Copyright (c) 2013 Jon Como. All rights reserved.
//

#import "IPWork.h"
#import "MVMarkov.h"
#import "NSURL+Unique.h"

#import "IPWorksCollection.h"

@implementation IPWork

-(id)initWithType:(IPWorkType)type name:(NSString *)name text:(NSString *)text
{
    if (self = [super init]) {
        //init
        _dateCreated = [NSDate date];
        _type = type;
        _name = name;
        _summary = [text substringToIndex:MIN(20, text.length)];
        
        _textURL = [NSURL uniqueWithName:@"text"];
        _modelURL = [NSURL uniqueWithName:@"model"];
    }
    
    return self;
}

-(id)initWithCoder:(NSCoder *)aDecoder
{
    if (self = [super init]) {
        //init
//        _text = [aDecoder decodeObjectForKey:@"text"];
//        _authorWorkURL = [aDecoder decodeObjectForKey:@"authorWorkURL"];
//        _url = [aDecoder decodeObjectForKey:@"url"];
        _name = [aDecoder decodeObjectForKey:@"name"];
        _dateCreated = [aDecoder decodeObjectForKey:@"dateCreated"];
        _type = [aDecoder decodeIntForKey:@"type"];
        _summary = [aDecoder decodeObjectForKey:@"summary"];
        
        _textURL = [aDecoder decodeObjectForKey:@"textURL"];
        _modelURL = [aDecoder decodeObjectForKey:@"modelURL"];
    }
    
    return self;
}

-(void)encodeWithCoder:(NSCoder *)aCoder
{
    //[aCoder encodeObject:self.url forKey:@"url"];
    [aCoder encodeObject:self.name forKey:@"name"];
    [aCoder encodeObject:self.dateCreated forKey:@"dateCreated"];
    [aCoder encodeInt:self.type forKey:@"type"];
    [aCoder encodeObject:self.summary forKey:@"summary"];
    
    [aCoder encodeObject:self.textURL forKey:@"textURL"];
    [aCoder encodeObject:self.modelURL forKey:@"modelURL"];
}

-(void)setText:(NSString *)text
{
    _text = text;
    
    _summary = [text substringToIndex:MIN(20, text.length)];
}

-(void)loadFromDiskCompletion:(void (^)(void))block
{
    //load markov model, sample text or work text, and anything else here
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^{
        _text = [NSKeyedUnarchiver unarchiveObjectWithFile:[self.textURL path]];
        _model = [NSKeyedUnarchiver unarchiveObjectWithFile:[self.modelURL path]];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            if (block) block();
        });
    });
}

@end