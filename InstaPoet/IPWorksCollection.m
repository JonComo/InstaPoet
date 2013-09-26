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

-(void)loadLocalWorksCompletion:(void(^)(NSArray *works))block
{
    NSString *worksDirectory = [NSString stringWithFormat:@"%@/works", DOCUMENTS];
    
    [self filesInDirectory:worksDirectory completion:block];
}

-(void)loadLocalAuthorsCompletion:(void (^)(NSArray *))block
{
    NSMutableArray *authors = [NSMutableArray array];
    
    //User created
    NSString *userAuthorsDirectory = [NSString stringWithFormat:@"%@/authors", DOCUMENTS];
    //NSArray *archivedAuthors = [[NSBundle mainBundle] pathsForResourcesOfType:@"author" inDirectory:nil];
    
    [self filesInDirectory:userAuthorsDirectory completion:^(NSArray *results) {
        [authors addObjectsFromArray:results];
        
        if(block) block(authors);
    }];
}

-(void)filesInDirectory:(NSString *)directory completion:(void(^)(NSArray *results))block
{
    NSError *error;
    NSArray *files = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:directory error:&error];
    
    if (error){
        if (block) block(nil);
        return;
    }
    
    NSMutableArray *works = [NSMutableArray array];
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^{
        for (NSString *fileName in files)
        {
            IPWork *work = [NSKeyedUnarchiver unarchiveObjectWithFile:[NSString stringWithFormat:@"%@/%@", directory, fileName]];
            
            if (work)
                [works addObject:work];
        }
        
        [works sortUsingComparator:^NSComparisonResult(id obj1, id obj2) {
            IPWork *work1 = obj1;
            IPWork *work2 = obj2;
            
            return [work1.dateCreated compare:work2.dateCreated];
        }];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            if (block) block(works);
        });
    });
}

-(void)createDirectoryAtURL:(NSURL *)url
{
    if (![[NSFileManager defaultManager] fileExistsAtPath:[url path] isDirectory:nil]){
        NSError *error;
        [[NSFileManager defaultManager] createDirectoryAtPath:[url path] withIntermediateDirectories:NO attributes:nil error:&error];
        if (error) NSLog(@"%@", error);
    }
}

@end