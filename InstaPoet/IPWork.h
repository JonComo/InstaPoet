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
    IPWorkTypeInspiration,
    IPWorkTypeUser
} IPWorkType;

@interface IPWork : NSObject <NSCoding>

@property IPWorkType type;
@property (nonatomic, strong) NSString *name;

@property (nonatomic, strong) NSURL *url;

@property (nonatomic, strong) NSString *text; //loaded from disk
@property (nonatomic, strong) MVMarkov *model; //loaded from disk

@property (nonatomic, strong) NSString *summary;

@property (nonatomic, strong) NSDate *dateCreated;

-(id)initWithType:(IPWorkType)type name:(NSString *)name text:(NSString *)text;

+(void)setupSavedWorks;
+(NSArray *)localFiles;
-(void)loadFromDiskCompletion:(void(^)(void))block;
-(void)saveToDisk;

-(void)generateModelCompletion:(void(^)(void))block;

@end