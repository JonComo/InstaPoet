//
//  IPWork.h
//  InstaPoet
//
//  Created by Jon Como on 6/26/13.
//  Copyright (c) 2013 Jon Como. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface IPWork : NSObject <NSCoding>

@property (nonatomic, strong) NSURL *modelURL;
@property (nonatomic, strong) NSString *text;
@property (nonatomic, strong) NSURL *url;
@property (nonatomic, strong) NSDate *dateCreated;

-(void)save;

@end