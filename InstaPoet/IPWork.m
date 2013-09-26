//
//  IPWork.m
//  InstaPoet
//
//  Created by Jon Como on 6/26/13.
//  Copyright (c) 2013 Jon Como. All rights reserved.
//

#import "IPWork.h"
#import "MVMarkov.h"
#import "IPWorksCollection.h"
#import "Macros.h"

@implementation IPWork

-(id)initWithType:(kWorkType)type name:(NSString *)name
{
    if (self = [super init]) {
        //init
        _dateCreated = [NSDate date];
        _type = type;
        _name = name;
        
        NSDateFormatter *formatter = [NSDateFormatter new];
        [formatter setDateFormat:@"MMddyyyyhhmmssSSSS"];
        
        NSString *identifier;
        
        if (type == kWorkTypeAuthor){
            identifier = @"author";
        }else if (type == kWorkTypeUser){
            identifier = @"work";
        }
        
        _url = [NSURL URLWithString:[NSString stringWithFormat:@"%@/%@s/", DOCUMENTS, identifier]];
        
        [[IPWorksCollection sharedCollection] createDirectoryAtURL:_url];
        
        _url = [_url URLByAppendingPathComponent:[NSString stringWithFormat:@"%@_%@.txt", identifier, [formatter stringFromDate:self.dateCreated]]];
        
        [self save];
    }
    
    return self;
}

-(id)initWithCoder:(NSCoder *)aDecoder
{
    if (self = [super init]) {
        //init
        _text = [aDecoder decodeObjectForKey:@"text"];
        _authorWorkURL = [aDecoder decodeObjectForKey:@"authorWorkURL"];
        _url = [aDecoder decodeObjectForKey:@"url"];
        _dateCreated = [aDecoder decodeObjectForKey:@"dateCreated"];
        _type = [aDecoder decodeIntForKey:@"type"];
    }
    
    return self;
}

-(void)encodeWithCoder:(NSCoder *)aCoder
{
    [aCoder encodeObject:self.text forKey:@"text"];
    [aCoder encodeObject:self.authorWorkURL forKey:@"authorWorkURL"];
    [aCoder encodeObject:self.url forKey:@"url"];
    [aCoder encodeObject:self.dateCreated forKey:@"dateCreated"];
    [aCoder encodeInt:self.type forKey:@"type"];
}

-(BOOL)save
{
    NSError *error;
    
    if (self.url){
        if ([[NSFileManager defaultManager] fileExistsAtPath:[self.url path]]){
            [[NSFileManager defaultManager] removeItemAtURL:self.url error:&error];
        }
    }
    
    [NSKeyedArchiver archiveRootObject:self toFile:[self.url path]];
    
    //[[NSUserDefaults standardUserDefaults] setObject:@{@"name": self.name, @"sample" : @"This is the sample of the work", @"URL" : _url} forKey:[_url path]];
    
    return error ? NO : YES;
}

-(BOOL)deleteWork
{
    NSError *error;
    [[NSFileManager defaultManager] removeItemAtPath:[self.url path] error:&error];
    
    return error ? NO : YES;
}

-(void)loadModelCompletion:(void(^)(void))block
{
    if (self.authorWorkURL){
        IPWork *authorWork = [NSKeyedUnarchiver unarchiveObjectWithFile:[self.authorWorkURL path]];
        
        self.model = [MVMarkov new];
        [self.model generateModelWithString:authorWork.text completion:block];
    }
}

@end