//
//  IPWork.h
//  InstaPoet
//
//  Created by Jon Como on 6/26/13.
//  Copyright (c) 2013 Jon Como. All rights reserved.
//

#import <Foundation/Foundation.h>

@class MVMarkov;

typedef enum
{
    kWorkTypeAuthor,
    kWorkTypeUser
} kWorkType;

@interface IPWork : NSObject <NSCoding>

@property (nonatomic, strong) NSURL *modelURL;
@property (nonatomic, strong) NSString *text;
@property (nonatomic, strong) NSURL *url;
@property (nonatomic, strong) NSDate *dateCreated;
@property (nonatomic, strong) MVMarkov *markov;

-(id)initWithType:(kWorkType)type;
-(void)save;

@end