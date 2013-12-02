//
//  IPWorksCollection.h
//  InstaPoet
//
//  Created by Jon Como on 6/26/13.
//  Copyright (c) 2013 Jon Como. All rights reserved.
//

#import <Foundation/Foundation.h>

#define WORKS @"works"

@class IPWork;

@interface IPWorksCollection : NSObject

+(IPWorksCollection *)sharedCollection;

/*
-(NSArray *)localFilesOfType:(int)type;
-(void)saveFile:(IPWork *)work;
-(void)deleteFile:(IPWork *)file;
 */

-(NSArray *)dirLocalFiles;

@end