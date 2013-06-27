//
//  MVPhrase.h
//  Markov
//
//  Created by Jon Como on 12/8/12.
//  Copyright (c) 2012 Jon Como. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface MVPhrase : NSObject <NSCoding>

@property (strong, nonatomic) NSString *text;
@property (strong, nonatomic) NSMutableArray *nextWords;

-(id)init;

@end