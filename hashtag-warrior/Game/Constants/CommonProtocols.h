//
//  CommonProtocols.h
//  hashtag-warrior
//
//  Created by Daniel Wood on 28/04/2013.
//  Copyright (c) 2013 Ossum Games. All rights reserved.
//

#ifndef hashtag_warrior_CommonProtocols_h
#define hashtag_warrior_CommonProtocols_h

typedef enum {
    kStateSpawning,
    kStateIdle,
    kStateRunningLeft,
    kStateRunningRight,
    kStateDead
} GameObjectState;

typedef enum {
    kNullType,
    kHeroType,
    kTweetType,
    kTwooshType
} GameObjectType;

typedef enum {
    kHWNoScene=0,
    kHWIntroScene=1,
    kHWMainMenuScene=2,
    kHWAboutScene=3,
    kHWGameOverScene=4,
    kHWGameScene=100
} SceneTypes;


// TODO not convinced the below will be necessary - at the moment
// only the GameLayer will be creating objects, and it's fine for
// the GameLayer to know what it itself is doing..
@protocol GameplayLayerDelegate
-(void)createObjectOfType:(GameObjectType)objectType
               atLocation:(CGPoint)spawnLocation
           withStartAngle:(int)startAngle
        withStartVelocity:(float)startVelocity
               withZValue:(int)zValue;
@end

#endif
