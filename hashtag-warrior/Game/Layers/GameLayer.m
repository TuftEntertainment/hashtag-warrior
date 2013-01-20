//
//  GameLayer.m
//  hashtag-warrior
//
//  Created by Nick James on 18/01/2013.
//  Copyright 2013 __MyCompanyName__. All rights reserved.
//

#import "GameLayer.h"
#import "GameOverScene.h"

@implementation GameLayer

- (id)init
{
    if ((self=[super init]))
    {
        // Get an instance of the game state singleton.
        _state = [GameState sharedInstance];
        
        // Create and initialize a Label.
		CCLabelTTF *label = [CCLabelTTF labelWithString:@"Insert game here..." fontName:@"Marker Felt" fontSize:64];
        
        // Ask director for the window size.
		CGSize size = [[CCDirector sharedDirector] winSize];
        
		// Position the label on the center of the screen.
		label.position =  ccp( size.width /2 , size.height/2 );
		
		// Add the label as a child to this Layer.
		[self addChild: label];
        
        // Add the game over menu, just for testing the transitions.
        [self addGameOverMenu];
        
    }
    return self;
}

- (void) dealloc
{
	// Nothing else to deallocate.
	[super dealloc];
}

-(void) addGameOverMenu
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
	
	CGSize size = [[CCDirector sharedDirector] winSize];
	[menu setPosition:ccp( size.width/2, size.height/3)];
	
	[self addChild: menu z:-1];
}

@end
