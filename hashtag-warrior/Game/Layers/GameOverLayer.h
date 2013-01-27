//
//  GameOverLayer.h
//  hashtag-warrior
//
//  Created by Nick James on 18/01/2013.
//  Copyright 2013 Ossum Games. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "cocos2d.h"
#import "GameState.h"

@interface GameOverLayer : CCLayer
{
    // The game state.
    GameState *_state;
}

@end
