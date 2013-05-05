//
//  GameState.h
//  hashtag-warrior
//
//  GameState retains information on the current state of the game,
//  including saving/loading this information from disk.
//
//  Created by Nick James on 20/01/2013.
//  Copyright (c) 2013 Ossum Games. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "cocos2d.h"
#import "Box2D.h"

@interface GameState : NSObject <NSCoding>
{
    NSString *_hashtag;
    NSInteger _score;
    b2Vec2 _gravity;
}

+(GameState*)sharedInstance;

@property (readwrite) NSString *_hashtag;
@property (readwrite) NSInteger _score;
@property (readwrite) b2Vec2 _gravity;

@end
