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

-(void)buildModelWithAuthorWork:(NSString *)work contextLevel:(u_int)desiredContextLevel completion:(void (^)(void))block;
-(void)suggestWordsAfterString:(NSString *)wordsString completion:(void (^)(NSArray *words))block;

@end