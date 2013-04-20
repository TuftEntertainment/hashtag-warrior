//
//  MainMenuLayer.m
//  hashtag-warrior
//
//  Created by Nick James on 20/01/2013.
//  Copyright 2013 Ossum Games. All rights reserved.
//

#import "MainMenuLayer.h"
#import "AboutScene.h"
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

- (void) addMainMenu
{
    // Default font size will be 32 points.
    [CCMenuItemFont setFontSize:32];
    
    // Menu items
    CCMenuItemLabel *newGame = [CCMenuItemFont itemWithString:NSLocalizedString(@"New Game", nil) block:^(id sender)
    {
        [[CCDirector sharedDirector] replaceScene:[CCTransitionShrinkGrow transitionWithDuration:1.0
                                                                                           scene:[GameScene node]]];
    }];
    newGame.color = ccc3(8, 90, 124);
    CCMenuItemLabel *about = [CCMenuItemFont itemWithString:NSLocalizedString(@"About", nil) block:^(id aboutSender)
    {
        [[CCDirector sharedDirector] replaceScene:[CCTransitionFade transitionWithDuration:1.0
                                                                    scene:[AboutScene node]]];
    }];
    about.color = ccc3(8, 90, 124);
    
    // Create the main menu.
    CCMenu *menu = [CCMenu menuWithItems:newGame, about, nil];
    
    // Align everything vertically.
    [menu alignItemsVertically];
    
    // Place it in the middle of the screen.
    CGSize size = [[CCDirector sharedDirector] winSize];
    [menu setPosition:ccp(size.width/2, size.height/2)];
    
    // Add to the layer.
    [self addChild: menu];
}

@end
