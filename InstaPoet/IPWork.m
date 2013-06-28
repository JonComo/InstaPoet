//
//  IPWork.m
//  InstaPoet
//
//  Created by Jon Como on 6/26/13.
//  Copyright (c) 2013 Jon Como. All rights reserved.
//

#import "IPWork.h"
#import "MVMarkov.h"
#import "Macros.h"

@implementation IPWork

-(id)initWithType:(kWorkType)type
{
    if (self = [super init]) {
        //init
        _dateCreated = [NSDate date];
        
        NSDateFormatter *formatter = [NSDateFormatter new];
        [formatter setDateFormat:@"MMHHDDmmssSSSS"];
        
        if (type == kWorkTypeAuthor)
        {
            _url = [NSURL URLWithString:[NSString stringWithFormat:@"%@/authors/", DOCUMENTS]];
            
            BOOL *directoryExists = NULL;
            
            [[NSFileManager defaultManager] fileExistsAtPath:[_url path] isDirectory:directoryExists];
            
            if (!directoryExists){
                NSError *error;
                [[NSFileManager defaultManager] createDirectoryAtPath:[_url path] withIntermediateDirectories:NO attributes:nil error:&error];
                if (error) NSLog(@"%@", error);
            }
            
            _url = [_url URLByAppendingPathComponent:[NSString stringWithFormat:@"author_%@.txt", [formatter stringFromDate:self.dateCreated]]];
            
        }else if (type == kWorkTypeUser)
        {
            _url = [NSURL URLWithString:[NSString stringWithFormat:@"%@/user_%@.txt", DOCUMENTS, [formatter stringFromDate:self.dateCreated]]];
        }
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
        _markov = [aDecoder decodeObjectForKey:@"markov"];
    }
    
    return self;
}

-(void)encodeWithCoder:(NSCoder *)aCoder
{
    [aCoder encodeObject:self.text forKey:@"text"];
    [aCoder encodeObject:self.modelURL forKey:@"modelURL"];
    [aCoder encodeObject:self.url forKey:@"url"];
    [aCoder encodeObject:self.dateCreated forKey:@"dateCreated"];
    [aCoder encodeObject:self.markov forKey:@"markov"];
}

-(void)save
{
    if (self.url){
        if ([[NSFileManager defaultManager] fileExistsAtPath:[self.url path]]){
            [[NSFileManager defaultManager] removeItemAtURL:self.url error:nil];
        }
    }
    
    [NSKeyedArchiver archiveRootObject:self toFile:[self.url path]];
}

@end