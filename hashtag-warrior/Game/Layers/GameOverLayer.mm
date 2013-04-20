//
//  GameOverLayer.m
//  hashtag-warrior
//
//  Created by Nick James on 18/01/2013.
//  Copyright 2013 Ossum Games. All rights reserved.
//

#import "Constants.h"
#import "GameOverLayer.h"
#import "MainMenuScene.h"

@implementation GameOverLayer

- (id)init
{
    if ((self=[super init]))
    { 
        // Create and initialize a label for the title.
        CCLabelTTF *title = [CCLabelTTF labelWithString:NSLocalizedString(@"Game Over", nil)
                                               fontName:@"Marker Felt"
                                               fontSize:64];
        title.color = kHWTextColor;
        
        // Ask director for the window size.
        CGSize size = [[CCDirector sharedDirector] winSize];
        
        // Position the labels on the center of the screen.
        title.position = ccp(size.width /2 , size.height/2);
        
        // Add the labels as a child to this Layer.
        [self addChild: title];
        
        // In three seconds transition to the new scene.
        [self scheduleOnce:@selector(makeTransition:) delay:1];
    }
    return self;
}

-(void) makeTransition:(ccTime)dt
{
    // Go back to the game.
    [[CCDirector sharedDirector] replaceScene:[CCTransitionFade transitionWithDuration:1.0
                                                                                 scene:[MainMenuScene node]
                                                                             withColor:ccBLACK]];
}

- (void) dealloc
{
    // Nothing else to deallocate.
    [super dealloc];
}

@end
