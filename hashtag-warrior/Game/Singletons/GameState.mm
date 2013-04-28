//
//  GameState.m
//  hashtag-warrior
//
//  Created by Nick James on 20/01/2013.
//
//

#import "GameState.h"

@implementation GameState

@synthesize _score;
@synthesize _hashtag;
@synthesize _gravity;

+(GameState*)sharedInstance
{
    static GameState *sharedInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedInstance = [[GameState alloc] init];
    });
    return sharedInstance;
}

-(id)init
{
    if ((self=[super init]))
    {
        self._score = 0;
        self._hashtag = @"foo";
        
        self._gravity = b2Vec2(0.0f, -10.0f);
    }
    
    return self;
}

-(void)encodeWithCoder:(NSCoder *)coder
{
    [coder encodeInt:self._score forKey:@"_score"];
    [coder encodeObject:self._hashtag forKey:@"_hashtag"];
}

-(id)initWithCoder:(NSCoder *)coder
{
    self = [super init];
    
    if(self != nil)
    {
        self._score = [coder decodeIntForKey:@"_score"];
        self._hashtag = [coder decodeObjectForKey:@"_hashtag"];
    }
    
    return self;
}

@end
