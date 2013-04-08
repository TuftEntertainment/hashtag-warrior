//
//  GameOverScene.m
//  hashtag-warrior
//
//  Created by Nick James on 19/01/2013.
//  Copyright 2013 Ossum Games. All rights reserved.
//

#import "GameOverScene.h"
#import "GameOverLayer.h"
#import "BackgroundLayer.h"


@implementation GameOverScene

- (id)init
{
    if ((self = [super init]))
    {
        BackgroundLayer *bgLayer = [BackgroundLayer node];
        [self addChild:bgLayer z:0];
        
        GameOverLayer *layer = [GameOverLayer node];
        [self addChild:layer];
    }
    
    return self;
}

- (void)dealloc
{
    // Nothing else to deallocate.
    [super dealloc];
}

@end