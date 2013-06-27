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

-(void)buildModelWithAuthorWork:(NSString *)work contextLevel:(u_int)desiredContextLevel completion:(void (^)(void))block
{
    contextLevel = desiredContextLevel;
    //IPAuthor *author = [[IPAuthor alloc] initWithFileURL:authorURL];
    
    if (phrases) {
        [phrases removeAllObjects];
    }else{
        phrases = [[NSMutableArray alloc] init];
    }
    
    //enumerate string and layout relationships
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^{
        
        NSString *string = work;
        
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

-(NSArray *)wordsFromString:(NSString *)string
{
    NSMutableArray *words = [[NSMutableArray alloc] init];
    
    NSRange range;
    range.location = 0;
    range.length = string.length;
    
    [string enumerateSubstringsInRange:range options:NSStringEnumerationByWords usingBlock:^(NSString *substring, NSRange substringRange, NSRange enclosingRange, BOOL *stop) {
        //Construct a phrase for each word
        [words addObject:substring];
    }];
    
    return words;
}

-(MVPhrase *)phraseForString:(NSString *)string inArray:(NSMutableArray *)phrasesArray
{
    NSIndexSet *set = [phrasesArray indexesOfObjectsPassingTest:^BOOL(id obj, NSUInteger idx, BOOL *stop) {
        MVPhrase *phrase = (MVPhrase *)obj;
        BOOL foundPhrase = [phrase.text isEqualToString:string];
        if (foundPhrase) *stop = YES;
        return foundPhrase;
    }];
    
    if (set.count >= 1) return [phrasesArray objectAtIndex:set.firstIndex];
    
    return nil;
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

@end