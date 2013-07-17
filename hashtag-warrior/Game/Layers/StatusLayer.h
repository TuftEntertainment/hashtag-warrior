//
//  StatusLayer.h
//  hashtag-warrior
//
//  Created by Daniel Wood on 13/02/2013.
//  Copyright (c) 2013 Ossum Games. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "cocos2d.h"
#import "GameState.h"

@interface StatusLayer : CCLayer
{
    GameState *_state;
    
    CCLabelTTF *_score;
}

@end