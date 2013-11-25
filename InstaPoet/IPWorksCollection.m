//
//  IPWorksCollection.m
//  InstaPoet
//
//  Created by Jon Como on 6/26/13.
//  Copyright (c) 2013 Jon Como. All rights reserved.
//

#import "IPWorksCollection.h"
#import "IPWork.h"
#import "Macros.h"

@implementation IPWorksCollection

+(IPWorksCollection *)sharedCollection
{
    static IPWorksCollection *sharedCollection;
    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedCollection = [[self alloc] init];
    });
    
    return sharedCollection;
}

-(NSArray *)localFilesOfType:(int)type
{
    NSArray *archivedWorks = [[NSUserDefaults standardUserDefaults] arrayForKey:WORKS];
    
    NSMutableArray *works = [NSMutableArray array];
    
    for (NSData *archivedWork in archivedWorks)
    {
        IPWork *work = [NSKeyedUnarchiver unarchiveObjectWithData:archivedWork];
        if (work.type == type) [works addObject:work];
    }
    
    return works;
}

+(NSURL *)uniqueURL
{
    NSString *documents = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES)[0];
    
    int count = 0;
    
    NSURL *URL;
    
    do {
        URL = [NSURL URLWithString:[NSString stringWithFormat:@"%@/%i", documents, count]];
        count ++;
    } while ([[NSFileManager defaultManager] fileExistsAtPath:[URL path]]);
    
    return URL;
}

-(void)saveFile:(IPWork *)work
{
    NSMutableArray *localFiles = [[[IPWorksCollection sharedCollection] localFilesOfType:work.type] mutableCopy];
    
    BOOL existingWork = NO;
    for (IPWork *localWork in localFiles){
        if ([work.dateCreated isEqualToDate:localWork.dateCreated]){
            existingWork = YES;
        }
    }
    
    [NSKeyedArchiver archiveRootObject:work.text toFile:[work.textURL path]];
    if (work.model) [NSKeyedArchiver archiveRootObject:work.model toFile:[work.modelURL path]];
    
    if (!existingWork) [localFiles addObject:work];
    
    [self archiveWorks:localFiles];
}

-(void)deleteFile:(IPWork *)work
{
    NSMutableArray *localFiles = [[[IPWorksCollection sharedCollection] localFilesOfType:work.type] mutableCopy];
    
    for (int i = 0; i<localFiles.count; i++)
    {
        IPWork *localWork = localFiles[i];
        
        if ([work.dateCreated isEqualToDate:localWork.dateCreated]){
            //Found it!
            [localFiles removeObjectAtIndex:i];
        }
    }
    
    [self archiveWorks:localFiles];
}

-(void)archiveWorks:(NSMutableArray *)works
{
    NSMutableArray *archivedFiles = [NSMutableArray array];
    for (IPWork *localWork in works)
    {
        NSData *archived = [NSKeyedArchiver archivedDataWithRootObject:localWork];
        [archivedFiles addObject:archived];
    }
    
    [[NSUserDefaults standardUserDefaults] setObject:archivedFiles forKey:WORKS];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

@end