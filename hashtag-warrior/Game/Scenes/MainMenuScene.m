//
//  MainMenuScene.m
//  hashtag-warrior
//
//  Created by Nick James on 20/01/2013.
//  Copyright 2013 __MyCompanyName__. All rights reserved.
//

#import "MainMenuScene.h"
#import "MainMenuLayer.h"


@implementation MainMenuScene

- (id)init
{
    if ((self = [super init]))
    {
        // All this scene does upon initialization is init & add the layer class.
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
