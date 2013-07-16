//
//  GameObject.h
//  hashtag-warrior
//
//  Created by Daniel Wood on 28/04/2013.
//  Copyright (c) 2013 Ossum Games. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "cocos2d.h"
#import "Box2D.h"
#import "Constants.h"
#import "CommonProtocols.h"

@interface GameObject : CCSprite
{
    BOOL isActive;
    BOOL reactsToScreenBoundaries;
    CGSize screenSize;
    GameObjectType gameObjectType;
    GameObjectState state;
    b2Body *physicsBody;
}

@property (readwrite) BOOL isActive;
@property (readwrite) BOOL reactsToScreenBoundaries;
@property (readwrite) CGSize screenSize;
@property (readwrite) GameObjectType gameObjectType;
@property (readwrite) GameObjectState state;
@property (readwrite) b2Body* physicsBody;

-(void)changeState:(GameObjectState)newState;

-(void)updateStateWithDeltaTime:(ccTime)deltaTime andListOfGameObjects:(CCArray*)listOfGameObjects;

-(CGRect)adjustedBoundingBox;

-(CCAnimation*)loadPlistForAnimationWithName:(NSString*)animationName andClassName:(NSString*)className;

@end