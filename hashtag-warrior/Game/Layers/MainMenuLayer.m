//
//  MainMenuLayer.m
//  hashtag-warrior
//
//  Created by Nick James on 20/01/2013.
//  Copyright 2013 Ossum Games. All rights reserved.
//

#import "MainMenuLayer.h"
#import "Constants.h"
#import "GameManager.h"


@implementation MainMenuLayer

- (id)init
{
    if ((self=[super init]))
    {
        [self addMainMenu];
    }
    return self;
}

- (void) addMainMenu
{
    // Default font size will be 32 points.
    [CCMenuItemFont setFontSize:32];
    
    // Menu items
    CCMenuItemLabel *newGame = [CCMenuItemFont itemWithString:NSLocalizedString(@"New Game", nil) block:^(id sender)
    {
        [[GameManager sharedGameManager] runSceneWithID:kHWGameScene];
    }];
    newGame.color = kHWTextColor;
    CCMenuItemLabel *about = [CCMenuItemFont itemWithString:NSLocalizedString(@"About", nil) block:^(id aboutSender)
    {
        [[GameManager sharedGameManager] runSceneWithID:kHWAboutScene];
    }];
    about.color = kHWTextColor;
    
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
