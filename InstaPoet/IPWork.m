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

#import "Macros.h"

@implementation IPWork

-(id)initWithType:(IPWorkType)type name:(NSString *)name text:(NSString *)text
{
    if (self = [super init]) {
        //init
        _dateCreated = [NSDate date];
        _type = type;
        
        _name = name;
        _text = text;
        
        _summary = [text substringToIndex:MIN(200, text.length)];
        
        _url = [IPWork uniqueDirectoryWithName:@"work"];
    }
    
    return self;
}


+(NSURL *)uniqueDirectoryWithName:(NSString *)name
{
    //Make unique directory url
    
    NSString *documents = [[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask][0];
    
    NSArray *dirNames = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:documents error:nil];
    
    int counter = 0;
    NSString *dirName;
    BOOL isUnique;
    
    do {
        dirName = [NSString stringWithFormat:@"%@%i", name, counter];
        counter ++;
        
        isUnique = YES;
        
        for (NSString *testName in dirNames)
        {
            if ([dirName isEqualToString:testName]) isUnique = NO;
        }
        
    } while (!isUnique);
    
    return [NSURL URLWithString:[NSString stringWithFormat:@"%@/%@", documents, dirName]];
}

-(id)initWithCoder:(NSCoder *)aDecoder
{
    if (self = [super init]) {
        //init
        _name = [aDecoder decodeObjectForKey:@"name"];
        _url = [aDecoder decodeObjectForKey:@"url"];
        
        _dateCreated = [aDecoder decodeObjectForKey:@"dateCreated"];
        _type = [aDecoder decodeIntForKey:@"type"];
        _summary = [aDecoder decodeObjectForKey:@"summary"];
    }
    
    return self;
}

-(void)encodeWithCoder:(NSCoder *)aCoder
{
    [aCoder encodeObject:self.name forKey:@"name"];
    [aCoder encodeObject:self.url forKey:@"url"];
    
    [aCoder encodeObject:self.dateCreated forKey:@"dateCreated"];
    [aCoder encodeInt:self.type forKey:@"type"];
    [aCoder encodeObject:self.summary forKey:@"summary"];
}

-(void)setText:(NSString *)text
{
    _text = text;
    
    _summary = [text substringToIndex:MIN(200, text.length)];
}

-(void)loadFromDiskCompletion:(void (^)(void))block
{
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^{
        NSString *textPath = [NSString stringWithFormat:@"%@/text", [self.url path]];
        _text = [NSKeyedUnarchiver unarchiveObjectWithFile:textPath];
        //_model = [NSKeyedUnarchiver unarchiveObjectWithFile:];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            if (block) block();
        });
    });
}

-(void)saveToDisk
{
    if (![[NSFileManager defaultManager] fileExistsAtPath:[self.url path] isDirectory:nil]){
        [[NSFileManager defaultManager] createDirectoryAtURL:self.url withIntermediateDirectories:NO attributes:nil error:nil];
    }
    
    NSString *workPath = [NSString stringWithFormat:@"%@/work", [self.url path]];
    NSString *textPath = [NSString stringWithFormat:@"%@/text", [self.url path]];
    
    [NSKeyedArchiver archiveRootObject:self toFile:workPath];
    [NSKeyedArchiver archiveRootObject:self.text toFile:textPath];
}

+(NSArray *)localFiles
{
    NSArray *localDirs = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:DOCUMENTS error:nil];
    NSMutableArray *files = [NSMutableArray array];
    
    if (localDirs.count == 0) return nil;
    
    for (NSString *directoryName in localDirs)
    {
        NSString *path = [NSString stringWithFormat:@"%@/%@/work", DOCUMENTS, directoryName];
        IPWork *work = [NSKeyedUnarchiver unarchiveObjectWithFile:path];
        if (work)
            [files addObject:work];
    }
    
    return files;
}

+(void)setupSavedWorks
{
    NSArray *bundleAuthors = [[NSBundle mainBundle] pathsForResourcesOfType:@"author" inDirectory:@"authors"];
    
    for (NSString *authorPath in bundleAuthors)
    {
        //unarchive json and create works to reference from
        NSData *data = [NSData dataWithContentsOfFile:authorPath];
        NSDictionary *info = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingAllowFragments error:nil];
        
        NSString *name = info[@"name"];
        NSString *text = info[@"text"];
        
        IPWork *work = [[IPWork alloc] initWithType:IPWorkTypeInspiration name:name text:text];
        [work saveToDisk];
    }
}

@end