//
//  GameLayer.h
//  hashtag-warrior
//
//  Created by Nick James on 18/01/2013.
//  Copyright 2013 Ossum Games. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "cocos2d.h"
#import "Box2D.h"
#import "GLES-Render.h"

#import "GameState.h"

#import "Hero.h"
#import "Projectile.h"

#import <HeroContactListener.h>

@interface GameLayer : CCLayer
{
    GLESDebugDraw *_debugDraw;
    GameState *_state;
    b2World *_world;
    b2Body *_groundBody;
    CCSpriteBatchNode *sceneSpriteBatchNode;
    HeroContactListener *_contactListener;
    
    // TODO possibly these will move into the SpriteBatchNode
    Hero *_hero;
    Projectile *_projectile;
}

@end
