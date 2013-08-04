/*
 * #Warrior - http://tuftentertainment.github.io/hashtag-warrior/
 *
 * The MIT License (MIT)
 *
 * Copyright (c) 2013 Tuft Entertainment
 *
 * Permission is hereby granted, free of charge, to any person obtaining a copy
 * of this software and associated documentation files (the "Software"), to deal
 * in the Software without restriction, including without limitation the rights
 * to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 * copies of the Software, and to permit persons to whom the Software is
 * furnished to do so, subject to the following conditions:
 *
 * The above copyright notice and this permission notice shall be included in
 * all copies or substantial portions of the Software.
 *
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 * IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 * FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 * AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 * LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 * OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
 * THE SOFTWARE.
 */

#import "GameState.h"

@implementation GameState

@synthesize _score;
@synthesize _hashtag;
@synthesize _gravity;
@synthesize _practice;

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
        self._hashtag = @"#Warrior";
        self._gravity = b2Vec2(0.0f, -10.0f);
        self._practice = TRUE;
    }
    
    return self;
}

-(void)encodeWithCoder:(NSCoder *)coder
{
    [coder encodeInt:self._score forKey:@"_score"];
    [coder encodeObject:self._hashtag forKey:@"_hashtag"];
    [coder encodeBool:self._practice forKey:@"_practice"];
}

-(id)initWithCoder:(NSCoder *)coder
{
    self = [super init];
    
    if(self != nil)
    {
        self._score = [coder decodeIntForKey:@"_score"];
        self._hashtag = [coder decodeObjectForKey:@"_hashtag"];
        self._practice = [coder decodeBoolForKey:@"_practice"];
    }
    
    return self;
}

@end
