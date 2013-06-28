//
//  IPWork.m
//  InstaPoet
//
//  Created by Jon Como on 6/26/13.
//  Copyright (c) 2013 Jon Como. All rights reserved.
//

#import "IPWork.h"
#import "Macros.h"

@implementation IPWork

-(id)init
{
    if (self = [super init]) {
        //init
        _dateCreated = [NSDate date];
    }
    
    return self;
}

-(id)initWithCoder:(NSCoder *)aDecoder
{
    if (self = [super init]) {
        //init
        _text = [aDecoder decodeObjectForKey:@"text"];
        _modelURL = [aDecoder decodeObjectForKey:@"modelURL"];
        _url = [aDecoder decodeObjectForKey:@"url"];
        _dateCreated = [aDecoder decodeObjectForKey:@"dateCreated"];
    }
    
    return self;
}

-(void)encodeWithCoder:(NSCoder *)aCoder
{
    [aCoder encodeObject:self.text forKey:@"text"];
    [aCoder encodeObject:self.modelURL forKey:@"modelURL"];
    [aCoder encodeObject:self.url forKey:@"url"];
    [aCoder encodeObject:self.dateCreated forKey:@"dateCreated"];
}

-(void)save
{
    if (self.url){
        if ([[NSFileManager defaultManager] fileExistsAtPath:[self.url path]]){
            [[NSFileManager defaultManager] removeItemAtURL:self.url error:nil];
        }
    }else{
        NSDateFormatter *formatter = [NSDateFormatter new];
        [formatter setDateFormat:@"MMHHDDmmssSSSS"];
        
        NSString *documents = DOCUMENTS;
        
        self.url = [NSURL URLWithString:[NSString stringWithFormat:@"%@/%@.txt", documents, [formatter stringFromDate:self.dateCreated]]];
    }
    
    [NSKeyedArchiver archiveRootObject:self toFile:[self.url path]];
}

@end
