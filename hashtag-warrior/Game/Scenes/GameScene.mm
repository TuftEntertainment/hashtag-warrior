//
//  GameScene.m
//  hashtag-warrior
//
//  Created by Nick James on 19/01/2013.
//  Copyright 2013 Ossum Games. All rights reserved.
//

#import "GameScene.h"
#import "BackgroundLayer.h"
#import "GameLayer.h"
#import "StatusLayer.h"


@implementation GameScene

- (id)init
{
    if ((self = [super init]))
    {
        [self addChild:[CCLayerColor layerWithColor:ccc4(142, 193, 218, 255)]];
        
        BackgroundLayer *bgLayer = [BackgroundLayer node];
        [self addChild:bgLayer z:0];
        
        GameLayer *layer = [GameLayer node];
        [self addChild:layer];
        
        StatusLayer *statLayer = [StatusLayer node];
        [self addChild:statLayer];
    }
    
    return self;
}

- (void)dealloc
{
    // Nothing else to deallocate.
    [super dealloc];
}

@end
