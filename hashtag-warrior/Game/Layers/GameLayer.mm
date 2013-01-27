//
//  GameLayer.m
//  hashtag-warrior
//
//  Created by Nick James on 18/01/2013.
//  Copyright 2013 Ossum Games. All rights reserved.
//

#import "GameLayer.h"
#import "GameOverScene.h"

#import "Hero.h"

// Define macros to convert from an iPhone ccp to iPad ccp.
// Note: Not much use when using the size from the director (e.g. [[CCDirector sharedDirector] winSize].width) as this
//       returns the size of the current device.
#define kXoffsetiPad        64
#define kYoffsetiPad        32

#define ADJUST_X(__x__)\
(UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad ? (__x__ * 2) + kXoffsetiPad : __x__)

#define ADJUST_Y(__y__)\
(UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad ? (__y__ * 2) + kYoffsetiPad : __y__)

#define ADJUST_CCP(__p__)\
(UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad ? ccp( ADJUST_X(__p__.x), ADJUST_Y(__p__.y) ) : __p__)

@implementation GameLayer

- (id)init
{
    if ((self=[super init]))
    {
        // Get an instance of the game state singleton.
        _state = [GameState sharedInstance];
        
        // Ask director for the window size.
        CGSize size = [[CCDirector sharedDirector] winSize];
        
        // Create the world.
        _world = new b2World(_state._gravity);
        
        // Create our hero.
        [self createHero:size];
        
        // Add the game over menu (so we can escape the layer until game logic is implemented)
        [self addGameOverMenu:size];
    }
    return self;
}

- (void) dealloc
{
    // Nothing else to deallocate.
    [super dealloc];
}

- (void) createHero: (CGSize) screenSize
{
    // Enable the accelerometer.
    self.isAccelerometerEnabled = YES;
    
    // Our hero.
    Hero *hero = [Hero spriteWithFile:@"Hero.png"];
    
    // Have him sit at the bottom of the screen, in the middle.
    hero.position = ccp(screenSize.width/2, ADJUST_Y(16) );
    [self addChild:hero];
}

- (void) addGameOverMenu: (CGSize) screenSize
{
    // Default font size will be 32 points.
    [CCMenuItemFont setFontSize:32];
    
    // Win Button.
    CCMenuItemLabel *win = [CCMenuItemFont itemWithString:@"Win Game" block:^(id sender)
    {
       _state._won = YES;
       [[CCDirector sharedDirector] replaceScene:[CCTransitionRotoZoom transitionWithDuration:1.0
                                                                                        scene:[GameOverScene node]]];
    }];
    
    // Lose Button
    CCMenuItemLabel *lose = [CCMenuItemFont itemWithString:@"Lose Game" block:^(id sender)
    {
        _state._won = NO;
        [[CCDirector sharedDirector] replaceScene:[CCTransitionSplitCols transitionWithDuration:2.0
                                                                                          scene:[GameOverScene node]]];
    }];
    
    CCMenu *menu = [CCMenu menuWithItems:win, lose, nil];
    
    [menu alignItemsHorizontallyWithPadding:30.0f];
    
    [menu setPosition:ccp(screenSize.width/2, ADJUST_Y(304))];
    
    [self addChild: menu z:-1];
}

@end
