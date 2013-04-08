//
//  MainMenuScene.m
//  hashtag-warrior
//
//  Created by Nick James on 20/01/2013.
//  Copyright 2013 Ossum Games. All rights reserved.
//

#import "MainMenuScene.h"
#import "MainMenuLayer.h"
#import "BackgroundLayer.h"


@implementation MainMenuScene

- (id)init
{
    if ((self = [super init]))
    {
        BackgroundLayer *bgLayer = [BackgroundLayer node];
        [self addChild:bgLayer z:0];
        
        MainMenuLayer *layer = [MainMenuLayer node];
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
