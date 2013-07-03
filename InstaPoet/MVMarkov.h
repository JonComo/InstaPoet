//
//  MVMarkov.h
//  Markov
//
//  Created by Jon Como on 12/8/12.
//  Copyright (c) 2012 Jon Como. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface MVMarkov : NSObject <NSCoding>

@property (nonatomic, strong) NSString *name;

-(void)generateModelWithString:(NSString *)string completion:(void(^)(void))block;
-(void)suggestWordsForString:(NSString *)string completion:(void(^)(NSArray *words))block;

@end