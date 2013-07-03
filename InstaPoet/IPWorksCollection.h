//
//  IPWorksCollection.h
//  InstaPoet
//
//  Created by Jon Como on 6/26/13.
//  Copyright (c) 2013 Jon Como. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface IPWorksCollection : NSObject

+(IPWorksCollection *)sharedCollection;

-(void)loadLocalWorksCompletion:(void(^)(NSArray *works))block;
-(void)loadLocalAuthorsCompletion:(void(^)(NSArray *authors))block;
-(void)createDirectoryAtURL:(NSURL *)url;

@end