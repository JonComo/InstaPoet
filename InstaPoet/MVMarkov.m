//
//  MVMarkov.m
//  Markov
//
//  Created by Jon Como on 12/8/12.
//  Copyright (c) 2012 Jon Como. All rights reserved.
//

#import "MVMarkov.h"
#import "MVPhrase.h"

@interface MVMarkov ()
{
    NSMutableArray *phrases;
    NSString *authorWork;
    u_int contextLevel;
}

@end

@implementation MVMarkov

-(id)initWithCoder:(NSCoder *)aDecoder
{
    if (self = [super init]) {
        //init
        phrases = [aDecoder decodeObjectForKey:@"phrases"];
        authorWork = [aDecoder decodeObjectForKey:@"authorWork"];
        contextLevel = [aDecoder decodeIntForKey:@"contextLevel"];
        _name = [aDecoder decodeObjectForKey:@"name"];
    }
    
    return self;
}

-(void)encodeWithCoder:(NSCoder *)aCoder
{
    [aCoder encodeObject:phrases forKey:@"phrases"];
    [aCoder encodeObject:authorWork forKey:@"authorWork"];
    [aCoder encodeInt:contextLevel forKey:@"contextLevel"];
    [aCoder encodeObject:self.name forKey:@"name"];
}

/*

-(void)generateWithAuthorWork:(NSString *)work contextLevel:(u_int)desiredContextLevel completion:(void (^)(void))block
{
    NSLog(@"Generating model");
    
    contextLevel = desiredContextLevel;
    
    if (phrases) {
        [phrases removeAllObjects];
    }else{
        phrases = [NSMutableArray array];
    }
    
    //enumerate string and layout relationships
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^{
        
        NSString *string = [work lowercaseString];
        
        [string enumerateLinesUsingBlock:^(NSString *line, BOOL *stop) {
            
            if (line.length > 0){
                
                NSArray *words = [self wordsFromString:line];
                
                for (u_int context = 1; context<contextLevel+1; context++)
                {
                    //For each level of context create phrases
                    [words enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
                        
                        NSString *phraseString = @"";
                        
                        for (u_int k = 0; k < context; k++)
                        {
                            if (idx+k < words.count-1)
                            {
                                phraseString = [NSString stringWithFormat:@"%@%@%@", phraseString, (k==0) ? @"" : @" ", words[idx+k]];
                            }
                        }
                        
                        if (phraseString.length > 0) {
                            
                            MVPhrase *phrase = [self phraseForString:phraseString inArray:phrases];
                            
                            if (phrase) {
                                //Phrase did exist in array alread, just add relationships
                                phrase.count ++;
                            }else{
                                //Phrase didn't exist, so create it now and add it to the array
                                phrase = [[MVPhrase alloc] init];
                                phrase.text = phraseString;
                                [phrases addObject:phrase];
                            }
                            
                            if (idx+context < words.count)
                            {
                                //Get the word(s) following the phrase
                                NSString *nextWord = words[idx + context];
                                [phrase.nextWords addObject:nextWord];
                            }
                            
                        }
                        
                    }];
                }
            }
            
        }];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            //Call completion block when done:
            if (block) block();
        });
        
    });
}


-(void)suggestWordsAfterString:(NSString *)wordsString completion:(void (^)(NSArray *words))block
{
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^{
        
        NSString *string = [wordsString lowercaseString];
        NSArray *words = [self wordsFromString:string];
        
        NSString *stringToAnalyze = @"";
        
        int initialValue = words.count - 1;
        int stoppingValue = initialValue - (contextLevel-1);
        
        NSMutableDictionary *wordsDictionary = [[NSMutableDictionary alloc] init];
        
        for (int i = initialValue; i >= stoppingValue; i--) {
            //Get biggest context
            if (i >= 0) {
                stringToAnalyze = [NSString stringWithFormat:@"%@%@%@", words[i], (i==initialValue) ? @"" : @" ", stringToAnalyze];
                MVPhrase *phrase = [self phraseForString:stringToAnalyze inArray:phrases];
                
                for (NSString *word in phrase.nextWords)
                {
                    NSNumber *count = (NSNumber *)[wordsDictionary valueForKey:word];
                    if (count) {
                        //Contains the key already
                        count = @(count.integerValue + 1);
                        [wordsDictionary setValue:count forKey:word];
                    }else{
                        //Create key
                        [wordsDictionary setValue:@(1) forKey:word];
                    }
                }
            }
        }
        
        NSArray *sortedKeys = [wordsDictionary keysSortedByValueUsingComparator:^NSComparisonResult(id obj1, id obj2) {
            return [obj2 compare:obj1];
        }];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            //Call completion block when done:
            block(sortedKeys);
        });
    });
}

*/

-(void)generateModelWithString:(NSString *)string completion:(void(^)(void))block
{
    if (!phrases){
        phrases = [NSMutableArray array];
    }else{
        [phrases removeAllObjects];
    }
    
    string = [string lowercaseString];
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^{
        [string enumerateLinesUsingBlock:^(NSString *line, BOOL *stop) {
            NSArray *words = [self wordsFromString:line];
            
            [words enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
                NSString *word = (NSString *)obj;
                
                MVPhrase *phrase = [self phraseForString:word inArray:phrases increment:YES];
                
                int nextWordIndex = idx + 1;
                
                if (nextWordIndex < words.count)
                {
                    NSString *nextWord = words[nextWordIndex];
                    
                    MVPhrase *nextPhrase = [self phraseForString:nextWord inArray:phrases increment:YES];
                    
                    if (![phrase.nextPhrases containsObject:nextPhrase])
                        [phrase.nextPhrases addObject:nextPhrase];
                }
            }];
        }];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            if (block) block();
        });
    });
}

-(void)suggestWordsForString:(NSString *)string completion:(void(^)(NSArray *words))block
{
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^{
        
        NSArray *words = [self wordsFromString:[string lowercaseString]];
        NSString *lastWord = [words lastObject];
        
        MVPhrase *phrase = [self phraseForString:lastWord inArray:phrases increment:NO];
        
        NSMutableArray *nextPhrases = phrase.nextPhrases;
        
        [nextPhrases sortUsingComparator:^NSComparisonResult(id obj1, id obj2) {
            MVPhrase *phrase1 = obj1;
            MVPhrase *phrase2 = obj2;
            
            return (phrase1.count > phrase2.count);
        }];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            if (block) block(phrase.nextPhrases);
        });
    });
}

-(NSArray *)wordsFromString:(NSString *)string
{
    NSMutableArray *words = [NSMutableArray array];
    
    NSRange range;
    range.location = 0;
    range.length = string.length;
    
    [string enumerateSubstringsInRange:range options:NSStringEnumerationByWords usingBlock:^(NSString *substring, NSRange substringRange, NSRange enclosingRange, BOOL *stop) {
        //Construct a phrase for each word
        [words addObject:substring];
    }];
    
    return words;
}

-(MVPhrase *)phraseForString:(NSString *)string inArray:(NSMutableArray *)phrasesArray increment:(BOOL)increment
{
    for (MVPhrase *phrase in phrasesArray)
    {
        if ([phrase.text isEqualToString:string])
        {
            if (increment) phrase.count ++;
            return phrase;
        }
    }
    
    MVPhrase *newPhrase = [MVPhrase new];
    newPhrase.text = string;
    [phrasesArray addObject:newPhrase];
    
    return newPhrase;
}

@end