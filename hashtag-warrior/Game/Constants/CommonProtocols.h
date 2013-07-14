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

#endif
