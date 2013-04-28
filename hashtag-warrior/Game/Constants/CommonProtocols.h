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
    kTweetType,
    kTwooshType
} GameObjectType;

@protocol GameplayLayerDelegate
-(void)createObjectOfType:(GameObjectType)objectType
               atLocation:(CGPoint)spawnLocation
           withStartAngle:(int)startAngle
        withStartVelocity:(float)startVelocity
               withZValue:(int)zValue;
@end

#endif
