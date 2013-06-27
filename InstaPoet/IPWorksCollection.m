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
    NSString *directory = DOCUMENTS;
    
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
            IPWork *work = [NSKeyedUnarchiver unarchiveObjectWithFile:[NSString stringWithFormat:@"%@/%@", DOCUMENTS, fileName]];
            
            if (work)
                [works addObject:work];
        }
        
        dispatch_async(dispatch_get_main_queue(), ^{
            if (block) block(works);
        });
    });
}

@end