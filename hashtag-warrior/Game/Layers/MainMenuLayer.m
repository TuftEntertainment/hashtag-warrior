//
//  MainMenuLayer.m
//  hashtag-warrior
//
//  Created by Nick James on 20/01/2013.
//  Copyright 2013 __MyCompanyName__. All rights reserved.
//

#import "MainMenuLayer.h"
#import "GameScene.h"


@implementation MainMenuLayer

- (id)init
{
    if ((self=[super init]))
    {
        // Add the main menu.
        [self addMainMenu];
    }
    return self;
}

- (void) dealloc
{
    // Nothing else to deallocate.
    [super dealloc];
}

-(void) addMainMenu
{
    // Default font size will be 32 points.
    [CCMenuItemFont setFontSize:32];
    
    // New game menu item.
    CCMenuItemLabel *newGame = [CCMenuItemFont itemWithString:@"New Game" block:^(id sender)
    {
        [[CCDirector sharedDirector] replaceScene:[CCTransitionShrinkGrow transitionWithDuration:1.0
                                                                                           scene:[GameScene node]]];
    }];
    
    // Create the main menu.
    CCMenu *menu = [CCMenu menuWithItems:newGame, nil];
    
    // Align everything vertically.
    [menu alignItemsVertically];
    
    // Place it in the middle of the screen.
    CGSize size = [[CCDirector sharedDirector] winSize];
    [menu setPosition:ccp(size.width/2, size.height/2)];
    
    // Add to the layer.
    [self addChild: menu];
}

@end