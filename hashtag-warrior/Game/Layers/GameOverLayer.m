//
//  GameOverLayer.m
//  hashtag-warrior
//
//  Created by Nick James on 18/01/2013.
//  Copyright 2013 __MyCompanyName__. All rights reserved.
//

#import "GameOverLayer.h"
#import "GameScene.h"

@implementation GameOverLayer

- (id)init
{
    if ((self=[super init]))
    {
        // Create and initialize a Label.
		CCLabelTTF *label = [CCLabelTTF labelWithString:@"Game Over!" fontName:@"Marker Felt" fontSize:64];
        
        // Ask director for the window size.
		CGSize size = [[CCDirector sharedDirector] winSize];
        
		// Position the label on the center of the screen.
		label.position =  ccp( size.width /2 , size.height/2 );
		
		// Add the label as a child to this Layer.
		[self addChild: label];
    }
    return self;
}

-(void) onEnter
{
	[super onEnter];
    
	// In three seconds transition to the new scene.
	[self scheduleOnce:@selector(makeTransition:) delay:3];
}

-(void) makeTransition:(ccTime)dt
{
    // Go back to the game.
	[[CCDirector sharedDirector] replaceScene:[CCTransitionFade transitionWithDuration:1.0
                                                                                 scene:[GameScene node]
                                                                             withColor:ccBLACK]];
}

- (void) dealloc
{
	// Nothing else to deallocate.
	[super dealloc];
}

@end
