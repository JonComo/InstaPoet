//
//  NSURL+Unique.m
//  InstaPoet
//
//  Created by Jon Como on 11/25/13.
//  Copyright (c) 2013 Jon Como. All rights reserved.
//

#import "NSURL+Unique.h"

@implementation NSURL (Unique)

+(NSURL *)uniqueWithName:(NSString *)name
{
    NSString *documents = [[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask][0];
    
    int count = 0;
    
    NSURL *URL;
    
    do {
        URL = [NSURL URLWithString:[NSString stringWithFormat:@"%@%@%i", documents, name, count]];
        
        NSLog(@"URL: %@", URL);
        
        count ++;
    } while ([[NSFileManager defaultManager] fileExistsAtPath:[URL path]]);
    
    return URL;
}

@end
